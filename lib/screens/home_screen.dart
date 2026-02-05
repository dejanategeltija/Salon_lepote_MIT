import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Salon Lepote"),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(themeValue: !themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Greška pri učitavanju podataka"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Trenutno nema dostupnih usluga."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var service = snapshot.data!.docs[index];
              String name = service['name'] ?? 'Nepoznata usluga';
              String price = service['price']?.toString() ?? '0';
              String duration = service['duration']?.toString() ?? '0';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.spa, color: Colors.pink),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$duration min"),
                    trailing: Text(
                      "$price RSD",
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      _showBookingDialog(context, name);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String serviceName) {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Zakazivanje"),
        content: Text("Da li želite da zakažete: $serviceName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Odustani")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                String? uid = FirebaseAuth.instance.currentUser?.uid;
                String? email = FirebaseAuth.instance.currentUser?.email;

                await FirebaseFirestore.instance.collection('appointments').add({
                  'userId': uid,
                  'userEmail': email,
                  'serviceName': serviceName,
                  'date': Timestamp.now(),
                  'status': 'na čekanju',
                });

                navigator.pop(); 
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text("Uspešno ste zakazali termin!")),
                );
              } catch (e) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text("Greška: $e")),
                );
              }
            }, 
            child: const Text("Zakaži")
          ),
        ],
      ),
    );
  }
}