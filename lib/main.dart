import 'package:flutter/material.dart';
import 'package:search/screens/AddPatientPage.dart';
import 'package:search/Widgets/Drawerwidget.dart';
import 'package:search/screens/edit_patient_page.dart';
import 'package:search/screens/ViewPatientPage.dart';
// Import the AppDrawer widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:search/screens/splash_screen.dart';

import 'models/patient.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return  const MaterialApp(
      home: SplashScreen(),    );
  }
}


class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.patientadd});

  final dynamic patientadd;

  @override
  State<SearchPage> createState() => _SearchPageState();
}
List<Patient> allPatients = [];

class _SearchPageState extends State<SearchPage> {
  List<Patient> display_list = [];  // This holds the list of patients displayed in the UI

  @override
  void initState() {
    super.initState();

    fetchPatients();  // Fetch data when the widget initializes
  }

  void fetchPatients() async {
    FirebaseFirestore.instance.collection("Patients").get().then((querySnapshot) {
      List<Patient> tempList = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        Patient patient = Patient.fromFirestore(data, doc.id);
        tempList.add(patient);
      }
      setState(() {
        allPatients = tempList; // Store all patients
        display_list = List.from(allPatients); // Set display_list to all patients initially
      });
    }).catchError((error) {
    });
  }

  void updatelist(String value) {
    setState(() {
      display_list = allPatients.where((element) {
        final pname = element.pname?.toLowerCase() ?? '';
        final telnum = element.telnum?.toString().toLowerCase() ?? '';

        return pname.contains(value.toLowerCase()) || telnum.contains(value.toLowerCase());
      }).toList();
    });
  }


  void editPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientPage(
          patient: patient,
          onUpdate: updatePatientList,
        ),
      ),
    );
  }

  void updatePatientList(Patient updatedPatient) {
    setState(() {
      int index = display_list.indexWhere((patient) => patient.id == updatedPatient.id);
      if (index != -1) {
        display_list[index] = updatedPatient;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF6F4EB),
      appBar: AppBar(
        backgroundColor: const Color(0xff91C8E4),
        elevation: 0.0,
      ),
      drawer: const Drawerw(), // Use the AppDrawer widget here

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Search for a Patient ",
                style: TextStyle(
                  color: Color(0xff4682A9),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.00,),
            Row(
              children: [
                Expanded(
                  child: TextField(

                    onChanged: (value) => updatelist(value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xff91C8E4),
                      hintText: "Chercher un Patient...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPatientPage(
                          patientadd: (newPatient) {
                            setState(() {
                              display_list.add(newPatient);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  color: const Color(0xff91C8E4),
                  iconSize: 30,
                ),
              ],
            ),
            const SizedBox(height: 10.00,),
            Expanded(
              child: ListView.builder(
                itemCount: display_list.length,

                itemBuilder: (BuildContext context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewPatientPage(patient: display_list[index]),
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: const Color(0xffECF9FF),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  display_list[index].pname.toString(),
                                  style: const TextStyle(
                                    color: Color(0xff4682A9),
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  display_list[index].plname.toString(),
                                  style: const TextStyle(color: Color(0xff4682A9)),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              "${display_list[index].telnum}",
                              style: const TextStyle(fontSize: 18.0, color: Color(0xff4682A9)),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: const Color(0xff4682A9),
                                  onPressed: () => editPatientDetails(display_list[index]),
                                ),
                                IconButton(

                                  onPressed: () {
                                    Patient patient = display_list[index];

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this patient?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  display_list.removeAt(index); // Remove from Firestore
                                                  if (patient.id != null && patient.id!.isNotEmpty) {
                                                    FirebaseFirestore.instance.collection("Patients")
                                                        .doc(patient.id)
                                                        .delete()
                                                        .then((_) {
                                                    })
                                                        .catchError((error) {
                                                      // Optionally, re-add the patient to the local list if the deletion failed
                                                      setState(() {
                                                        display_list.insert(index, patient);
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Failed to delete patient from cloud.'))
                                                      );
                                                    });
                                                  }
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}