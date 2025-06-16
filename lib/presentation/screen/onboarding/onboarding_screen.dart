import 'package:WashAm/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:WashAm/configuration/padding_spacing.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to WashAM",
      "image": "assets/images/onboarding.png",
      "subtitle":
          "Experience top-notch laundry service with spotless results—every time!"
    },
    {
      "title": "Schedule with Ease",
      "image":
          "https://ouch-cdn2.icons8.com/y2oKEsDxKxxcm6HfLfTb2tPpG37z5AUFwlvYlhrB_iI/rs:fit:960:960/czM6Ly9pY29uczgvZXNzZW50aWFsLXNldC8zMC9iN2FlYTI1MC1lNzNmLTRkZDctYjcyYi1mYmYzNjEzMjYxYmMucG5n.png",
      "subtitle":
          "Book pickups, customize your wash, and set schedules in seconds."
    },
    {
      "title": "Fresh Clothes Delivered",
      "image":
          "https://ouch-cdn2.icons8.com/gzkQSp_-WmS8JxuGul5LTFSnElpnpqJSAGThOCyiBGI/rs:fit:960:960/czM6Ly9pY29uczgvZXNzZW50aWFsLXNldC80MC82YTUwY2RkNy1kYmI1LTQ3YWYtYmZhYS1mOWFkNmE5ZWEzMWEucG5n.png",
      "subtitle": "Your fresh laundry delivered to your doorstep—fast and easy."
    },
  ];

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await AppRouter()
          .pushReplacement(context, '/login'); // navigate after onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (_, index) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _pages[index]["image"]!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (ctx, err, st) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _pages[index]["title"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: Spacing.widthPercentage80(context),
                    child: Text(
                      _pages[index]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == i ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? const Color(0xFF43DED0)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43DED0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
