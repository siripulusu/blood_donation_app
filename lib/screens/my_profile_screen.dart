import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donor_profile_screen.dart';
import 'register_donor_screen.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User? user;
  Map<String, dynamic>? donorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserAndFetchInfo();
  }

  Future<void> _checkUserAndFetchInfo() async {
    // This listener dynamically updates the screen when auth state changes (e.g., login, logout)
    FirebaseAuth.instance.authStateChanges().listen((currentUser) async {
      if (currentUser != null) {
        // User is logged in, now check for a donor profile
        final doc = await FirebaseFirestore.instance.collection('donors').doc(currentUser.uid).get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              user = currentUser;
              donorData = doc.data();
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              user = currentUser;
              donorData = null; // Indicate profile doesn't exist
              isLoading = false;
            });
          }
        }
      } else {
        // No user logged in
        if (mounted) {
          setState(() {
            user = null;
            donorData = null;
            isLoading = false;
          });
        }
      }
    });
  }

  Future<void> toggleAvailability(bool value) async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('donors')
        .doc(user!.uid)
        .update({'isAvailable': value});
    setState(() {
      donorData!['isAvailable'] = value;
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      deleteAccount();
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('donors').doc(user!.uid).delete();
        await user!.delete();
        // The authStateChanges listener in main.dart will handle the navigation after logout
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      // User is not logged in, show the DonorProfileScreen
      return const DonorProfileScreen();
    }

    if (donorData == null) {
      // User is logged in but has no donor data, prompt them to register
      return const RegisterDonorScreen();
    }

    // This part is the actual MyProfileScreen UI
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        automaticallyImplyLeading: false, // Prevents the back button from appearing
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.notifications_none),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        donorData!["name"]?.substring(0, 1).toUpperCase() ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      donorData!["name"] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            donorData!["bloodGroup"] ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: donorData!["isAvailable"] == true ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            donorData!["isAvailable"] == true ? "Available" : "Unavailable",
                            style: TextStyle(color: donorData!["isAvailable"] == true ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      title: const Text("Donation Availability"),
                      subtitle: const Text("Toggle when you're available to donate"),
                      value: donorData!["isAvailable"] ?? false,
                      onChanged: toggleAvailability,
                      activeColor: Colors.red,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            // The pen icon now correctly navigates to the edit screen
                            Navigator.pushNamed(context, '/editProfile', arguments: donorData);
                          },
                          child: const Icon(Icons.edit, size: 20)
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    infoRow(Icons.person_outline, "Full Name", donorData!["name"] ?? ''),
                    const SizedBox(height: 12),
                    infoRow(Icons.phone, "Phone Number", donorData!["phone"] ?? ''),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: infoRow(Icons.local_fire_department, "Blood Group", donorData!["bloodGroup"] ?? '')),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("Cannot be changed", style: TextStyle(fontSize: 10, color: Colors.red)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    infoRow(Icons.location_on_outlined, "Location", "${donorData!["city"]}, ${donorData!["state"]}"),
                    const SizedBox(height: 12),
                    infoRow(Icons.calendar_month, "Last Donated", donorData!['lastDonated'] != null ? donorData!['lastDonated']!.split('T').first : 'Never'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
              onTap: _showDeleteConfirmationDialog,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text("Logout"),
              onTap: _showLogoutConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
