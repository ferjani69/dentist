import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:search/screens/OCR0ptionsPage.dart';
import 'package:search/main.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../Widgets/Drawerwidget.dart'; // Import the AppDrawer widget
import '../Widgets/Voicett.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient.dart';
import '../models/ptientsList.dart';


class AddPatientPage extends StatefulWidget {

  final Function(Patient) patientadd; // Define the callback function

  const AddPatientPage({super.key, required this.patientadd});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController birthDateController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController professionController = TextEditingController();

  final TextEditingController referenceController = TextEditingController();

  void _showDatePicker() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2080),
    );
    if (selectedDate != null) {
      setState(() {
        final formattedDate= '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
        birthDateController.text = formattedDate;
      });
    }
  }

  void _submitForm() {
    if (_formkey.currentState!.validate()) {
      // Retrieve values from controllers
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String phoneNumber = phoneNumberController.text;
      String birthDateString = birthDateController.text; // Get the birth date string

      // Convert the birth date string into a DateTime object
      DateTime? birthdate;
      try {
        birthdate = DateFormat('yyyy-MM-dd').parse(birthDateString);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing birth date: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format. Please use YYYY-MM-DD.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit if the date parse fails
      }
      String formattedDate = DateFormat('yyyy-MM-dd').format(birthdate);

      String address = addressController.text;
      String profession = professionController.text;
      String reference = referenceController.text;

      // Create a new Patient object with the form data
      Patient newPatient = Patient(
        "unique_id", // Generate or assign a unique ID for the new patient
        firstName,
        lastName,
        int.parse(phoneNumber),
        birthdate, // Assign the parsed birth date
        address,
        profession,
        reference,
      );
      firstNameController.clear();
      lastNameController.clear();
      addressController.clear();
      professionController.clear();
      referenceController.clear();
      phoneNumberController.clear();
      birthDateController.clear();
      // Add the new patient to the patient_list
      widget.patientadd(newPatient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient added successfully'),
        ),
      );
      CollectionReference patients = FirebaseFirestore.instance.collection("Patients");
      patients.add({

        'firstname': firstName,
        'lastname': lastName,
        'phonenumber': phoneNumber,
        'dateOfBirth':formattedDate, // Firestore will handle DateTime correctly
        'address': address,
        'profession': profession,
        'reference': reference,
      }).then((docRef) {
        if (kDebugMode) {
          print("Document written with ID: ${docRef.id}");
        }
        // Update the ID of newPatient if necessary
        newPatient.id = docRef.id;
      }).catchError((error) {
        if (kDebugMode) {
          print("Error adding document: $error");
        }
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            patientadd: (newPatient) {
              setState(() {
                display_list.add(newPatient);
              });
            },
          ),
        ),
      );
    }else {
      // Show snackbar for invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your inputs'),
        ),
      );
    }
  }

  String? _validatePhonenumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }

    // Check if the value consists only of numeric characters
    if (!value.contains(RegExp(r'^[0-9]*$'))) {
      return 'Please enter a valid phone number (numbers only)';
    }

    // Check if the length of the phone number is not equal to 8 digits
    if (value.length != 8) {
      return 'Please enter a valid 8-digit phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECF9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff91C8E4),
        title: const Center(child: Text("Patient form")),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 30.0), // Adjust the padding as needed for spacing
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OCROptionsPage()),
              );
            },
            icon: const Icon(Icons.camera_alt),
          ),
        ],
      ),
      drawer: const Drawerw(), // Use the AppDrawer widget here


      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a last name";
                              }
                              // Check if the value contains only alphabetic characters
                              if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                                return "Please enter a valid last name containing only alphabetic characters";
                              }
                              return null;
                            },

                          ),

                        ),
                        Voicett(controller: firstNameController),
                      ],
                    ),

                    const SizedBox(height: 16.0),
                    // Other TextFormField widgets...



                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: lastNameController,
                        decoration: InputDecoration(
                            labelText: 'Last name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a last name";
                          }
                          // Check if the value contains only alphabetic characters
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return "Please enter a valid last name containing only alphabetic characters";
                          }
                          return null;
                        },

                      ),
                    ),
                    Voicett(controller: lastNameController),

                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                      
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: _validatePhonenumber,
                      ),
                    ),
                    Voicett(controller: phoneNumberController),

                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  onTap: _showDatePicker,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: birthDateController,
                  decoration: InputDecoration(
                      labelText: 'Birth Date (YYYY-MM-DD)', // Specify the expected format
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      )
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a birth date";
                    }
                    // Validate the date format using a regular expression
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return "Please enter a valid date in the format YYYY-MM-DD";
                    }
                    // Convert the string date into a DateTime object
                    try {
                      DateTime.parse(value);
                      return null; // Return null if the date is valid
                    } catch (e) {
                      return "Please enter a valid date in the format YYYY-MM-DD";
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: addressController,
                        decoration: InputDecoration(
                            labelText: 'Adresse ',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter an adress";
                          }
                          // Check if the value contains only alphabetic characters, spaces, and periods (.)
                          if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value)) {
                            return "Please enter a valid adress containing only alphabetic characters, spaces, and periods";
                          }
                          return null;
                        },

                      ),
                    ),
                    Voicett(controller: addressController),

                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: professionController,
                        decoration: InputDecoration(
                            labelText: 'Profession',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a profession";
                          }
                          // Check if the value contains only alphabetic characters
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return "Please enter a valid profession containing only alphabetic characters";
                          }
                          return null;
                        },

                      ),
                    ),
                    Voicett(controller: professionController),

                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: referenceController,
                        decoration: InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                      ),
                    ),
                    Voicett(controller: referenceController),

                  ],
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff91C8E4)),
                      onPressed: _submitForm,
                      child: const Text("Submit Your Patient")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
