import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBanksScreen extends StatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  State<BloodBanksScreen> createState() => _BloodBanksScreenState();
}


class _BloodBanksScreenState extends State<BloodBanksScreen> {
  List<Map<String, dynamic>> bloodBanks = [];
  List<Map<String, dynamic>> filteredBanks = [];

  String searchQuery = "";
  String? selectedState;
  String? selectedCity;
  List<String> states = [];
  List<String> cities = [];
  // Hardcoded state-city data (replace with your provided data)
  Map<String, List<String>> locationData = {
    "Andhra Pradesh": [
      "Visakhapatnam","Vijayawada","Guntur","Nellore","Kurnool",
      "Rajahmundry","Tirupati","Anantapur","Kadapa","Eluru",
      "Ongole","Srikakulam","Chittoor","Vizianagaram","Tenali",
      "Proddatur","Adoni","Nandyal","Machilipatnam","Hindupur",
      "Bhimavaram","Gudivada","Tadepalligudem","Amalapuram","Narasaraopet"
    ],
    "Telangana": [
      "Hyderabad","Warangal","Nizamabad","Karimnagar","Khammam",
      "Ramagundam","Mahbubnagar","Nalgonda","Adilabad","Miryalaguda",
      "Siddipet","Suryapet","Jagityal","Mancherial","Bodhan",
      "Jangaon","Medak","Vikarabad","Zaheerabad","Sangareddy",
      "Kamareddy","Tandur","Bellampalle","Bhongir","Palwancha"
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
    // Add more states and cities as needed
  };

  @override
  void initState() {
    super.initState();
    // Initialize states and cities from hardcoded data
    states = locationData.keys.toList()..sort();
    if (states.isNotEmpty) {
      selectedState ??= states.first;
      cities = locationData[selectedState] ?? [];
      selectedCity = null;
    }
    fetchBloodBanks();
  }

  Future<void> fetchBloodBanks() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('blood_banks').get();
      final data = snapshot.docs.map((e) => e.data()).toList();
      bloodBanks = data.cast<Map<String, dynamic>>();
      filterBanks();
      setState(() {});
    } catch (e) {
      print("Error fetching blood banks: $e");
    }
  }

  void filterBanks() {
    filteredBanks = bloodBanks.where((bank) {
      final nameMatch = bank['name']
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
      final cityMatch = bank['city']
              ?.toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
      final stateMatch = selectedState == null || bank['state'] == selectedState;
      final cityFilterMatch = selectedCity == null || bank['city'] == selectedCity;
      return (nameMatch || cityMatch) && stateMatch && cityFilterMatch;
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Nearby Blood Banks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "${filteredBanks.length} found",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // State Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedState,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "State",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: states.map((state) => DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedState = value;
                          cities = locationData[selectedState] ?? [];
                          selectedCity = null;
                        });
                        filterBanks();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // City Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "City",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: cities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                      filterBanks();
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                onChanged: (value) {
                  searchQuery = value;
                  filterBanks();
                },
                decoration: InputDecoration(
                  hintText: "Search by name or city",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredBanks.isEmpty
                  ? const Center(child: Text("No blood banks found."))
                  : ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        return _buildModernBloodBankCard(bank);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBloodBankCard(Map<String, dynamic> bank) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusBadge("Open", color: Colors.red.shade600),
              const SizedBox(width: 8),
              if (bank['distance'] != null)
                Text(
                  "${bank['distance']} km",
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bank['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  bank['address'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text("24/7", style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.call, color: Colors.black87),
                  label: const Text("Call", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _launchPhone(bank['phone']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation, color: Colors.white),
                  label: const Text("Navigate", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _openMap(bank['latitude'], bank['longitude']),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.12) ?? Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.red.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  void _launchPhone(String? number) async {
    if (number != null && number.trim().isNotEmpty) {
      final url = Uri.parse("tel:$number");
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No dialer app found.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to launch dialer.')));
      }
    }
  }

  void _openMap(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    final googleMapsUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No maps app found.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open maps.')));
    }
  }
}
