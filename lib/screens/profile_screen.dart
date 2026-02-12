import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/edit_profile_screen.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
import 'package:salonlepote_mit/screens/root_screen.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odjava"),
          content: const Text("Da li ste sigurni da želite da se odjavite?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Otkaži"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pop(context); // zatvaranje dijaloga

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RootScreen(startScreen: 0)),
                    (route) => false, // brisanje istorije
                  );
                }
              },
              child:
                  const Text("Odjavi se", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Salon Lepote Mio"),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(
                  themeValue: !themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
          if (user == null)
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.login),
              tooltip: 'Prijava',
            ),
          if (user != null)
            IconButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Odjava',
            ),
        ],
      ),

      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TitlesTextWidget(
                      label: "Niste prijavljeni", fontSize: 20),
                  const SizedBox(height: 10),
                  const Text("Prijavite se da biste videli vaš profil."),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212121),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(IconlyLight.login),
                    label: const Text("Prijavi se"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/user/profile/profile_placeholder.png',
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TitlesTextWidget(
                                label: "Profil", fontSize: 24),
                            Text(
                              user.email ?? "Korisnik",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: TitlesTextWidget(label: "Podešavanja", fontSize: 18),
                  ),
                  SwitchListTile(
                    title: Text(themeProvider.getIsDarkTheme
                        ? "Tamni režim"
                        : "Svetli režim"),
                    secondary: Icon(themeProvider.getIsDarkTheme
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    value: themeProvider.getIsDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(themeValue: value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(IconlyLight.calendar),
                    title: const Text("Zakazani termini"),
                    trailing: const Icon(IconlyLight.arrowRightCircle),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RootScreen(startScreen: 2),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(IconlyLight.edit),
                    title: const Text("Upravljajte svojim profilom"),
                    trailing: const Icon(IconlyLight.arrowRightCircle),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(IconlyLight.logout, color: Colors.red),
                      label: const Text(
                        "Odjavi se",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}