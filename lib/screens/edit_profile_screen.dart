import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); 
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_passwordController.text.isNotEmpty) {
          await user!.updatePassword(_passwordController.text);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil je uspešno ažuriran!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconlyLight.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TitlesTextWidget(label: "Uredi profil", fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Prijavljeni ste kao: ${user?.email}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Novo ime i prezime",
                  prefixIcon: Icon(IconlyLight.profile),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nova lozinka",
                  prefixIcon: Icon(IconlyLight.password),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return "Lozinka mora imati bar 6 karaktera";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Potvrdite novu lozinku",
                  prefixIcon: Icon(IconlyLight.password),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_passwordController.text.isNotEmpty && value != _passwordController.text) { //provera da li se lozinka poklapa sa prethodnim poljem
                    return "Lozinke se ne poklapaju!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _updateProfile,
                  child: const Text("Sačuvaj izmene"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}