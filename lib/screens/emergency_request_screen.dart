import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedBloodGroup;
  DateTime? selectedDate;
  String? selectedState;
  String? selectedCity;

  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final Map<String, List<String>> citiesByState = {
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
  };

  @override
  void initState() {
    super.initState();
    final states = citiesByState.keys.toList();
    if (states.isNotEmpty) {
      selectedState = states.first;
      if (citiesByState[selectedState]!.isNotEmpty) {
        selectedCity = citiesByState[selectedState]!.first;
      }
    }
    if (bloodGroups.isNotEmpty) {
      selectedBloodGroup = bloodGroups.first;
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('emergency_requests').add({
        'patient_name': patientNameController.text.trim(),
        'blood_group': selectedBloodGroup,
        'units_required': int.tryParse(unitsController.text.trim()) ?? 1,
        'required_on': selectedDate?.toIso8601String(),
        'hospital': hospitalController.text.trim(),
        'city': selectedCity,
        'state': selectedState,
        'contact_person': contactPersonController.text.trim(),
        'phone': phoneController.text.trim(),
        'notes': notesController.text.trim(),
        'posted_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emergency request posted!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> states = citiesByState.keys.toList();
    List<String> cities = selectedState != null ? citiesByState[selectedState]! : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Urgent Blood Needed?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill out the form below for immediate assistance.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                items: bloodGroups.map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (value) => setState(() => selectedBloodGroup = value),
                validator: (value) => value == null ? 'Please select a blood group' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: unitsController,
                decoration: const InputDecoration(
                  labelText: 'Units Required',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Required Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    selectedDate != null
                        ? DateFormat('yMMMd').format(selectedDate!)
                        : 'Select Date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Hospital / Location',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(
                  labelText: 'State',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                items: states.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value!;
                    selectedCity = citiesByState[selectedState]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) => setState(() => selectedCity = value!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person',
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Enter valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Post Emergency Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}