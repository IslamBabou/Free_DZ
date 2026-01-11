import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:free_dz/screens/freelancers/freelancers_services.dart';
import 'package:free_dz/screens/freelancers/jobs/jobs.dart';


import 'free_home.dart';
import 'package:free_dz/screens/shared/chat_list.dart';

// ==========================================
// FREELANCER MAIN SCREEN
// ==========================================

class FreelancerMainScreen extends StatefulWidget {
  final bool showCompletionBanner;

  const FreelancerMainScreen({
    super.key,
    this.showCompletionBanner = false,
  });

  @override
  State<FreelancerMainScreen> createState() => _FreelancerMainScreenState();
}

class _FreelancerMainScreenState extends State<FreelancerMainScreen> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);
  
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Show profile completion banner if needed
    if (widget.showCompletionBanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionBanner();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showCompletionBanner() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.orange.shade100,
        leading: const Icon(Icons.info_outline, color: Colors.orange),
        content: const Text(
          'Complete your profile to get 3x more visibility',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              setState(() {
                _currentIndex = 3; // Profile page index
              });
            },
            child: const Text('Complete Now'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }

  // Define your pages here
  final List<Widget> _pages = [
    
    const FreelancerHomePage(),
    const JobsPage(),
    const ChatListPage(),
    const FreelancerServicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade700
            : Colors.blue,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 10),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.home_outlined,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.home,
              color: Colors.white,
            ),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.work_outline,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.work,
              color: Colors.white,
            ),
            itemLabel: 'Jobs',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.chat_bubble,
              color: Colors.white,
            ),
            itemLabel: 'Messages',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.medical_services_outlined,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
            ),
            itemLabel: 'Services',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}

