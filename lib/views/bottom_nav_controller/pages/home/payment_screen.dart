import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tour_app/constant/constant.dart';
import 'package:flutter_tour_app/services/firestore_services.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/card_holder_findding.dart';
import 'package:flutter_tour_app/views/bottom_nav_controller/pages/home/otp_verification.dart';
import 'package:pay/pay.dart'; // Replace with the correct import path
import 'package:http/http.dart' as http;

import 'package:flutter_stripe/flutter_stripe.dart';
import 'payment_configurations.dart' as payment_configurations;
const _paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '99.99',
    status: PaymentItemStatus.final_price,
  )
];

class PaymentScreen extends StatefulWidget {
  final String orderId;

  PaymentScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  late final Future<PaymentConfiguration> _googlePayConfigFuture;
  int step = 0;
  @override
  void initState() {
    super.initState();
    initPaymentSheet();
    _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('default_google_pay_config.json');
        initPaymentSheet();
          }

  void onGooglePayResult(paymentResult) {
         Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardHolderFindingScreen(orderId: widget.orderId),
                      ),
                    );

    debugPrint(paymentResult.toString());
  }

  void onApplePayResult(paymentResult) {
         Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardHolderFindingScreen(orderId: widget.orderId),
                      ),
                    );

    debugPrint(paymentResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error fetching order info'));
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('Order not found'));
                        } else {
                          var orderData = snapshot.data!.data() as Map<String, dynamic>;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderData['product_name'] ?? 'Product Name',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Amount: ₹${orderData['product_price'] ?? '0'}',
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${orderData['status'] ?? 'Pending'}',
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Created At: ${orderData['createdAt']?.toDate().toString() ?? 'Not available'}',
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Product Link: ${orderData['product_url'] ?? 'Not available'}',
                                style: const TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹${orderData['amount']}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Methods Section
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              PaymentMethodTile(
                icon: Icons.credit_card,
                title: 'GPay',
                onTap: () {
                  // Handle card payment
                  showSnackbar(context, 'Selected Credit/Debit Card');
                },
              ),
              const SizedBox(height: 20),

              // Address and Phone Fields
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter delivery address',
                  labelText: 'Address',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
                Row(
                children: [
                  Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: 'Enter phone number',
                    labelText: 'Phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        ListTile(
                          leading: const Icon(Icons.cancel),
                          title: const Text('Cancel'),
                          onTap: () {
                          Navigator.pop(context);
                          },
                        ),
                        OTPVerificationScreen(phoneNumber: _phoneController.text)
                        ],
                      ),
                      );
                    },
                    );
                  },
                  child: const Text('Verify'),
                  ),
                     ElevatedButton(
                  onPressed: () {
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OTPVerificationScreen(phoneNumber: _phoneController.text),
  ),
);

                  },
                  child: const Text('Verify1'),
                  ),
                ],
                ),
              const SizedBox(height: 20),
                 Center(
                child: ElevatedButton(
                  onPressed: () async {
                  confirmPayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'PAYMENT',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              kIsWeb?
              // Confirm Payment Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String buyerAddress = _addressController.text;
                    String buyerPhone = _phoneController.text;

                    // Update Firestore with buyer details
                    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
                      'buyer_address': buyerAddress,
                      'buyer_phone': buyerPhone,
                      'available': true
                    });


                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardHolderFindingScreen(orderId: widget.orderId),
                      ),
                    );

                    // Handle payment confirmation
                    showSnackbar(context, 'Payment Confirmed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'PAYMENT',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ):
                       // Example pay button configured using an asset
          FutureBuilder<PaymentConfiguration>(
              future: _googlePayConfigFuture,
              builder: (context, snapshot) => snapshot.hasData
                  ? GooglePayButton(
                      paymentConfiguration: snapshot.data!,
                      paymentItems: _paymentItems,
                      type: GooglePayButtonType.buy,
                      margin: const EdgeInsets.only(top: 15.0),
                      onPaymentResult: onGooglePayResult,
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink()),
          // Example pay button configured using a string
          ApplePayButton(
            paymentConfiguration: payment_configurations.defaultApplePayConfig,
            paymentItems: _paymentItems,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: onApplePayResult,
            loadingIndicator: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
            ApplePayButton(
            paymentConfiguration: payment_configurations.defaultApplePayConfig,
            paymentItems: _paymentItems,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: onApplePayResult,
            loadingIndicator: const Center(
              child: CircularProgressIndicator(),
            )),
           Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String buyerAddress = _addressController.text;
                    String buyerPhone = _phoneController.text;

                    // Update Firestore with buyer details
                    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
                      'buyer_address': buyerAddress,
                      'buyer_phone': buyerPhone,
                      'available': true
                    });


                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardHolderFindingScreen(orderId: widget.orderId),
                      ),
                    );

                    // Handle payment confirmation
                    showSnackbar(context, 'Payment Confirmed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'PAYMENT LATER',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              CardField(
          onCardChanged: (card) {
            print(card);
          },
        ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<Map<String, dynamic>> _createTestPaymentSheet() async {
  final url = Uri.parse('http://192.168.1.154:3000/create-payment-intent');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
   
    );

    // Check if the response status is OK (200)
    print(response);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
      // If the API response contains an 'error', throw an exception
      if (body['error'] != null) {
        throw Exception(body['error']);
      }

      // Return the body if no errors are found
      return body;
    } else {
      // Handle error based on the response status code
      throw Exception('Failed to create payment intent: ${response.statusCode}');
    }
  } catch (e) {
    // Catch and print any exceptions
    print('Error: $e');
    rethrow;  // Re-throw the exception if needed
  }
}
  Future<void> initPaymentSheet() async {
    // final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // 1. create payment intent on the server
      final data = await _createTestPaymentSheet();

      // create some billingdetails
      final billingDetails = BillingDetails(
        name: 'Flutter Stripe',
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Flutter Stripe Store Demo',
          preferredNetworks: [CardBrand.Amex],
          // Customer params
          customerId: data['customer'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          returnURL: 'flutterstripe://redirect',

          // Extra params
          primaryButtonLabel: 'Pay now',
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'DE',
          ),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'DE',
            testEnv: true,
            buttonType: PlatformButtonType.book,
          ),
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.lightBlue,
              primary: Colors.blue,
              componentBorder: Colors.red,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: Colors.red),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color.fromARGB(255, 231, 235, 30),
                  text: Color.fromARGB(255, 235, 92, 30),
                  border: Color.fromARGB(255, 235, 92, 30),
                ),
              ),
            ),
          ),
          billingDetails: billingDetails,
        ),
      );
      setState(() {
        step = 1;
      });
    } catch (e) {
      if (context.mounted) {
        // scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        step = 0;
      });

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Payment successfully completed'),
          ),
        );
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        }
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Unforeseen error: $e'),
            ),
          );
        }
      }
    }
  }
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}

class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PaymentMethodTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
