import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:salonlepote_mit/screens/home_screen.dart';
import 'package:salonlepote_mit/screens/search_screen.dart';
import 'package:salonlepote_mit/screens/profile_screen.dart';


class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late List<Widget> screens;
  int currentScreen = 0; 
  late PageController controller;

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const SearchScreen(),
      const Center(child: Text("Termini uskoro")), 
      const ProfileScreen(),
    ];
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

       /* if (!snapshot.hasData) {
           return const LoginScreen(); 
        }*/


        return Scaffold(
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
                label: "Pretraga",
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
      },
    );
  }
}