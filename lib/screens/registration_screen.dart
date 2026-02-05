import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Kreiranje korisnika u Firebase-u
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Opciono: Ovde možemo dodati kod za čuvanje imena u Firestore bazi
        
        if (!mounted) return;
        Navigator.pop(context); // Vraća korisnika na login ili ga Root prebacuje dalje
        
      } on FirebaseAuthException catch (e) {
        String message = "Greška pri registraciji";
        if (e.code == 'email-already-in-use') {
          message = "Ovaj email je već u upotrebi.";
        } else if (e.code == 'weak-password') {
          message = "Lozinka je previše slaba.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const TitlesTextWidget(label: "Registracija", fontSize: 28),
                    const SizedBox(height: 8),
                    Container(height: 1, width: 140, color: Colors.grey.shade400),
                    const SizedBox(height: 40),
                    
                    // Polje za ime
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Ime i prezime",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Unesite ime" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email polje
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || !value.contains('@')) ? "Neispravan email" : null,
                    ),
                    const SizedBox(height: 16),

                    // Lozinka
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Lozinka",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.length < 6 ? "Minimum 6 karaktera" : null,
                    ),
                    const SizedBox(height: 16),

                    // Potvrda lozinke
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Potvrdite lozinku",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value != _passwordController.text ? "Lozinke se ne poklapaju" : null,
                    ),
                    const SizedBox(height: 32),

                    // Dugme za registraciju
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF212121),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: _isLoading ? null : _handleRegistration,
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text("Registruj se"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}