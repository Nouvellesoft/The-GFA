import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:the_gfa/club_admin/make_payment/payment_plan_page.dart';
import 'package:the_gfa/club_admin/make_payment/payments_history_page.dart';
import 'package:the_gfa/keys/some_keys.dart';

import '../../notifier/a_club_global_notifier.dart';

String clubName = '';

class ClubAppPaymentPage extends StatefulWidget {
  final String clubId;

  const ClubAppPaymentPage({super.key, required this.clubId});

  @override
  State<ClubAppPaymentPage> createState() => _ClubAppPaymentPageState();
}

class _ClubAppPaymentPageState extends State<ClubAppPaymentPage> {
  bool isMonthly = true;
  int selectedPlanIndex = 0;
  late DatabaseReference _pricingRef;
  Map<String, dynamic>? stripeIntentPaymentData;
  bool _googlePaySupported = false;

  @override
  Widget build(BuildContext context) {
    clubName = Provider.of<ClubGlobalProvider>(context).clubName;

    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive font size (19 is the base size)
    double responsiveFontSize = screenWidth * 0.05; // 5% of screen width
    responsiveFontSize = responsiveFontSize.clamp(16.0, 24.0); // Min and max bounds

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Payment Plans for $clubName',
            style: GoogleFonts.poppins(
              // Using Poppins from Google Fonts
              color: Colors.black,
              fontSize: responsiveFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // This will pop the current screen and return to the previous one
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubPaymentHistoryPage(clubId: widget.clubId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _pricingRef.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Center(child: Text('No pricing data available'));
            }

            final pricingData = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
            final pricing = PlanPricing.fromRTDB(pricingData);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildToggleSwitch(),
                    const SizedBox(height: 30),
                    _buildPlans(pricing),
                    if (_googlePaySupported)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "✓ Google Pay Available",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializePricing();
    _pricingRef = FirebaseDatabase.instance.ref('thegfa_pricing/${widget.clubId}');
    checkPaymentMethodAvailability();
  }

  Future<void> checkPaymentMethodAvailability() async {
    if (Platform.isAndroid) {
      final googlePaySupported = await Stripe.instance.isPlatformPaySupported();
      setState(() {
        _googlePaySupported = googlePaySupported;
      });
    }
  }

  Future<void> _initializePricing() async {
    try {
      final snapshot = await _pricingRef.get();
      if (!snapshot.exists) {
        // Set default pricing if no data exists
        await _pricingRef.set({
          'standardMonthly': 29,
          'advancedMonthly': 59,
          'standardAnnual': 290,
          'advancedAnnual': 590,
          'standardAnnualDiscount': 50,
          'advancedAnnualDiscount': 100,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing pricing: $e');
      }
    }
  }

  // Stripe Payment Methods
  Future<String?> createOrGetStripeCustomer() async {
    try {
      Map<String, dynamic> customerData = {
        "description": "FC Customer: ${widget.clubId}",
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {"Authorization": "Bearer $secretStripeKey", "Content-Type": "application/x-www-form-urlencoded"},
        body: customerData,
      );

      var customerJson = jsonDecode(response.body);
      return customerJson['id'];
    } catch (e) {
      if (kDebugMode) {
        print('Error creating/getting Stripe customer: $e');
      }
      return null;
    }
  }

  makeStripeIntentForPayment(String amountToBeCharged, String currency, String customerId, bool isFirstTime, String clubName,
      {bool isSubscription = false}) async {
    try {
      if (isSubscription) {
        // Subscription flow
        // Create a subscription price first (if it doesn't exist)
        final priceResponse = await http.post(
          Uri.parse('https://api.stripe.com/v1/prices'),
          headers: {
            "Authorization": "Bearer $secretStripeKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: {
            "unit_amount": (int.parse(amountToBeCharged) * 100).toString(),
            "currency": currency,
            "recurring[interval]": "month",
            "product_data[name]": clubName,
          },
        );

        final priceData = jsonDecode(priceResponse.body);

        // Create a subscription
        Map<String, dynamic> subscriptionData = {
          "customer": customerId,
          "items[0][price]": priceData['id'],
          "payment_behavior": "default_incomplete",
          "payment_settings[save_default_payment_method]": "on_subscription",
          "expand[]": "latest_invoice.payment_intent",
        };

        // Add trial period for first-time users
        if (isFirstTime) {
          subscriptionData["trial_period_days"] = "30"; // First month free
        }

        final subscriptionResponse = await http.post(
          Uri.parse('https://api.stripe.com/v1/subscriptions'),
          headers: {
            "Authorization": "Bearer $secretStripeKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: subscriptionData,
        );

        final subscription = jsonDecode(subscriptionResponse.body);
        return subscription['latest_invoice']['payment_intent'];
      } else {
        // One-time payment flow
        Map<String, dynamic> paymentInfo = {
          "amount": (int.parse(amountToBeCharged) * 100).toString(),
          "currency": currency,
          "customer": customerId,
          "setup_future_usage": "off_session",
          "payment_method_types[0]": "card",
          "payment_method_types[1]": "paypal",
          "payment_method_types[2]": "bacs_debit",
        };

        var responseFromStripeAPI = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: paymentInfo,
          headers: {
            "Authorization": "Bearer $secretStripeKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        );

        if (kDebugMode) {
          print('Response from Stripe API = ${responseFromStripeAPI.body}');
        }

        final response = jsonDecode(responseFromStripeAPI.body);

        if (response['error'] != null) {
          throw Exception(response['error']['message']);
        }

        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<bool> checkFirstTimeSubscriber(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/subscriptions?customer=$customerId'),
        headers: {
          "Authorization": "Bearer $secretStripeKey",
        },
      );

      final data = jsonDecode(response.body);
      return data['data'].isEmpty; // True if no previous subscriptions
    } catch (e) {
      if (kDebugMode) {
        print('Error checking subscription history: $e');
      }
      return true; // Assume first time in case of error
    }
  }

  stripePaymentSheetInitialization(amountToBeCharged, currency) async {
    try {
      String? stripeCustomerId = await createOrGetStripeCustomer();
      if (stripeCustomerId == null) {
        throw Exception('Failed to create/get Stripe customer');
      }

      final clubName = widget.clubId; // Replace with actual club name fetch

      // Check if the customer is subscribing for the first time
      final isFirstTime = await checkFirstTimeSubscriber(stripeCustomerId);

      final stripeIntentPaymentData = await makeStripeIntentForPayment(amountToBeCharged, currency, stripeCustomerId, isFirstTime, clubName);

      if (stripeIntentPaymentData['client_secret'] == null) {
        throw Exception('No client secret received from Stripe');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: stripeCustomerId,
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: stripeIntentPaymentData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Nouvellesoft Inc.",
          returnURL: "your-app-scheme://stripe-redirect",
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: kDebugMode,
          ),
          // billingDetails: BillingDetails(
          //   name: clubName, // Show club name in billing details
          // ),
          customFlow: false,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                ),
              ),
            ),
          ),
          // metadata: {
          //   'club_id': widget.clubId,
          //   'club_name': clubName,
          // },
        ),
      );

      await showStripePaymentSheet();
    } catch (e, s) {
      if (kDebugMode) {
        print('Error: $e\nStack trace: $s');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment setup failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _savePaymentToFirestore(String paymentIntentId, double amount, String currency) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('PaymentHistory').add({
        'paymentIntentId': paymentIntentId,
        'amount': amount,
        'currency': currency,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'succeeded',
        'planType': selectedPlanIndex == 0 ? 'Standard' : 'Advanced',
        'period': isMonthly ? 'Monthly' : 'Annual',
        'paymentMethod': 'card', // You can update this based on the actual payment method used
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving payment to Firestore: $e');
      }
    }
  }

  showStripePaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Save payment record to Firestore
        if (stripeIntentPaymentData != null) {
          _savePaymentToFirestore(
            stripeIntentPaymentData!['id'],
            double.parse(stripeIntentPaymentData!['amount'].toString()) / 100,
            stripeIntentPaymentData!['currency'],
          );
        }

        stripeIntentPaymentData = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')),
        );
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print('Error: $error\nStack trace: $stackTrace');
        }
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(error.error.localizedMessage ?? "Payment cancelled"),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton('Monthly', isMonthly),
            _buildToggleButton('Annual', !isMonthly),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMonthly = text == 'Monthly';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlans(PlanPricing pricing) {
    // Add pricing parameter
    return Column(
      children: [
        _buildPlanCard(
            'Standard',
            isMonthly ? pricing.standardMonthly : pricing.standardAnnual, // Use pricing object
            standardFeatures,
            Colors.blue,
            0,
            pricing),
        const SizedBox(height: 20),
        _buildPlanCard(
            'Advanced',
            isMonthly ? pricing.advancedMonthly : pricing.advancedAnnual, // Use pricing object
            advancedFeatures,
            Colors.deepOrange[600]!,
            1,
            pricing),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    double price,
    List<Map<String, dynamic>> features,
    Color accentColor,
    int index,
    PlanPricing pricing,
  ) {
    bool isSelected = selectedPlanIndex == index;
    // Calculate discounted price for annual plans
    // double discountedPrice = !isMonthly ? price * 0.8 : price; // 20% discount for annual

    // Calculate discounted price for annual plans
    double discountedPrice = !isMonthly ? price - (title == 'Standard' ? pricing.standardAnnualDiscount : pricing.advancedAnnualDiscount) : price;
    // Calculate discount percentage
    double discountPercentage = !isMonthly ? ((price - discountedPrice) / price * 100) : 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? accentColor : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isMonthly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Text(
                '🎉 First Month Free!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          InkWell(
            onTap: () {
              setState(() {
                selectedPlanIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: accentColor,
                          size: 28,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isMonthly)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Then ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '£${price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                  Text(
                                    '/month',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else // Annual pricing display (remains the same)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '£${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        Text(
                          'Save ${discountPercentage.toStringAsFixed(0)}% '
                          '(£${title == 'Standard' ? pricing.standardAnnualDiscount.toStringAsFixed(0) : pricing.advancedAnnualDiscount.toStringAsFixed(0)} off)',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '£${discountedPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              TextSpan(
                                text: '/year',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  ...features.map((feature) => _buildFeatureItem(feature['title'])),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        handlePlanSelection(
                          title, // 'Standard' or 'Advanced'
                          price,
                          discountedPrice,
                        );

                        // Calculate the correct amount based on the plan and billing period
                        // final amount = isMonthly ? price : discountedPrice;
                        // stripePaymentSheetInitialization(amount.round().toString(), "GBP");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Choose Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 14,
            height: MediaQuery.of(context).size.width / 14,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Color.fromRGBO(30, 34, 35, 0.7215686274509804)),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.gg,
                color: Color.fromRGBO(137, 204, 162, 1.0),
                size: 16,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> standardFeatures = [
    {'title': 'Up to 3 projects', 'included': true},
    {'title': 'Basic analytics', 'included': true},
    {'title': 'Unlimited users', 'included': true},
    {'title': '30-days support', 'included': true},
  ];

  final List<Map<String, dynamic>> advancedFeatures = [
    {'title': 'Unlimited projects', 'included': true},
    {'title': 'Advanced analytics', 'included': true},
    {'title': 'Priority support', 'included': true},
    {'title': 'Custom integrations', 'included': true},
    {'title': 'Team collaboration', 'included': true},
  ];

  Future<void> handlePlanSelection(
    String planType,
    double price,
    double discountedPrice,
  ) async {
    try {
      // Determine final amount and subscription details
      final bool isFirstTimeSubscriber = await checkFirstTimeSubscriber(await createOrGetStripeCustomer() ?? '');
      final amount = isMonthly ? price : discountedPrice;

      // Store the current plan details for use after successful payment
      final planDetails = {
        'club_id': widget.clubId,
        'plan_type': planType,
        'period': isMonthly ? 'Monthly' : 'Annual',
        'is_trial': isFirstTimeSubscriber && isMonthly,
        'amount': amount,
      };

      // For monthly plans with first month free trial
      // if (isMonthly && isFirstTimeSubscriber) { using dummy below instead since I'm not sure whats going on yet
      if (/**isMonthly && isFirstTimeSubscriber */ amount == 0.00) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Start Your Free Trial'),
              content: Text('You\'ll get your first month free! After the trial period, '
                  'you\'ll be charged £${amount.toStringAsFixed(2)} per month for the '
                  '${planType.toLowerCase()} plan.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _initializePaymentWithTrial(
                      amount.round().toString(),
                      "GBP",
                      planDetails,
                      true, // isSubscription
                      true, // isFirstTime
                    );
                  },
                  child: Text('Start Trial'),
                ),
              ],
            );
          },
        );
      } else {
        _initializePaymentWithTrial(
          amount.round().toString(),
          "GBP",
          planDetails,
          isMonthly, // isSubscription only for monthly plans
          false, // isFirstTime
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling plan selection: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: ${e.toString()}')),
      );
    }
  }

  Future<void> _initializePaymentWithTrial(
    String amount,
    String currency,
    Map<String, dynamic> planDetails,
    bool isSubscription,
    bool isFirstTime,
  ) async {
    try {
      String? stripeCustomerId = await createOrGetStripeCustomer();
      if (stripeCustomerId == null) {
        throw Exception('Failed to create/get Stripe customer');
      }

      final stripeData = await makeStripeIntentForPayment(
        amount,
        currency,
        stripeCustomerId,
        isFirstTime,
        widget.clubId,
        isSubscription: isSubscription,
      );

      // Store plan details for use after successful payment
      setState(() {
        stripeIntentPaymentData = {
          ...stripeData,
          'planDetails': planDetails,
        };
      });

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: stripeCustomerId,
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: stripeData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Nouvellesoft Inc.",
          returnURL: "your-app-scheme://stripe-redirect",
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: kDebugMode,
          ),
          customFlow: false,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await showStripePaymentSheet();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing payment: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment setup failed: ${e.toString()}')),
      );
    }
  }
}
