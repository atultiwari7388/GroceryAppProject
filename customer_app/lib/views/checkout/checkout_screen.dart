import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:logger/logger.dart';
import '../../common/dashed_divider.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';
import '../../functions/inc_dec.dart';
import '../../services/collection_ref.dart';
import '../../utils/app_style.dart';
import '../../utils/toast_msg.dart';
import '../address/address_management_screen.dart';
import '../success/success_screen.dart';
import 'checkout_functionality.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  final TextEditingController _couponController = TextEditingController();
  bool isCouponApplied = false;
  num totalBill = 0.0;
  num baseToTalBill = 0;
  num subtotal = 0.0;
  num discValue = 0.0;
  num discountAmount = 0;
  num gstAmountPrice = 0;
  String? address;
  String? time;
  String? addreeType;
  String? name;
  String? phoneNumber;
  double? userLat;
  double? userLong;
  String selectedPaymentMethod = "Select Payment Mode";
  String razorpayApiKey = "";
  num minimuOrderValue = 0;
  num lessOrderValue = 0;
  num deliveryCharges = 0;
  num gstCharges = 0;
  bool isApiKeyLoading = false;
  late Razorpay _razorpay;
  bool isDeliveryChargesApplied = false;
  bool isPlacingOrder = false;
  num calculatedTotalBill = 0;
  num discountValue = 0;
  var logger = Logger();
  num finalTimeAfterAdding10 = 0;
  // bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    fetchApiKey();
    fetchMinimumOrderValue();
    fetchLessOrderValue();
    fetchDeliveryChargesValue();
    fetchGstChargesValue();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    WidgetsBinding.instance.addObserver(this);
    calculateTotalBill();
  }

