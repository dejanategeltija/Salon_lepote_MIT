import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:salonlepote_mit/screens/appointments_screen.dart';
import 'package:salonlepote_mit/screens/home_screen.dart';
import 'package:salonlepote_mit/screens/search_screen.dart';
import 'package:salonlepote_mit/screens/profile_screen.dart';

class RootScreen extends StatefulWidget {
  final int startScreen; 
  const RootScreen({super.key, this.startScreen = 0});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int currentScreen;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    currentScreen = widget.startScreen;
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(), 
      const AppointmentsScreen(), 
      const ProfileScreen(),
    ];

    return Scaffold(
      // OVDE NEMA APPBARA - svaki screen ima svoj
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index) {
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(currentScreen);
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Početna",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.search),
            icon: Icon(IconlyLight.search),
            label: "Usluge",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.calendar),
            icon: Icon(IconlyLight.calendar),
            label: "Termini",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.profile),
            icon: Icon(IconlyLight.profile),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}