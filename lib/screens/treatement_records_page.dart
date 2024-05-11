import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:search/models/treatement.dart'; // Corrected import statement
import 'package:search/models/treatmentlist.dart';
import '../database/Edittreatement.dart';
// Import the AppDrawer widget
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient.dart';

// Adjust import as necessary





// Corrected import statement

class TreatmentRecordsPage extends StatefulWidget {
  final Patient patient;
  final Function(Treatement) addtreat; // Accepting the addtreat function


  const TreatmentRecordsPage({super.key, required this.patient, required this.addtreat,});

  @override
  State<TreatmentRecordsPage> createState() => _TreatmentRecordsPageState();
}

class _TreatmentRecordsPageState extends State<TreatmentRecordsPage> {
  void edittreatmentdetails(Treatement treat, {required Patient patient}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => edittreatment(
          patient: widget.patient,
          treatement1: treat,
          onUpdate: (updatedtreat) => setState(() {
            int index1 = display_list1.indexWhere((t) => t.id == updatedtreat.id);
            if (index1 != -1) {
              display_list1[index1] = updatedtreat;
            }
          }),
        ),
      ),
    );
  }

  void updateList1(String value) {
    // Update displayed treatments by applying filters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment Records - ${widget.patient.pname} ${widget.patient.plname}'),
        backgroundColor: const Color(0xff91C8E4),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const Center(
        child: Text(
        "Search for a Treatment",
          style: TextStyle(
            color: Color(0xff4682A9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 10.0),
      TextField(
        onChanged: (value) => updateList1(value),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xff91C8E4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          hintText: "e.g., Detartrage",
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: Colors.white,
          suffixIcon: IconButton(
            onPressed: () async {
            },
            icon: const Icon(Icons.add_box_rounded),
            color: Colors.white,
            iconSize: 30,
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      Text(
        'Treatments for ${widget.patient.pname} ${widget.patient.plname}:',
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff4682A9)),
      ),
      const SizedBox(height: 16.0), Expanded(
        child: StreamBuilder<QuerySnapshot>(
          // Query the patient's treatments subcollection
          stream: FirebaseFirestore.instance
              .collection('Patients')
              .doc(widget.patient.id) // The patient's ID
              .collection('treatements') // Subcollection for treatments
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No treatments found"));
            }

            List<Treatement> treatments = snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              try {
                return Treatement.fromFirestore(data, doc.id); // Ensure this conversion is correct
              } catch (e) {
                if (kDebugMode) {
                  print("Error parsing data: $e");
                }
                return null;
              }
            }).where((t) => t != null).cast<Treatement>().toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [



                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: treatments.length,
                      itemBuilder: (context, index1) {
                        final treatment = treatments[index1];
                        return _buildTreatmentItem(treatment, index1);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ])));
  }

  Widget _buildTreatmentItem(Treatement treatment, int index1) {
    return Card(
      color: const Color(0xffECF9FF),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(treatment.datetreat!)}',
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color(0xff4682A9)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: const Color(0xff4682A9),
                  onPressed: () => edittreatmentdetails(treatment, patient: widget.patient
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this treatment?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (treatment.id != null && treatment.id!.isNotEmpty) {
                                  // Delete treatment from the patient's treatments subcollection
                                  FirebaseFirestore.instance
                                      .collection('Patients')
                                      .doc(widget.patient.id) // Patient's document
                                      .collection('treatements') // Treatments subcollection
                                      .doc(treatment.id)
                                      .delete()
                                      .then((_) {
                                    if (kDebugMode) {
                                      print("Treatment successfully deleted from Firestore!");
                                    }
                                  })
                                      .catchError((error) {
                                    if (kDebugMode) {
                                      print("Error removing document: $error");
                                    }
                                  });
                                }
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
            const SizedBox(height: 8.0),
            Text(
              'Dent: ${treatment.dent}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color(0xff4682A9)),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Nature of Intervention: ${treatment.natureinterv}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color(0xff4682A9)),
            ),
          ],
        ),
      ),
    );
  }
}
