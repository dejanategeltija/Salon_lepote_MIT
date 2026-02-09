import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart'; // Dodat import za LoginScreen
import 'package:salonlepote_mit/widgets/title_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Funkcija za prikazivanje dijaloga pre odjave
  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odjava"),
          content: const Text("Da li ste sigurni da želite da se odjavite?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Zatvara samo dijalog
              child: const Text("Otkaži"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context); // Zatvara dijalog
                }
              },
              child: const Text("Odjavi se", style: TextStyle(color: Colors.red)),
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
        title: const TitlesTextWidget(label: "Profil"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/user/profile/profile_placeholder.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person),
          ),
        ),
      ),
      // DODATO: Provera da li je korisnik ulogovan
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TitlesTextWidget(label: "Niste prijavljeni", fontSize: 20),
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
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email ?? "Korisnik",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    title: const Text("Moji zakazani termini"),
                    trailing: const Icon(IconlyLight.arrowRightCircle),
                    onTap: () {
                      // Ovde ćeš kasnije dodati navigaciju ka AppointmentsScreen
                    },
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),
                  // Dugme za Logout
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