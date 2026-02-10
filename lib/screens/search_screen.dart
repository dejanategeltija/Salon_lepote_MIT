import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  final user = FirebaseAuth.instance.currentUser;

  // PROVERA ADMINA
  bool get isAdmin => user != null && user!.email == 'admin@salon.com';

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
              icon: const Icon(Icons.login),
              tooltip: 'Prijava',
            ),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.black, 
              ),
              child: const Text(
                "Kompletna ponuda salona",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: "Pretraži usluge (npr. Masaža)...",
                  prefixIcon: const Icon(IconlyLight.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        searchTextController.clear();
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddServiceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj novu uslugu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // PRIKAZ USLUGA
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nema dostupnih usluga."));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final serviceName = doc['name'].toString().toLowerCase();
                  final query = searchTextController.text.toLowerCase();
                  return serviceName.contains(query);
                }).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return _buildServiceGridCard(filteredDocs[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // KARTICA USLUGE 
  Widget _buildServiceGridCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? 'Usluga';
    String price = data['price']?.toString() ?? '0';
    String imageUrl = data['imageUrl'] ?? '';
    String duration = data['duration']?.toString() ?? '30';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _handleTap(name),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50))
                    : const Icon(Icons.image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
                  const SizedBox(height: 5),
                  Text("$duration min / $price RSD", style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w600)),
                  if (isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.blue, size: 20)),
                        IconButton(
                          onPressed: () => _deleteService(doc.id),
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(String serviceName) {
    if (user == null) {
      _showLoginPromptDialog();
    } else {
      _showBookingPicker(serviceName);
    }
  }

  Future<void> _showBookingPicker(String serviceName) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        _checkAndBook(serviceName, pickedDate, pickedTime);
      }
    }
  }

  void _checkAndBook(String serviceName, DateTime date, TimeOfDay time) async {
    String bookingId = "${date.year}-${date.month}-${date.day}-${time.hour}-${time.minute}";
    
    var existing = await FirebaseFirestore.instance
        .collection('appointments')
        .where('bookingId', isEqualTo: bookingId)
        .get();

    if (existing.docs.isNotEmpty) {
      _showErrorSnackBar("Termin je već zauzet! Izaberite drugo vreme.");
    } else {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userEmail': user!.email,
        'serviceName': serviceName,
        'date': "${date.day}.${date.month}.${date.year}",
        'time': "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
        'bookingId': bookingId,
        'status': 'zakazano'
      });
      _showSuccessSnackBar("Uspešno zakazano: $serviceName");
    }
  }

  void _showAddServiceDialog(BuildContext context) {
    final nController = TextEditingController();
    final pController = TextEditingController();
    final dController = TextEditingController();
    final iController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova usluga"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nController, decoration: const InputDecoration(labelText: "Naziv")),
              TextField(controller: pController, decoration: const InputDecoration(labelText: "Cena"), keyboardType: TextInputType.number),
              TextField(controller: dController, decoration: const InputDecoration(labelText: "Trajanje (min)"), keyboardType: TextInputType.number),
              TextField(controller: iController, decoration: const InputDecoration(labelText: "URL slike")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('services').add({
                'name': nController.text,
                'price': int.parse(pController.text),
                'duration': int.parse(dController.text),
                'imageUrl': iController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  void _deleteService(String id) {
    FirebaseFirestore.instance.collection('services').doc(id).delete();
  }

  void _showLoginPromptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prijavite se"),
        content: const Text("Da bi ste zakazali termin morate biti prijavljeni na svoj nalog."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Odustani")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Prijava"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccessSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}