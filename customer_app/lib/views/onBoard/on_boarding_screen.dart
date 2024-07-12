import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants/constants.dart';
import '../auth/phone_authentication_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onBoardingData = [
    {
      "image": "assets/onboard_1.png",
      "heading": "Choose from our best menu",
      "subheading":
          "Pick your desired food from the menu. There are more than 30 items.",
    },
    {
      "image": "assets/onboard_2.png",
      "heading": "Easy and online Payment",
      "subheading":
          "Trouble free and online payment any card payment is available",
    },
    {
      "image": "assets/onboard_3.png",
      "heading": "Quick delivery at your Doorstep",
      "subheading":
          "Home delivery and online reservation system for restaurant and cafe.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onBoardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(_onBoardingData[index]['image']!),
                      const SizedBox(height: 20),
                      Text(
                        _onBoardingData[index]['heading']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18),
                        child: Text(
                          _onBoardingData[index]['subheading']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: _onBoardingData.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: kPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kWhite,
                  minimumSize: Size(100.w, 42.h)),
              onPressed: () {
                if (_currentPage == _onBoardingData.length - 1) {
                  // Navigate to another screen, e.g., HomeScreen
                  Get.offAll(() => const PhoneAuthenticationScreen(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 900));
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(_currentPage == _onBoardingData.length - 1
                  ? 'Get Started'
                  : 'Next'),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
