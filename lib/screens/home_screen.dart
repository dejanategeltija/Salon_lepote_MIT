import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
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
          // Ikonica za promenu teme (Mesec/Sunce)
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(
                  themeValue: !themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
          
          // IKONICA ZA PRIJAVU (Pojavljuje se samo ako korisnik NIJE ulogovan)
          if (user == null)
            IconButton(
              onPressed: () {
                // Direktna navigacija na login stranicu bez dijaloga
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
              icon: const Icon(Icons.login),
              tooltip: 'Prijava',
            ),

          // Ikonica za odjavu (Pojavljuje se samo ako JESTE ulogovan)
          if (user != null)
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                setState(() {});
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Odjava',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HERO SECTION ---
            _buildHeroSection(context, user),

            // --- 2. ZAŠTO NAS KLIJENTI BIRAJU ---
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: Text(
                "Zašto nas klijenti biraju?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoShape(Icons.diamond_outlined, "Kvalitetni Proizvodi", "Profesionalni preparati.", Colors.blue),
                _buildInfoShape(Icons.calendar_month_outlined, "Online Zakazivanje", "Rezervišite 24/7.", Colors.green),
                _buildInfoShape(Icons.star_outline, "Stručni Tim", "Sertifikovani stručnjaci.", Colors.orange),
              ],
            ),

            const SizedBox(height: 40),

            // --- 3. NASLOV IZNAD USLUGA ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Naša Najpopularnija Ponuda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.brown),
              ),
            ),

            // --- 4. LISTA USLUGA ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("Trenutno nema dostupnih usluga.");
                }

                return ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var serviceDoc = snapshot.data!.docs[index];
                    return _buildServiceCard(context, serviceDoc, user); 
                  },
                );
              },
            ),
            const SizedBox(height: 20),
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
              image: NetworkImage('https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 250,
          width: double.infinity,
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Oaza lepote i relaksacije", 
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (user == null) {
                        // Korisnik nije ulogovan -> Pitamo ga da li želi na login
                        _showLoginPromptDialog(context);
                      } else {
                        // Korisnik je ulogovan -> Vodimo ga na pretragu
                        DefaultTabController.of(context).animateTo(1);
                      }
                    },
                    child: const Text("Zakažite termin"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => DefaultTabController.of(context).animateTo(1),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                    child: const Text("Istražite Usluge", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, DocumentSnapshot doc, User? user) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? 'Usluga';
    String price = data['price']?.toString() ?? '0';
    String imageUrl = data['imageUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: InkWell(
        onTap: () {
          if (user == null) {
            // Korisnik nije ulogovan -> Pitamo ga da li želi na login
            _showLoginPromptDialog(context);
          } else {
            // Korisnik je ulogovan -> Otvaramo dijalog za zakazivanje
            _showBookingDialog(context, name);
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl.startsWith('http') 
                ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _placeholderImage())
                : _placeholderImage(),
            ),
            ListTile(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['description'] ?? 'Vrhunska usluga u našem salonu.'),
              trailing: Text("$price RSD", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIJALOG KOJI PITA KORISNIKA DA LI ŽELI DA SE ULOGUJE ---
  void _showLoginPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potrebna prijava"),
        content: const Text("Da biste zakazali termin, morate biti prijavljeni na svoj nalog. Želite li da se prijavite sada?"),
        actions: [
          // OPCIJA: NE
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Zatvori dijalog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Morate biti ulogovani ako želite da zakažete termin."),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text("Ne", style: TextStyle(color: Colors.grey)),
          ),
          // OPCIJA: DA
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Zatvori dijalog
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen())
              );
            },
            child: const Text("Da"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoShape(IconData icon, String title, String desc, Color color) {
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(height: 180, width: double.infinity, color: Colors.grey[300], child: const Icon(Icons.image_not_supported));
  }

  void _showBookingDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda rezervacije"),
        content: Text("Želite li da zakažete: $serviceName?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Odustani")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uspešno ste poslali zahtev!")));
            },
            child: const Text("Potvrdi"),
          ),
        ],
      ),
    );
  }
}