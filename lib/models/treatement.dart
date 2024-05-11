import 'package:cloud_firestore/cloud_firestore.dart';

class Treatement {
  String? _id;
  DateTime? _datetreat;
  String? _dent;
  String? _natureinterv;
  String?_notes;
  String? _patientId;

  String? get patientId => _patientId;

  set patientId(String? value) {
    _patientId = value;
  }

  String? get notes => _notes;

  set notes(String? value) {
    _notes = value;
  }

  String? get id => _id;

  set id(String? value) {
    _id = value;
  }

  int? _doit;
  int? _recu;

  Treatement(this._id,this._datetreat, this._dent, this._natureinterv,this._notes, this._doit, this._recu,this._patientId);

  DateTime? get datetreat => _datetreat;

  set datetreat(DateTime? value) {
    _datetreat = value;
  }

  String? get dent => _dent;

  set dent(String? value) {
    _dent = value;
  }

  String? get natureinterv => _natureinterv;

  set natureinterv(String? value) {
    _natureinterv = value;
  }

  int? get doit => _doit;

  set doit(int? value) {
    _doit = value;
  }

  int? get recu => _recu;

  set recu(int? value) {
    _recu = value;
  }
  // Your fields and constructor

  factory Treatement.fromFirestore(Map<String, dynamic> data, String docId) {
    return Treatement(
      docId,
      data['treatDate'] is Timestamp
          ? (data['treatDate'] as Timestamp).toDate()
          : DateTime.parse(data['treatDate'] as String),
      data['dent'] as String?,
      data['Natureintrv'] as String?,
      data['Notes'] as String?,
      data['doit'] is int ? data['doit'] as int : int.parse(data['doit'].toString()), // Convert to int
      data['recu'] is int ? data['recu'] as int : int.parse(data['recu'].toString()), // Convert to int
      data['patientId'] as String, // New field
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'treatDate': datetreat?.toIso8601String(),
      'dent': dent,
      'Natureintrv': natureinterv,
      'Notes': notes,
      'doit': doit,
      'recu': recu,
      'patientId': patientId, // Add patientId to Firestore data
    };
  }

}



