import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Pretraži usluge"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: "Npr. Masaža, Frizura...",
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
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text("Došlo je do greške pri učitavanju."));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nema dostupnih usluga u bazi."));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final serviceName = doc['name'].toString().toLowerCase();
                  final query = searchTextController.text.toLowerCase();
                  return serviceName.contains(query);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Nema rezultata za vašu pretragu."));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var service = filteredDocs[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.pinkAccent,
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                      title: Text(
                        service['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${service['price']} RSD"),
                      trailing: const Icon(IconlyLight.arrowRightCircle),
                      onTap: () {
                        debugPrint("Izabrana usluga: ${service['name']}");
                      },
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
}