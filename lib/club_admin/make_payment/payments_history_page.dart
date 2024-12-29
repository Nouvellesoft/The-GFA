// payment_history_page.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:the_gfa/keys/some_keys.dart';

class ClubPaymentHistoryPage extends StatefulWidget {
  final String clubId;

  const ClubPaymentHistoryPage({super.key, required this.clubId});

  @override
  State<ClubPaymentHistoryPage> createState() => _ClubPaymentHistoryPageState();
}

class _ClubPaymentHistoryPageState extends State<ClubPaymentHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      // Load from Firestore using the correct path
      final firestorePayments =
          await _firestore.collection('clubs').doc(widget.clubId).collection('PaymentHistory').orderBy('timestamp', descending: true).get();

      // Load from Stripe
      final stripePayments = await _loadStripePayments();

      // Combine and sort payments
      final allPayments = [
        ...firestorePayments.docs.map((doc) => {
              ...doc.data(),
              'source': 'firestore',
              'id': doc.id,
            }),
        ...stripePayments,
      ];

      // Sort by timestamp
      allPayments.sort((a, b) {
        DateTime timestampA = a['timestamp'] is Timestamp ? (a['timestamp'] as Timestamp).toDate() : a['timestamp'] as DateTime;
        DateTime timestampB = b['timestamp'] is Timestamp ? (b['timestamp'] as Timestamp).toDate() : b['timestamp'] as DateTime;
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        _payments = allPayments;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading payments: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadStripePayments() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents?limit=100'),
        headers: {
          'Authorization': 'Bearer $secretStripeKey',
        },
      );

      final data = json.decode(response.body);
      if (data['data'] == null) return [];

      return data['data']
          .where((payment) => payment['metadata']?['club_id'] == widget.clubId && payment['status'] == 'succeeded')
          .map<Map<String, dynamic>>((payment) => {
                'id': payment['id'],
                'amount': payment['amount'] / 100,
                'currency': payment['currency'],
                'timestamp': DateTime.fromMillisecondsSinceEpoch(payment['created'] * 1000),
                'status': payment['status'],
                'source': 'stripe',
                'paymentMethod': payment['payment_method_types']?[0] ?? 'unknown',
                'planType': payment['metadata']?['plan_type'] ?? 'N/A',
                'period': payment['metadata']?['period'] ?? 'N/A',
              })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Stripe payments: $e');
      }
      return [];
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('MMM dd, yyyy HH:mm').format(timestamp);
    }
    return 'Invalid Date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No payment history available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: payment['status'] == 'succeeded' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          child: Icon(
                            payment['status'] == 'succeeded' ? Icons.check_circle : Icons.info,
                            color: payment['status'] == 'succeeded' ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${payment['currency'].toString().toUpperCase()} ${payment['amount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                payment['planType'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(_formatTimestamp(payment['timestamp'])),
                            Text(
                              'Payment Method: ${payment['paymentMethod']?.toString().toUpperCase() ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (payment['period'] != null)
                              Text(
                                'Period: ${payment['period']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            payment['source'].toString().toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
