import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
import 'package:salonlepote_mit/screens/root_screen.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isAdmin = user?.email == "admin@gmail.com";

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
          ? const Center(child: Text("Prijavite se da biste videli termine."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TitlesTextWidget(
                    label: isAdmin ? "Upravljanje terminima" : "Moji termini",
                    fontSize: 24,
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: isAdmin
                        ? FirebaseFirestore.instance
                            .collection('appointments')
                            .orderBy('createdAt', descending: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('appointments')
                            .where('userEmail', isEqualTo: user.email)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Nema termina."));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var appointment = snapshot.data!.docs[index];
                          var data = appointment.data() as Map<String, dynamic>;
                          String docId = appointment.id;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            // Ako je obrisan, malo ga prozirnijim učinimo (opciono)
                            child: Opacity(
                              opacity: data['status'] == 'obrisan' ? 0.6 : 1.0,
                              child: ListTile(
                                leading: Icon(
                                  data['status'] == 'obrisan' ? Icons.delete_outline : Icons.event_available, 
                                  color: data['status'] == 'obrisan' ? Colors.grey : Colors.brown
                                ),
                                title: Text(data['serviceName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${data['date']} u ${data['time']}"),
                                    if (isAdmin) Text("Klijent: ${data['userEmail']}", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatusBadge(data['status']),
                                    
                                    if (isAdmin && data['status'] != 'obrisan') ...[
                                      const SizedBox(width: 8),
                                      if (data['status'] == 'zakazano')
                                        IconButton(
                                          icon: const Icon(Icons.check_circle, color: Colors.green),
                                          onPressed: () => _updateStatus(docId, 'potvrđeno'),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _markAsDeleted(context, docId),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'potvrđeno': color = Colors.blue; break;
      case 'obrisan': color = Colors.red; break;
      case 'otkazan': color = Colors.grey; break; 
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> _markAsDeleted(BuildContext context, String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje termina"),
        content: const Text("Da li ste sigurni da želite da obrisete ovaj termin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Otkaži")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'obrisan'});
    }
  }

  void _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odjava"),
          content: const Text("Da li ste sigurni da želite da se odjavite?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RootScreen(startScreen: 0)),
                    (route) => false,
                  );
                }
              },
              child: const Text("Odjavi se", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}