//================== Razor pay paement gateway =========================

  void openRazorpayCheckout(totalBill) {
    var options = {
      'key': razorpayApiKey,
      'amount': (totalBill * 100).toInt(),
      'name': 'FoodOTG',
      'description': 'Order Payment',
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser!.phoneNumber,
        'email': FirebaseAuth.instance.currentUser!.email,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      logger.d(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    showToastMessage("Success", "Payment Successful", Colors.green);
    logger.d(response.paymentId.toString());
    logger.d(response.orderId.toString());
    logger.d(response.signature.toString());
    placeOrderLogic(
        paymentMode: "online", paymentId: response.paymentId.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showToastMessage("Payment Fail", response.message.toString(), Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToastMessage(
        "External Wallet Error", response.walletName.toString(), Colors.red);
  }

//================== Fetch Api Key =====================
  Future<void> fetchApiKey() async {
    setState(() {
      isApiKeyLoading = true;
    });
    try {
      // Access the 'settings' collection and 'razorpayKey' document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('settings')
          .doc('razorpayKey')
          .get();

      // Get the 'key' field from the document
      String apiKey = snapshot.data()?['key'];

      // Set the apiKey to the class variable
      setState(() {
        razorpayApiKey = apiKey;
        logger.d("RazorPayApiKey set to $razorpayApiKey");
        isApiKeyLoading = false;
      });
    } catch (error) {
      setState(() {
        isApiKeyLoading = true;
      });
      // Handle any errors that occur during the process
      logger.d("Error fetching API key: $error");
    }
  }

//================== Fetch Minimum Order Key =====================
  Future<void> fetchMinimumOrderValue() async {
    setState(() {
      isApiKeyLoading = true;
    });
    try {
      // Access the 'settings' collection and 'razorpayKey' document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('settings')
          .doc('minimumOrder')
          .get();

      // Get the 'key' field from the document
      num minValue = snapshot.data()?['value'];

      // Set the apiKey to the class variable
      setState(() {
        minimuOrderValue = minValue;
        logger.d("minimum Order value set to $minimuOrderValue");
        isApiKeyLoading = false;
      });
    } catch (error) {
      setState(() {
        isApiKeyLoading = true;
      });
      // Handle any errors that occur during the process
      logger.d("Error fetching API key: $error");
    }
  }

//================== Fetch Minimum Order Key =====================
  Future<void> fetchLessOrderValue() async {
    setState(() {
      isApiKeyLoading = true;
    });
    try {
      // Access the 'settings' collection and 'razorpayKey' document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('settings')
          .doc('orderLessThen')
          .get();

      // Get the 'key' field from the document
      num minValue = snapshot.data()?['value'];

      // Set the apiKey to the class variable
      setState(() {
        lessOrderValue = minValue;
        logger.d("LessOrder Value set to $lessOrderValue");
        isApiKeyLoading = false;
      });
    } catch (error) {
      setState(() {
        isApiKeyLoading = true;
      });
      // Handle any errors that occur during the process
      logger.d("Error fetching API key: $error");
    }
  }

//================== Fetch Minimum Order Key =====================
  Future<void> fetchDeliveryChargesValue() async {
    setState(() {
      isApiKeyLoading = true;
    });
    try {
      // Access the 'settings' collection and 'razorpayKey' document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('settings')
          .doc('deliveryCharges')
          .get();

      // Get the 'key' field from the document
      num minValue = snapshot.data()?['value'];

      // Set the apiKey to the class variable
      setState(() {
        deliveryCharges = minValue;
        logger.d("DeliveryCharges Value set to $deliveryCharges");
        isApiKeyLoading = false;
      });
    } catch (error) {
      setState(() {
        isApiKeyLoading = true;
      });
      // Handle any errors that occur during the process
      logger.d("Error fetching API key: $error");
    }
  }

  Future<void> fetchGstChargesValue() async {
    setState(() {
      isApiKeyLoading = true;
    });
    try {
      // Access the 'settings' collection and 'razorpayKey' document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('settings')
          .doc('gstCharges')
          .get();

      // Get the 'key' field from the document
      num minValue = snapshot.data()?['value'];

      // Set the apiKey to the class variable
      setState(() {
        gstCharges = minValue;
        logger.d("Gst Charges Value set to $gstCharges");
        isApiKeyLoading = false;
      });
    } catch (error) {
      setState(() {
        isApiKeyLoading = true;
      });
      // Handle any errors that occur during the process
      logger.d("Error fetching API key: $error");
    }
  }

  void calculateTotalBill() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUId)
        .collection("cart")
        .get()
        .then((cartSnapshot) {
      if (cartSnapshot.docs.isNotEmpty) {
        double initialTotalBill = cartSnapshot.docs.fold(
            0.0,
            (previousValue, cartItem) =>
                previousValue + cartItem["quantityPrice"]);

        // Find the highest time value
        double maxTime = cartSnapshot.docs.fold(
            0.0,
            (previousValue, cartItem) =>
                max(previousValue, double.parse(cartItem["time"] ?? "0")));

        setState(() {
          time = maxTime.toStringAsFixed(0);
          finalTimeAfterAdding10 = int.parse(time!) + 10;
          baseToTalBill = initialTotalBill;
          totalBill = initialTotalBill;
          subtotal = initialTotalBill;
          // calculatedTotalBill = initialTotalBill;
          logger.d("TotalBill set to $totalBill");
          logger.d("Base TotalBill set to $totalBill");
          logger.d("Subtotal set to $subtotal");
          logger.d("Time is set to $time");

          if (totalBill < lessOrderValue) {
            totalBill += deliveryCharges;
            totalBill = calculatedTotalBill;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      deleteCoupon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        deleteCoupon();
        return true; // Return true to allow the pop navigation
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              deleteCoupon();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          iconTheme: const IconThemeData(color: kDark),
          title: ReusableText(
              text: "Checkout", style: appStyle(18, kDark, FontWeight.normal)),
        ),
        body: isApiKeyLoading
            ? const Center(child: CircularProgressIndicator())
            : isPlacingOrder
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //top section dynamic product
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(currentUId)
                              .collection("cart")
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            // Check if cart is empty
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('Your cart is empty'));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (ctx, index) {
                                final food = snapshot.data!.docs[index];
                                final foodId = food.id;
                                // resIds = food["resId"];
                                final Map<String, dynamic> selectedAddOns =
                                    food["selectedAddOnsPrice"];
                                final List<dynamic> selectedAddOnsName =
                                    food["selectedAddOns"];

                                final num selectedSizePrice =
                                    food["selectedSizePrice"];
                                final String selectedSize =
                                    food["selectedSize"] ?? "";

                                return buildProductCard(
                                    food,
                                    foodId,
                                    selectedAddOns,
                                    selectedAddOnsName,
                                    selectedSizePrice,
                                    selectedSize);
                              },
                            );
                          },
                        ),

                        SizedBox(height: 7.h),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15.w, top: 8.h, bottom: 5.h),
                          child: ReusableText(
                              text: "Apply Coupon",
                              style: appStyle(15, kDark, FontWeight.normal)),
                        ),
                        //here lets create coupon section
                        SizedBox(height: 10.h),
                        buildCouponSection(_couponController),
                        SizedBox(height: 10.h),
                        //delivery time , delivery address, and contact name and number, and total bill
                        buildDeliveryTimeAddressSection(),
                        // SizedBox(height: 10.h),
                        buildPrivacyPolicy(),
                      ],
                    ),
                  ),
        bottomNavigationBar: isApiKeyLoading
            ? const Center(child: CircularProgressIndicator())
            // : totalBill < minimuOrderValue
            //     ?

            // :  Container(
            //       height: 80.h,
            //       width: double.maxFinite,
            //       color: kWhite,
            //       margin: EdgeInsets.fromLTRB(7.w, 2.h, 10.w, 5.h),
            //       padding: EdgeInsets.all(10.h),
            //       child: const Center(
            //         child: Text(
            //           "Minimum order should be ₹100",
            //           style: TextStyle(color: Colors.red),
            //         ),
            //       ),
            //     )
            : Container(
                height: 80.h,
                width: double.maxFinite,
                color: kWhite,
                margin: EdgeInsets.fromLTRB(7.w, 2.h, 10.w, 5.h),
                padding: EdgeInsets.all(10.h),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PopupMenuButton(
                          initialValue: "Please Select Pyament options",
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "online",
                              child: Text("Online Payment"),
                            ),
                            PopupMenuItem(
                              value: "cash",
                              child: Text("Cash on Delivery"),
                            ),
                          ],
                          onSelected: (value) {
                            // Update the selected payment method and rebuild the UI
                            setState(() {
                              selectedPaymentMethod = value;
                            });
                          },
                          child: Row(
                            children: [
                              ReusableText(
                                text: selectedPaymentMethod,
                                style: appStyle(12, kGray, FontWeight.normal),
                              ),
                              Icon(
                                Icons.arrow_drop_up,
                                color: kGray,
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    selectedPaymentMethod == "Select Payment Mode"
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              // Show a message when the button is disabled
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("First select the payment mode"),
                                ),
                              );
                            },
                            child: Text("Place order",
                                style: appStyle(13, kDark, FontWeight.normal)))
                        : Container(
                            height: 45.h,
                            // width: 140.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  kPrimary,
                                  kPrimary,
                                  kPrimary,
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  selectedPaymentMethod == "Select Payment Mode"
                                      ? null
                                      : () {
                                          if (selectedPaymentMethod == "cash") {
                                            placeOrderLogic(
                                                paymentMode: "cash",
                                                paymentId: "");
                                          } else if (selectedPaymentMethod ==
                                              "online") {
                                            if (totalBill < lessOrderValue) {
                                              totalBill += deliveryCharges;
                                              openRazorpayCheckout(totalBill);
                                            }
                                          }
                                        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text("Place Order",
                                  style: appStyle(16, kWhite, FontWeight.w500)),
                            ),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  void placeOrderLogic(
      {required String paymentMode, required String paymentId}) {
    setState(() {
      isPlacingOrder = true;
    });
    // Retrieve user's location from Firestore
    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUId)
        .collection("Addresses")
        .where("isAddressSelected", isEqualTo: true)
        .get()
        .then((userAddressSnapshot) {
      // Extract user's latitude and longitude
      if (userAddressSnapshot.docs.isNotEmpty) {
        userAddressSnapshot.docs.forEach((addressDoc) {
          double userLatitude = addressDoc.data()['location']['latitude'];
          double userLongitude = addressDoc.data()['location']['longitude'];
          // Iterate through each restaurant document

          placeOrder(
            address!,
            name!,
            phoneNumber!,
            paymentMode,
            "",
            userLatitude,
            userLongitude,

            calculatedTotalBill,
            //subtotoal
            subtotal,
            gstCharges,
            discountAmount,
            discountValue,
            _couponController.text.toString(),
            paymentId,
            isDeliveryChargesApplied ? deliveryCharges : 0,
            gstAmountPrice,
            time.toString(),
            // orderList,
          ).then((value) {
            setState(() {
              isPlacingOrder = true; // Show loading indicator
            });
            Get.offAll(() => const SuccessScreen(),
                transition: Transition.cupertino,
                duration: const Duration(milliseconds: 900));
          }).catchError((error) {
            setState(() {
              isPlacingOrder = false; // Hide loading indicator on error
            });

            // Show error message
            showToastMessage(
                "Order Placement Failed", error.toString(), Colors.red);
          });
        });
      } else {
        setState(() {
          isPlacingOrder = false; // Hide loading indicator if no address found
        });

        showToastMessage("Error", "No address selected", Colors.red);
      }
    }).catchError((error) {
      setState(() {
        isPlacingOrder = false; // Hide loading indicator on error
      });

      showToastMessage("Error", error.toString(), Colors.red);
    });
  }

  //=================== Build Privacy policy =================
  Container buildPrivacyPolicy() {
    return Container(
      margin: EdgeInsets.fromLTRB(7.w, 2.h, 10.w, 5.h),
      padding: EdgeInsets.all(10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
              text: "CANCELLATION POLICY",
              style: appStyle(14, kGray, FontWeight.normal)),
          SizedBox(
            width: 340.w,
            child: Text(
                "Help us reduce food waste by avoiding cancellations after placing your order. A 100% cancellation fee will be applied.",
                style: appStyle(11, kGray, FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchSelectedAddress(String userId) async {
    QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .collection("Addresses")
        .where("isAddressSelected", isEqualTo: true)
        .get();
    if (addressSnapshot.docs.isNotEmpty) {
      return addressSnapshot.docs.first.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchUserAndAddressData(String userId) async {
    Map<String, dynamic> userData = await fetchUserData(userId);
    Map<String, dynamic> addressData = await fetchSelectedAddress(userId);
    userData.addAll(addressData);
    return userData;
  }

  Container buildDeliveryTimeAddressSection() {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 5.h),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: FutureBuilder(
        future: fetchUserAndAddressData(currentUId),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No address found'));
          }

          var userData = snapshot.data!;
          address = userData["address"];
          addreeType = userData["addressType"];
          name = userData["userName"];
          phoneNumber = userData["phoneNumber"];
          userLat = userData["location"]["latitude"];
          userLong = userData["location"]["longitude"];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //--------- delivery section ------------
              Row(
                children: [
                  Image.asset("assets/timer_clock.png",
                      height: 25.h, width: 25.w),
                  SizedBox(width: 10.w),
                  RichText(
                    text: TextSpan(
                      text: "Delivery in ",
                      style: appStyle(13, kDark, FontWeight.normal),
                      children: [
                        TextSpan(
                            text:
                                "${finalTimeAfterAdding10.toStringAsFixed(0)} mins",
                            style: appStyle(13, kDark, FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              const DashedDivider(height: 1, color: kGrayLight),
              SizedBox(height: 15.h),

              //--------- Address section ------------
              Row(
                children: [
                  Image.asset("assets/house.png", height: 25.h, width: 25.w),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Delivery at ",
                          style: appStyle(13, kDark, FontWeight.normal),
                          children: [
                            TextSpan(
                                text: "$addreeType",
                                style: appStyle(13, kDark, FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 220.w,
                        child: Text("$address",
                            maxLines: 2,
                            style: appStyle(12, kGrayLight, FontWeight.normal)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () async {
                        var result = await Get.to(() => AddressManagementScreen(
                              userLat: userLat!,
                              userLng: userLong!,
                            ));
                        if (result != null) {
                          setState(() {
                            address = result["address"];
                            userLat = result["location"]["latitude"];
                            userLong = result["location"]["longitude"];
                          });
                        }
                      },
                      icon: Icon(Icons.arrow_forward_ios, size: 20.sp))
                ],
              ),

              SizedBox(height: 15.h),
              const DashedDivider(height: 1, color: kGrayLight),
              SizedBox(height: 15.h),
              //------------ Contact Section --------------
              Row(
                children: [
                  Image.asset("assets/phone-call.png",
                      height: 25.h, width: 25.w),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "$name",
                          style: appStyle(13, kDark, FontWeight.normal),
                          children: [
                            TextSpan(
                                text: "$phoneNumber",
                                style: appStyle(13, kDark, FontWeight.bold)),
                          ],
                        ),
                      ),
                      ReusableText(
                          text: "Cannot be changed for this order",
                          style: appStyle(12, kGrayLight, FontWeight.normal)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios, size: 20.sp))
                ],
              ),
              SizedBox(height: 15.h),
              const DashedDivider(height: 1, color: kGrayLight),
              SizedBox(height: 15.h),

              //------------ Bill Section --------------
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUId)
                    .collection("cart")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> cartSnapshot) {
                  if (cartSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (cartSnapshot.hasError) {
                    return Text('Error: ${cartSnapshot.error}');
                  }

                  // Calculate total bill
                  calculatedTotalBill = cartSnapshot.data!.docs.fold(0,
                      (previousValue, cartItem) {
                    discValue = cartItem["discountAmount"] ?? 0.0;
                    // time =
                    //     cartItem["time"] ?? "0"; //for storing the delivery time

                    if (isCouponApplied) {
                      return cartItem["totalPrice"];
                    } else {
                      return previousValue + cartItem["totalPrice"];
                    }
                  });

                  // Calculate subtotal from subTotalPrice
                  num calculatedSubTotal = cartSnapshot.data!.docs.fold(0.0,
                      (previousValue, cartItem) {
                    return previousValue + cartItem["subTotalPrice"];
                  });
                  subtotal = calculatedSubTotal.toInt();
                  totalBill = calculatedTotalBill;

                  // Calculate GST
                  gstAmountPrice = (gstCharges / 100) * subtotal.toDouble();

                  totalBill = calculatedTotalBill + gstAmountPrice;
                  // bool isDeliveryChargesApplied = false;

                  if (calculatedTotalBill < lessOrderValue) {
                    totalBill += deliveryCharges;
                    calculatedTotalBill += deliveryCharges + gstAmountPrice;
                    isDeliveryChargesApplied = true;
                  } else {
                    calculatedTotalBill += gstAmountPrice;
                    isDeliveryChargesApplied = false;
                  }

                  if (isCouponApplied) {
                    if (baseToTalBill < lessOrderValue) {
                      totalBill =
                          baseToTalBill += deliveryCharges + gstAmountPrice;
                    }
                  } else {
                    totalBill = calculatedTotalBill;
                  }
                  logger.d("GST Amount calculated as $gstAmountPrice");
                  logger.d("Total Bill :$totalBill");
                  logger.d("SubTotal Bill: $subtotal");
                  logger.d("Discount Value: $discValue");
                  logger.d("Calculated Total Bill : $calculatedTotalBill");

                  return Container(
                    // margin: EdgeInsets.all(2.h),
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          kTertiary.withOpacity(0.1),
                          kTertiary.withOpacity(0.1),
                          kTertiary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      children: [
                        reusbaleRowTextWidget("SubTotal :",
                            "₹${subtotal.round().toStringAsFixed(2)}", kDark),

                        SizedBox(height: 3.h),
                        isDeliveryChargesApplied
                            ? reusbaleRowTextWidget(
                                "Delivery Charges  :",
                                "₹${deliveryCharges.round().toStringAsFixed(2)}",
                                kTertiary)
                            : reusbaleRowTextWidget(
                                "Delivery Charges  :", "0", kTertiary),
                        SizedBox(height: 3.h),
                        reusbaleRowTextWidget(
                            "GST($gstCharges%)  :",
                            "₹${gstAmountPrice.round().toStringAsFixed(2)}",
                            kDark),
                        SizedBox(height: 3.h),
                        isCouponApplied
                            ? reusbaleRowTextWidget(
                                "Discounts ($discountValue%) :",
                                "-₹${discValue.round().toStringAsFixed(2)}",
                                const Color.fromARGB(255, 11, 95, 2))
                            : reusbaleRowTextWidget("Discounts  :", "0",
                                const Color.fromARGB(255, 11, 95, 2)),
                        SizedBox(height: 5.h),
                        const DashedDivider(),
                        SizedBox(height: 5.h),
                        // reusbaleRowTextWidget("Total Bill  :",
                        //     "₹${totalBill.round().toStringAsFixed(2)}", kWhite),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Bill :",
                                style: appStyle(16, kPrimary, FontWeight.bold)),
                            Text("₹${totalBill.round().toStringAsFixed(2)}",
                                style: appStyle(16, kPrimary, FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 15.h),
            ],
          );
        },
      ),
    );
  }

  Row reusbaleRowTextWidget(
      String firstTitle, String secondTitle, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(firstTitle, style: appStyle(14, textColor, FontWeight.normal)),
        Text(secondTitle, style: appStyle(11, textColor, FontWeight.normal)),
      ],
    );
  }

  //================================== Product Card ===================================
  Container buildProductCard(
    dynamic food,
    String foodId,
    Map<String, dynamic> selectedAddOnsPrice,
    List<dynamic> selectedAddOnsName,
    num selectedSizePrice,
    String selectedSize,
  ) {
    return Container(
      height: 110.h,
      width: double.maxFinite,
      margin: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 5.h),
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r), color: kWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title , increment and price section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //title and price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                      text: food["foodName"],
                      style: appStyle(16, kDark, FontWeight.normal)),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "₹${food["foodPrice"].toString()}",
                      style: appStyle(13, kDark, FontWeight.bold)),
                ],
              ),
              //increment and decrement button and price as well.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 35.h,
                    // width: 120.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: kPrimary)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 18.sp),
                          onPressed: isCouponApplied
                              ? () {
                                  showToastMessage(
                                      "Umm",
                                      "Firstly remove discount coupon",
                                      kPrimary);
                                }
                              : () {
                                  setState(() {
                                    if (food["quantity"] > 1) {
                                      int newQuantity = food["quantity"] - 1;
                                      updateIncrementQuantity(foodId,
                                          newQuantity, food["baseTotalPrice"]);
                                      setState(() {});
                                    } else {
                                      showDeleteConfirmationDialogProduct(
                                          context, food);
                                    }
                                  });
                                },
                        ),
                        Text(food["quantity"].toString(),
                            style: appStyle(12, kDark, FontWeight.normal)),
                        IconButton(
                          icon: Icon(Icons.add, size: 18.sp),
                          onPressed: isCouponApplied
                              ? () {
                                  showToastMessage(
                                      "Message!",
                                      "Firstly remove discount coupon",
                                      kPrimary);
                                }
                              : () {
                                  setState(() {
                                    int newQuantity = food["quantity"] + 1;
                                    // updateQuantity(foodId, newQuantity);
                                    updateQuantity(foodId, newQuantity,
                                        food["totalPrice"]);
                                    totalBill += food["totalPrice"];
                                    subtotal += food["totalPrice"];
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ReusableText(
                      text: "₹${food["quantityPrice"].toString()}",
                      style: appStyle(13, kDark, FontWeight.bold)),
                ],
              ),
            ],
          ),
          //food tag section
          SizedBox(
            width: width * 0.7,
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: food["foodCalories"].length,
              itemBuilder: (ctx, i) {
                final tag = food["foodCalories"][i];
                return Container(
                  margin: EdgeInsets.only(right: 5.w),
                  decoration: BoxDecoration(
                      color: kSecondaryLight,
                      borderRadius: BorderRadius.all(Radius.circular(9.r))),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(2.h),
                      child: ReusableText(
                          text: tag,
                          style: appStyle(8, kGray, FontWeight.w400)),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5.h),
          // Add-ons Price
          Row(
            children: [
              if (selectedAddOnsName.isNotEmpty) ...[
                // SizedBox(height: 5.h),
                ReusableText(
                    text: "Add-ons: ${selectedAddOnsName.join(', ')}",
                    style: appStyle(10, kSecondary, FontWeight.normal)),
              ],
              SizedBox(width: 10.w),
              // Size Price and Name
              if (selectedSizePrice != null && selectedSize.isNotEmpty) ...[
                // SizedBox(height: 5.h),
                ReusableText(
                    // text: "Size: $selectedSize - ₹$selectedSizePrice",
                    text: "Size: $selectedSize",
                    style: appStyle(10, kSecondary, FontWeight.normal)),
              ],
            ],
          ),
          //veg and nonveg section
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialogProduct(BuildContext context, dynamic food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Item",
              style: appStyle(18, kPrimary, FontWeight.bold)),
          content: Text(
              "Are you sure you want to delete this item from your cart?",
              style: appStyle(16, kDark, FontWeight.normal)),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: appStyle(13, kRed, FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text("Yes", style: appStyle(13, kSuccess, FontWeight.bold)),
              onPressed: () async {
                // deleteItem(food.id);
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUId)
                    .collection("cart")
                    .doc(food.id)
                    .delete()
                    .then((value) {
                  logger.d("Item successfully deleted! ${food.id}");
                  // deleteCoupon();
                  setState(() {
                    totalBill = subtotal;
                    baseToTalBill = subtotal;
                    calculatedTotalBill = subtotal;
                    discountAmount = 0;
                    isCouponApplied = false;
                    calculateTotalBill();
                  });
                  logger.d(
                      "After Deleting the item then total is $totalBill and base total bill is $baseToTalBill and calculated total bill is $calculatedTotalBill and Discount amount is $discountAmount");
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //================================== Coupon Section =================================
  Padding buildCouponSection(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, top: 8.h, bottom: 5.h, right: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: TextField(
                    controller: controller,
                    enabled: !isCouponApplied,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "Enter Coupon Code",
                      hintStyle: appStyle(15, kDark, FontWeight.normal),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimary),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              isCouponApplied
                  ? const SizedBox()
                  : Container(
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            kPrimary,
                            kPrimary,
                            kPrimary,
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: isCouponApplied
                            ? null
                            : () => applyCoupon(_couponController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text("Apply",
                            style: appStyle(16, kWhite, FontWeight.w500)),
                      ),
                    ),

//======Delete button================
              if (isCouponApplied) ...[
                SizedBox(width: 10.w),
                Container(
                  height: 50.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kRed,
                  ),
                  child: IconButton(
                    onPressed: () {
                      showCouponDeleteConfirmationDialog();
                    },
                    icon: const Icon(Icons.delete, color: kWhite),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReusableText(
                text:
                    "You can apply only 1 coupon per orders", // Informative message
                style: appStyle(12, kGray, FontWeight.normal),
              ),
              TextButton(
                  onPressed: () async {
                    // final selectedCoupon = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => CouponScreen(
                    //       onCouponSelected: (couponCode) {
                    //         _couponController.text = couponCode.toString();
                    //       },
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kSecondary),
                    ),
                    child: Text("view more",
                        style: appStyle(12, kPrimary, FontWeight.normal)),
                  )),
            ],
          ),
        ],
      ),
    );
  }

// Step 3: Implement logic to show confirmation dialog
  void showCouponDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Coupon?"),
          content:
              const Text("Are you sure you want to delete the applied coupon?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Step 4: Reset coupon and update UI and database
                deleteCoupon();
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  void deleteCoupon() {
    setState(() {
      isCouponApplied = false; // Reset coupon state

      // Clear the coupon code field
      _couponController.clear();

      // Fetch original price from Firestore and update each cart item
      FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUId)
          .collection("cart")
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          // Extract the original base price and quantity from each document
          num basePrice = doc.data()['foodPrice'];
          num quantity = doc.data()['quantity'];
          num quantityPrice = doc.data()["quantityPrice"];

          // Update each document with the original prices
          doc.reference.update({
            // 'quantityPrice': basePrice * quantity,
            'quantityPrice': quantityPrice,
            // 'totalPrice': basePrice * quantity, // Reset to original total price
            'totalPrice': quantityPrice, // Reset to original total price
            'quantity': quantity,
            'couponCode': '', // Clear coupon code
            'discountAmount': 0, // Reset discount amount
          }).then((_) {
            totalBill = subtotal;
            baseToTalBill = subtotal;
            discountAmount = 0;
            setState(() {});
            logger.d('Cart item ${doc.id} updated successfully');
            logger.d(
                "Cart Total is $totalBill and Subtotal is $subtotal and Base Total is $baseToTalBill and discount amount is $discountAmount");
          }).catchError((error) {
            logger.d('Failed to update cart item ${doc.id}: $error');
          });
        }
      }).catchError((error) {
        logger.d('Failed to fetch cart items: $error');
      });
    });
  }

  void applyCoupon(String couponCode) async {
    if (couponCode.isEmpty) {
      showToastMessage("Error", "Coupon code cannot be empty.", kRed);
      return;
    }

    try {
      // Fetch the coupon document from Firestore
      DocumentSnapshot couponSnapshot = await FirebaseFirestore.instance
          .collection("coupons")
          .doc(couponCode)
          .get();

      // Retrieve coupon data from the snapshot
      Map<String, dynamic>? couponData =
          couponSnapshot.data() as Map<String, dynamic>?;

      // Log coupon data for debugging
      logger.d('Coupon Data: $couponData');

      // Check if the coupon exists and is enabled
      if (couponSnapshot.exists && couponData?['enabled'] == true) {
        // Check if the total bill meets the minimum purchase amount required by the coupon
        if (baseToTalBill >= couponData?['minPurchaseAmount']) {
          num discount = 0.0;

          // Apply discount based on the type of discount
          if (couponData?['discountType'] == 'percentage') {
            discount = baseToTalBill * (couponData?['discountValue'] / 100);
            logger.d(
                "Discount value.. ${couponData?['discountValue'].toString()}");
            logger.d("Coupon Code value $couponCode");
            setState(() {
              discountValue = couponData?['discountValue'];
            });
          } else if (couponData?['discountType'] == 'fixed') {
            discount = couponData?['discountValue'];
            logger
                .d("Discount value ${couponData?['discountValue'].toString()}");
          }

          // Log the calculated discount for debugging
          logger.d('Calculated Discount: $discount');

          // Check if the coupon usage count is within the usage limit
          if (couponData?['usageCount'] < couponData?['usageLimit']) {
            setState(() {
              baseToTalBill -= discount;
              // subtotal -= discount;
              discountAmount = discount;
              isCouponApplied = true;
            });
            logger.d(
                "Total Bill After apply coupon $baseToTalBill and discount amount is $discountAmount");

            // Update the coupon usage count in Firestore
            couponSnapshot.reference.update({
              'usageCount': FieldValue.increment(1),
            });

            // Update the user's cart with the applied coupon code and discounted price
            FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUId)
                .collection("cart")
                .get()
                .then((querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                doc.reference.update({
                  // 'isCouponApplied': true,
                  'totalPrice': baseToTalBill,
                  'couponCode': couponCode,
                  'discountAmount': discount,
                });
              });
            });

            showToastMessage(
                "Success", "Coupon applied successfully!", kSuccess);
            logger.d('Coupon applied successfully! Discount: $discount');
            return;
          } else {
            showToastMessage(
                "Limit Reached", "Coupon has reached its usage limit.", kRed);
            logger.d('Coupon has reached its usage limit.');
          }
        } else {
          showToastMessage("Minimum Not Met",
              "Minimum purchase amount requirement not met.", kRed);
          logger.d('Minimum purchase amount requirement not met.');
        }
      } else {
        showToastMessage("Invalid", "Invalid or disabled coupon.", kRed);
        logger.d('Invalid or disabled coupon.');
      }
    } catch (e) {
      showToastMessage("Error", "Error applying coupon: $e", kRed);
      logger.d('Error applying coupon: $e');
    }
  }
}
