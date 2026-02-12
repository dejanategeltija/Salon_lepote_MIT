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
    final bool isAdmin = user?.email == "admin@gmail.com";  //lozinka:Administrator123

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
          if (user != null)
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Odjava',
            ),
        ],
      ),
      body: user == null
          ? _buildLoggedOutView(context)
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
                          String status = data['status'] ?? 'zakazano';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Opacity(
                              opacity: (status == 'otkazan' || status == 'obrisan') ? 0.5 : 1.0,
                              child: ListTile(
                                leading: Icon(
                                    (status == 'otkazan' || status == 'obrisan')
                                        ? Icons.cancel_outlined
                                        : Icons.event_available,
                                    color: (status == 'otkazan' || status == 'obrisan')
                                        ? Colors.grey
                                        : Colors.brown),
                                title: Text(data['serviceName'] ?? "Usluga",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${data['date']} u ${data['time']}"),
                                    Text(
                                      "Trajanje: ${data['duration'] ?? '/'} min | Cena: ${data['price'] ?? '/'} RSD",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.brown),
                                    ),
                                    if (isAdmin)
                                      Text("Klijent: ${data['userEmail']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatusBadge(status),
                                    const SizedBox(width: 8),
                                    if (status != 'otkazan' && status != 'obrisan')
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        tooltip: isAdmin ? 'Obriši termin' : 'Otkaži termin',  //dugme x menja funkciju zavisno od uloge
                                        onPressed: () {
                                          if (isAdmin) {
                                            _deleteAppointment(context, docId);
                                          } else {
                                            _cancelAppointment(context, docId);
                                          }
                                        },
                                      ),
                                    if (isAdmin && status == 'zakazano')
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        tooltip: 'Potvrdi termin',
                                        onPressed: () => _updateStatus(
                                            docId, 'potvrđeno'),
                                      ),
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

//funkcija brisanje termina za admina
  Future<void> _deleteAppointment(BuildContext context, String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje termina"),
        content: const Text("Da li ste sigurni da želite da obrišete ovaj termin?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Ne")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Da, obriši", style: TextStyle(color: Colors.red)),
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

//funkcija otkazivanje za klijenta
  Future<void> _cancelAppointment(BuildContext context, String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Otkazivanje termina"),
        content: const Text("Da li ste sigurni da želite da otkažete ovaj termin?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Ne")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Da, otkaži", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'otkazan'});
    }
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': newStatus});
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TitlesTextWidget(label: "Niste prijavljeni", fontSize: 22),
          const SizedBox(height: 10),
          const Text("Prijavite se da biste videli vaše termine."),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            icon: const Icon(Icons.login),
            label: const Text("Prijavi se"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text = status;

    switch (status) {
      case 'potvrđeno':
        color = Colors.blue;
        break;
      case 'otkazan':
        color = Colors.orange;
        break;
      case 'obrisan':
        color = Colors.red;
        text = 'obrisan';
        break;
      default:
        color = Colors.green;
        text = 'zakazano';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Odjava"),
        content: const Text("Da li želite da se odjavite?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
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
      ),
    );
  }
}