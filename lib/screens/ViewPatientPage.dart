import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:search/screens/treatement_records_page.dart';

import '../models/patient.dart';

class ViewPatientPage extends StatelessWidget {
  final Patient patient;

  const ViewPatientPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: const Color(0xff91C8E4),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff97cce7),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TreatmentRecordsPage(patient: patient, addtreat: (treatement ) {  },)),
                      );
                    },
                    child: const Text(
                      'View Treatments',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff97cce7),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    onPressed: () {

                    },
                    child: const Text(
                      'View Appointments',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0), // Add some space between buttons and patient details
              _buildInfoItem(title: 'First Name', value: patient.pname ?? "N/A"),
              _buildInfoItem(title: 'Last Name', value: patient.plname ?? "N/A"),
              _buildInfoItem(title: 'Phone Number', value: patient.telnum?.toString() ?? "N/A"),
              _buildInfoItem(
                title: 'Date of Birth',
                value: patient.daten != null ? DateFormat('yyyy-MM-dd').format(patient.daten!) : 'N/A',
              ),
              _buildInfoItem(title: 'Address', value: patient.adress ?? "N/A"),
              _buildInfoItem(title: 'Profession', value: patient.proff ?? "N/A"),
              _buildInfoItem(title: 'Reference', value: patient.ref ?? "N/A"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String title, required String value}) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xffECF9FF),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xff4682A9),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 18.0, color: Color(0xff4682A9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
