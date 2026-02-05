import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Profil"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/user/profile/profile_placeholder.png', errorBuilder: (context, error, stackTrace) => const Icon(Icons.person)), // Placeholder ako nema slike
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Prikaz email-a ulogovanog korisnika
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email ?? "Gost",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              title: Text(themeProvider.getIsDarkTheme ? "Tamni režim" : "Svetli režim"),
              secondary: Icon(themeProvider.getIsDarkTheme ? Icons.dark_mode : Icons.light_mode),
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
              },
            ),

            const Divider(thickness: 1),

            // Dugme za Logout
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  
                },
                icon: const Icon(IconlyLight.logout, color: Colors.red),
                label: const Text(
                  "Odjavi se",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}