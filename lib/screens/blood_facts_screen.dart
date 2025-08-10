import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BloodFactsScreen extends StatefulWidget {
  const BloodFactsScreen({super.key});

  @override
  State<BloodFactsScreen> createState() => _BloodFactsScreenState();
}

class _BloodFactsScreenState extends State<BloodFactsScreen> {
  List<dynamic> bloodFacts = [];

  final List<Color> iconColors = [
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.deepPurple,
    Colors.orangeAccent,
    Colors.teal,
    Colors.redAccent,
    Colors.indigo,
    Colors.green
  ];

  final List<IconData> icons = [
    Icons.favorite,
    Icons.calendar_month,
    Icons.public,
    Icons.access_time,
    Icons.shield,
    Icons.water_drop,
    Icons.info,
    Icons.mood
  ];

  @override
  void initState() {
    super.initState();
    loadFacts();
  }

  Future<void> loadFacts() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/blood_facts.json');

      if (response.trim().isEmpty) {
        throw Exception("Blood facts JSON file is empty.");
      }

      final data = json.decode(response);
      setState(() {
        bloodFacts = data;
      });
    } catch (e) {
      print("Failed to load blood facts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Blood Donation Facts",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Increased font weight
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: bloodFacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bloodFacts.length,
              itemBuilder: (context, index) {
                final fact = bloodFacts[index];
                final iconColor = iconColors[index % iconColors.length];
                final icon = icons[index % icons.length];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + index * 50),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300, // subtle gray border
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      fact['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        fact['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
