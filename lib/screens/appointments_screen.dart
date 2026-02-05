import 'package:flutter/material.dart';
import 'package:salonlepote_mit/widgets/title_text.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Moji Termini"),
      ),
      body: const Center(
        child: Text("Ovde će biti lista tvojih zakazanih tretmana."),
      ),
    );
  }
}