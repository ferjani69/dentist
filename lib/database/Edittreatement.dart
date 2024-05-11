import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:search/models/treatement.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient.dart';

class edittreatment extends StatefulWidget {
  final Treatement treatement1;
  final Function(Treatement) onUpdate;
  final Patient patient;
  const edittreatment({super.key, required this.treatement1, required this.onUpdate,required this.patient});


  @override
  State<edittreatment> createState() => _edittreatmentState();
}
late TextEditingController dateController;

String date='';
class _edittreatmentState extends State<edittreatment> {
  @override
  void initState() {
    super.initState();
    // Initialize the date controller with formatted date or empty if null
    dateController = TextEditingController(
        text: widget.treatement1.datetreat != null
            ? DateFormat('yyyy-MM-dd').format(widget.treatement1.datetreat!)
            : ''
    );
  }
  void updateTreatmentInFirestore() {
    if (widget.treatement1.id == null) {
      // Handle error: treatement ID should not be null
      if (kDebugMode) {
        print("Error: No Treatement ID available for updating.");
      }
      return;
    }

    FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.patient.id) // The patient's ID
        .collection('treatements').doc(widget.treatement1.id).update({
      'treatDate': widget.treatement1.datetreat != null ? DateFormat('yyyy-MM-dd').format(widget.treatement1.datetreat!) : null,
      'dent': widget.treatement1.dent,
      'Natureintrv': widget.treatement1.natureinterv,
      'Notes': widget.treatement1.notes,
      'doit': widget.treatement1.doit,
      'recu': widget.treatement1.recu,
    }).then((_) {
      if (kDebugMode) {
        print("Patient updated successfully in Firestore.");
      }
      widget.onUpdate(widget.treatement1);  // Update the local data
      Navigator.pop(context);  // Optionally pop back
    }).catchError((error) {
      if (kDebugMode) {
        print("Error updating patient: $error");
      }
      // Optionally show an error message to the user
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  void _showDatePicker() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(dateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2080),
    );
    if (selectedDate != null) {
      setState(() {
        // Update the date controller with the new date
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        // Update the treatment object if needed
        widget.treatement1.datetreat = selectedDate;
      });
    }
  }
  final _formKey = GlobalKey<FormState>();

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECF9FF),
      appBar: AppBar(

        backgroundColor: const Color(0xff91C8E4),
        title: const Text('Edit Treatement'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.treatement1.dent,
                  decoration: InputDecoration(
                      labelText: 'Tooth',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    setState(() {
                      widget.treatement1.dent = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(

                      labelText: 'Treatement Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  controller: dateController,
                  onTap: _showDatePicker,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date';
                    }
                    // Additional validation can be performed here
                    return null;
                  },
                ),


                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.treatement1.natureinterv.toString(),
                  decoration: InputDecoration(
                      labelText: 'Nature Intervention',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    setState(() {
                      widget.treatement1.natureinterv = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  initialValue: widget.treatement1.notes,
                  decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    setState(() {
                      widget.treatement1.notes = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.treatement1.doit.toString(),
                  decoration: InputDecoration(
                      labelText: 'Charge',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    setState(() {
                      widget.treatement1.doit = int.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: widget.treatement1.recu.toString(),
                  decoration: InputDecoration(
                      labelText: 'Payment',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    setState(() {
                      widget.treatement1.recu =int.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Center(
                  child:  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff91C8E4)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateTreatmentInFirestore(); // Call the function with parentheses
                        widget.onUpdate(widget.treatement1);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

