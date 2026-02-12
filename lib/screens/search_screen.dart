import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:salonlepote_mit/providers/theme_provider.dart';
import 'package:salonlepote_mit/screens/login_screen.dart';
import 'package:salonlepote_mit/screens/root_screen.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

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
    final user = FirebaseAuth.instance.currentUser;
    final bool isAdmin = user != null && user.email == 'admin@gmail.com';

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .snapshots(),
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
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return _buildServiceGridCard(filteredDocs[index], isAdmin);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridCard(DocumentSnapshot doc, bool isAdmin) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String name = data['name'] ?? 'Usluga';
    String price = data['price']?.toString() ?? '0';
    String imageUrl = data['imageUrl'] ?? '';
    String duration = data['duration']?.toString() ?? '30';
    String description =
        data['description'] ?? 'Vrhunska usluga u našem salonu.';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _handleTap(name, price, duration),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50))
                    : const Icon(Icons.image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text("$duration min / $price RSD",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.brown,
                          fontWeight: FontWeight.w600)),
                  if (isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () =>
                                _showEditServiceDialog(context, doc),
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20)),
                        IconButton(
                          onPressed: () => _confirmDelete(context, doc.id, name),
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
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

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: Text("Da li ste sigurni da želite da obrišete uslugu: $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Otkaži"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('services')
                  .doc(id)
                  .delete();
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar("Usluga obrisana.");
              }
            },
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final nController = TextEditingController(text: data['name']);
    final pController = TextEditingController(text: data['price'].toString());
    final dController =
        TextEditingController(text: data['duration'].toString());
    final iController = TextEditingController(text: data['imageUrl']);
    final descController = TextEditingController(text: data['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izmeni uslugu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nController,
                  decoration: const InputDecoration(labelText: "Naziv *")),
              TextField(
                  controller: pController,
                  decoration: const InputDecoration(labelText: "Cena *"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: dController,
                  decoration: const InputDecoration(labelText: "Trajanje (min) *"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: iController,
                  decoration: const InputDecoration(labelText: "URL slike *")),
              TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Opis *")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Otkaži")),
          ElevatedButton(
            onPressed: () async {
              if (nController.text.trim().isEmpty ||
                  pController.text.trim().isEmpty ||
                  dController.text.trim().isEmpty ||
                  iController.text.trim().isEmpty ||
                  descController.text.trim().isEmpty) {
                _showErrorSnackBar("Sva polja moraju biti popunjena!");
                return;
              }

              await FirebaseFirestore.instance
                  .collection('services')
                  .doc(doc.id)
                  .update({
                'name': nController.text.trim(),
                'price': int.tryParse(pController.text.trim()) ?? 0,
                'duration': int.tryParse(dController.text.trim()) ?? 0,
                'imageUrl': iController.text.trim(),
                'description': descController.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar("Usluga izmenjena!");
              }
            },
            child: const Text("Sačuvaj"),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final nController = TextEditingController();
    final pController = TextEditingController();
    final dController = TextEditingController();
    final iController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova usluga"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nController,
                  decoration: const InputDecoration(labelText: "Naziv *")),
              TextField(
                  controller: pController,
                  decoration: const InputDecoration(labelText: "Cena *"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: dController,
                  decoration: const InputDecoration(labelText: "Trajanje (min) *"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: iController,
                  decoration: const InputDecoration(labelText: "URL slike *")),
              TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Opis *")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Otkaži")),
          ElevatedButton(
            onPressed: () async {
              if (nController.text.trim().isEmpty ||
                  pController.text.trim().isEmpty ||
                  dController.text.trim().isEmpty ||
                  iController.text.trim().isEmpty ||
                  descController.text.trim().isEmpty) {
                _showErrorSnackBar("Molimo popunite sva obavezna polja!");
                return;
              }

              await FirebaseFirestore.instance.collection('services').add({
                'name': nController.text.trim(),
                'price': int.tryParse(pController.text.trim()) ?? 0,
                'duration': int.tryParse(dController.text.trim()) ?? 0,
                'imageUrl': iController.text.trim(),
                'description': descController.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar("Usluga dodata!");
              }
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  void _handleTap(String serviceName, String price, String duration) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginPromptDialog();
    } else {
      _showBookingPicker(serviceName, price, duration);
    }
  }

  Future<void> _showBookingPicker(
      String serviceName, String price, String duration) async {
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
        helpText: "RADNO VREME: 09:00 - 21:00",
      );

      if (pickedTime != null) {
        if (pickedTime.hour < 9 || pickedTime.hour >= 21) {
          _showErrorSnackBar("Salon radi od 09:00 do 21:00.");
          return;
        }
        _checkAndBook(serviceName, pickedDate, pickedTime, price, duration);
      }
    }
  }

  void _checkAndBook(String serviceName, DateTime date, TimeOfDay time,
      String price, String duration) async {
    final user = FirebaseAuth.instance.currentUser;
    String bookingId =
        "${date.year}-${date.month}-${date.day}-${time.hour}-${time.minute.toString().padLeft(2, '0')}";

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      var existing = await FirebaseFirestore.instance
          .collection('appointments')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (!mounted) return;
      Navigator.pop(context);

      if (existing.docs.isNotEmpty) {
        _showErrorSnackBar("Termin je već zauzet! Izaberite drugo vreme.");
      } else {
        await FirebaseFirestore.instance.collection('appointments').add({
          'userEmail': user!.email,
          'serviceName': serviceName,
          'price': price,
          'duration': duration,
          'date': "${date.day}.${date.month}.${date.year}.",
          'time':
              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
          'bookingId': bookingId,
          'status': 'zakazano',
          'createdAt': Timestamp.now(),
        });
        _showSuccessSnackBar("Uspešno zakazano: $serviceName");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar("Greška: $e");
    }
  }

  void _showLoginPromptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prijavite se"),
        content: const Text("Morate biti prijavljeni da biste zakazali termin."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Odustani")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Prijava"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Odjava"),
        content: const Text("Da li želite da se odjavite?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Otkaži")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RootScreen(startScreen: 0)),
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

  void _showErrorSnackBar(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccessSnackBar(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}