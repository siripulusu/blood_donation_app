import 'package:flutter/material.dart';
import '../widgets/quick_action_card.dart';
import 'donor_search_screen.dart';
import 'blood_facts_screen.dart';
import 'emergency_request_screen.dart';
import 'blood_banks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.015),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFlashCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 225, 46, 46), Color.fromARGB(255, 240, 24, 57)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_border, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            "Save Lives Today",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            "Every drop counts, every donor matters",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return SlideTransition(
      position: _floatAnimation,
      child: QuickActionCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        backgroundColor: backgroundColor,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Blood Connect",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SlideTransition(position: _floatAnimation, child: _buildFlashCard()),
              const SizedBox(height: 28),
              const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickAction(
                    title: 'Find Donors',
                    subtitle: 'Search for blood donors near you',
                    icon: Icons.manage_search_rounded,
                    backgroundColor: Colors.blue.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonorSearchScreen()),
                    ),
                  ),
                  _buildQuickAction(
                    title: 'Blood Banks',
                    subtitle: 'Locate nearby blood centers',
                    icon: Icons.location_on_outlined,
                    backgroundColor: Colors.green.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodBanksScreen()),
                    ),
                  ),
                  _buildQuickAction(
                    title: 'Emergency',
                    subtitle: 'Urgent blood needed!',
                    icon: Icons.warning_amber_rounded,
                    backgroundColor: Colors.red.shade100,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyRequestScreen()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    title: 'Blood Facts',
                    subtitle: 'Learn about donation facts',
                    icon: Icons.menu_book,
                    backgroundColor: Colors.purple.shade100,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodFactsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}