import 'package:flutter_dotenv/flutter_dotenv.dart';

String? publishableStripeKey = dotenv.env['PUBLISHABLE_STRIPE_KEY'];
String? secretStripeKey = dotenv.env['SECRET_STRIPE_KEY'];
