import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Patient {
  String? _id;
  String? _pname;
  String? _plname;
  int? _telnum;
  DateTime? _daten;
  String? _adress;
  String? _proff;
  String? _ref;

  Patient(this._id, this._pname, this._plname, this._telnum, this._daten, this._adress, this._proff, this._ref);

  // Getters and setters
  String? get ref => _ref;
  set ref(String? value) {
    _ref = value;
  }

  String? get id => _id;
  set id(String? value) {
    _id = value;
  }

  String? get proff => _proff;
  set proff(String? value) {
    _proff = value;
  }

  String? get adress => _adress;
  set adress(String? value) {
    _adress = value;
  }

  DateTime? get daten => _daten;
  set daten(DateTime? value) {
    _daten = value;
  }

  int? get telnum => _telnum;
  set telnum(int? value) {
    _telnum = value;
  }

  String? get plname => _plname;
  set plname(String? value) {
    _plname = value;
  }

  String? get pname => _pname;
  set pname(String? value) {
    _pname = value;
  }

  // Factory constructor to create a Patient from Firestore data
  factory Patient.fromFirestore(Map<String, dynamic> firestore, String documentId) {
    DateTime? birthDate;
    try {
      if (firestore['dateOfBirth'] != null) {
        birthDate = DateFormat('yyyy-MM-dd').parse(firestore['dateOfBirth']);
      }
    } catch (e) {
      print("Error parsing birth date: $e");
      birthDate = null;
    }

    return Patient(
      documentId,
      firestore['firstname'] as String?,
      firestore['lastname'] as String?,
      int.tryParse(firestore['phonenumber']?.toString() ?? ''),
      birthDate, // Now a DateTime object
      firestore['address'] as String?,
      firestore['profession'] as String?,
      firestore['reference'] as String?,
    );
  }}
