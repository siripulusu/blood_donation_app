import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  String selectedGroup = 'All';
  String selectedCountry = 'India';
  String selectedState = '';
  String selectedCity = '';

  final List<String> bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final Map<String, Map<String, List<String>>> locationData = {
    "India": {
    "Andhra Pradesh": [
      "Visakhapatnam","Vijayawada","Guntur","Nellore","Kurnool",
      "Rajahmundry","Tirupati","Anantapur","Kadapa","Eluru",
      "Ongole","Srikakulam","Chittoor","Vizianagaram"
    ],
    "Telangana": [
      "Hyderabad","Warangal","Nizamabad","Karimnagar","Khammam",
      "Ramagundam","Mahbubnagar","Nalgonda","Adilabad","Miryalaguda",
      "Siddipet","Suryapet",
      "Jangaon","Medak","Vikarabad","Zaheerabad","Sangareddy",
      "Kamareddy",
    ],
    "Arunachal Pradesh": ["Itanagar", "Tawang", "Pasighat", "Ziro", "Bomdila"],
    "Assam": ["Guwahati", "Tezpur", "Dibrugarh", "Silchar", "North Lakhimpur"],
    "Bihar": ["Patna", "Gaya", "Darbhanga", "Bhagalpur", "Muzaffarpur"],
    "Chhattisgarh": ["Raipur", "Bilaspur", "Korba", "Durg", "Rajnandgaon"],
    "Goa": ["Panaji", "Vasco da Gama", "Margao", "Ponda", "Mapusa"],
    "Gujarat": ["Ahmedabad", "Surat", "Rajkot", "Vadodara", "Bhavnagar"],
    "Haryana": ["Faridabad", "Gurugram", "Panipat", "Ambala", "Hisar"],
    "Himachal Pradesh": ["Shimla", "Dharamshala", "Mandi", "Solan", "Bilaspur"],
    "Jharkhand": ["Ranchi", "Jamshedpur", "Dhanbad", "Bokaro", "Deoghar"],
    "Karnataka": ["Bengaluru", "Mysuru", "Mangalore", "Hubli", "Belgaum"],
    "Kerala": ["Thiruvananthapuram", "Kochi", "Kozhikode", "Thrissur", "Alappuzha"],
    "Madhya Pradesh": ["Bhopal", "Indore", "Gwalior", "Jabalpur", "Ujjain"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik", "Aurangabad"],
    "Manipur": ["Imphal", "Bishnupur", "Ukhrul", "Churachandpur", "Thoubal"],
    "Meghalaya": ["Shillong", "Tura", "Jowai", "Baghmara", "Nongpoh"],
    "Mizoram": ["Aizawl", "Lunglei", "Champhai", "Serchhip", "Kolasib"],
    "Nagaland": ["Kohima", "Dimapur", "Mokokchung", "Tuensang", "Zunheboto"],
    "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela", "Puri", "Sambalpur"],
    "Punjab": ["Ludhiana", "Amritsar", "Jalandhar", "Patiala", "Bathinda"],
    "Rajasthan": ["Jaipur", "Jodhpur", "Udaipur", "Kota", "Ajmer"],
    "Sikkim": ["Gangtok", "Namchi", "Mangan", "Gyalshing", "Rangpo"],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai", "Tiruchirappalli", "Salem"],
    "Tripura": ["Agartala", "Udaipur", "Dharmanagar", "Belonia", "Kailasahar"],
    "Uttar Pradesh": ["Lucknow", "Kanpur", "Varanasi", "Agra", "Meerut"],
    "Uttarakhand": ["Dehradun", "Haridwar", "Roorkee", "Haldwani", "Rishikesh"],
    "West Bengal": ["Kolkata", "Asansol", "Siliguri", "Durgapur", "Howrah"],
    },
  };

  @override
  Widget build(BuildContext context) {
    final states = locationData[selectedCountry]?.keys.toList() ?? [];
    final cities = locationData[selectedCountry]?[selectedState] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Donors",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Blood Group", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bloodGroups.map((group) {
                      return ChoiceChip(
                        label: Text(group),
                        selected: selectedGroup == group,
                        onSelected: (_) => setState(() => selectedGroup = group),
                        selectedColor: Colors.red.shade100,
                        labelStyle: TextStyle(
                          color: selectedGroup == group ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Location", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCountry,
                    items: locationData.keys.map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    )).toList(),
                    onChanged: (val) => setState(() {
                      selectedCountry = val!;
                      selectedState = '';
                      selectedCity = '';
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedState.isNotEmpty ? selectedState : null,
                    hint: const Text('Select State'),
                    items: states.map((state) => DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    )).toList(),
                    onChanged: (val) => setState(() {
                      selectedState = val!;
                      selectedCity = '';
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCity.isNotEmpty ? selectedCity : null,
                    hint: const Text('Select City'),
                    items: cities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )).toList(),
                    onChanged: (val) => setState(() => selectedCity = val!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('donors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No donors available.'));
                }

                String? inferredCountry = (selectedCountry.isNotEmpty && selectedCountry != '') ? selectedCountry : null;
                String? inferredState = (selectedState.isNotEmpty && selectedState != '') ? selectedState : null;
                String? inferredCity = (selectedCity.isNotEmpty && selectedCity != '') ? selectedCity : null;

                if ((inferredState != null && inferredState.isNotEmpty) && (inferredCountry == null || inferredCountry.isEmpty)) {
                  locationData.forEach((country, statesMap) {
                    if (statesMap.containsKey(inferredState)) {
                      inferredCountry = country;
                    }
                  });
                }
                if ((inferredCity != null && inferredCity.isNotEmpty) && (inferredState == null || inferredState.isEmpty)) {
                  locationData.forEach((country, statesMap) {
                    statesMap.forEach((state, citiesList) {
                      if (citiesList.contains(inferredCity)) {
                        inferredCountry = country;
                        inferredState = state;
                      }
                    });
                  });
                }

                final donors = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesGroup = selectedGroup == 'All' || data['bloodGroup'] == selectedGroup;
                  bool matchesLocation = true;
                  if (inferredCountry?.isNotEmpty ?? false) {
                    matchesLocation = matchesLocation && (data['country'] == inferredCountry);
                  }
                  if (inferredState?.isNotEmpty ?? false) {
                    matchesLocation = matchesLocation && (data['state'] == inferredState);
                  }
                  if (inferredCity != null && inferredCity.isNotEmpty) {
                    matchesLocation = matchesLocation && (data['city'] == inferredCity);
                  }
                  return matchesGroup && matchesLocation;
                }).toList();

                if (donors.isEmpty) {
                  return const Center(child: Text('No matching donors.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final data = donors[index].data() as Map<String, dynamic>;
                    return _buildDonorCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'No Name',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${data['city'] ?? ''}${data['state'] != null && data['state'] != '' ? ', ${data['state']}' : ''}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          if (data['distance'] != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${data['distance']} km',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['bloodGroup'] ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (data['available'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text('Call', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      String phone = (data['phone'] ?? '').replaceAll(RegExp(r'\s+'), '');
                      if (phone.isNotEmpty) {
                        final Uri phoneUri = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No dialer app found.')));
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message, color: Colors.red.shade600),
                    label: Text('Message', style: TextStyle(color: Colors.red.shade600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      String phone = (data['phone'] ?? '').replaceAll(RegExp(r'\s+'), '');
                      if (phone.isNotEmpty) {
                        final Uri smsUri = Uri.parse('sms:$phone');
                        if (await canLaunchUrl(smsUri)) {
                          await launchUrl(smsUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No messaging app found.')));
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share, color: Colors.red),
                    label: const Text('Share', style: TextStyle(color: Colors.red)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final shareText =
                          'Donor: ${data['name']}, Blood Group: ${data['bloodGroup']}, Phone: ${data['phone']}, City: ${data['city']}';
                      Share.share(shareText);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    String selectedReason = 'Wrong Number';
                    final reason = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Report Donor'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Name: ${data['name']}'),
                              Text('Phone: ${data['phone']}'),
                              const SizedBox(height: 12),
                              DropdownButton<String>(
                                value: selectedReason,
                                isExpanded: true,
                                items: [
                                  'Wrong Number',
                                  'Using someone else\'s identity',
                                  'Donor location changed',
                                  'Donated recently',
                                  'Cannot donate anymore'
                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (value) => setState(() => selectedReason = value!),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('Submit'),
                              onPressed: () => Navigator.pop(context, selectedReason),
                            ),
                          ],
                        );
                      },
                    );
                    if (reason != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reported for: $reason')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Report',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
