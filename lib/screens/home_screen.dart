import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
import 'package:salonlepote_mit/screens/root_screen.dart'; 
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
    final user = FirebaseAuth.instance.currentUser;

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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, user),

            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: Text(
                "Zašto nas klijenti biraju?",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoShape(
                    Icons.diamond_outlined,
                    "Kvalitetni Proizvodi",
                    "Koristimo isključivo profesionalne proizvode.",
                    Colors.blue),
                _buildInfoShape(
                    Icons.calendar_month_outlined,
                    "Online Rezervacija",
                    "Brzo i lako zakažite svoj termin.",
                    Colors.green),
                _buildInfoShape(Icons.star_outline, "Stručni Tim",
                    "Sertifikovani profesionalci.", Colors.orange),
              ],
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Naša Najpopularnija Ponuda",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .limit(3)
                  .snapshots(),  //slusa promene u realnom vremenu
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("Trenutno nema dostupnih usluga.");
                }

                return ListView.builder(
                  shrinkWrap: true,  //zauzimanje mesta liste
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var serviceDoc = snapshot.data!.docs[index];   //uzima podatke za jednu uslugu
                    return _buildServiceCard(context, serviceDoc, user);
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, User? user) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.black.withValues(alpha:0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Oaza lepote i relaksacije",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Zakažite termin ili Pregledajte termine
                  ElevatedButton(
                    onPressed: () {
                      if (user == null) {
                        _showLoginPromptDialog(context);
                      } else {
                        Navigator.push( 
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RootScreen(startScreen: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                        user == null ? "Zakažite termin" : "Pregledajte termine"),
                  ),
                  const SizedBox(width: 10),
                  
                  // Istražite Usluge
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RootScreen(startScreen: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white)),
                    child: const Text("Istražite Usluge",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      BuildContext context, DocumentSnapshot doc, User? user) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? 'Usluga';
    String price = data['price']?.toString() ?? '0';
    String imageUrl = data['imageUrl'] ?? '';
    String duration = data['duration']?.toString() ?? '30';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: InkWell(   //efekat talasa,kartica postaje dugme
        onTap: () {
          if (user == null) {
            _showLoginPromptDialog(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RootScreen(startScreen: 1),
              ),
            );
          }
        },
        child: Column(
          children: [
            ClipRRect(  //za zaobljenu ivicu slike
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl.startsWith('http')
                  ? Image.network(imageUrl,
                      height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholderImage())
                  : _placeholderImage(),
            ),
            ListTile(
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['description'] ?? 'Vrhunska usluga u našem salonu.'),
              trailing: Text("$price RSD/$duration min",
                  style: const TextStyle(
                      color: Colors.brown, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potrebna prijava"),
        content: const Text(
            "Da biste zakazali termin, morate biti prijavljeni na svoj nalog. Želite li da se prijavite sada?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Da"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
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


  Widget _buildInfoShape(
      IconData icon, String title, String desc, Color color) {
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _placeholderImage() => Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported));
}