import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String title;
  final String description;
  final String patientId;
  final DateTime date;
  final TimeOfDay time;
  final String? doctor;
  final String? location;
  final String? notes;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.patientId,
    required this.date,
    required this.time,
    this.doctor,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'patientId': patientId,
      'date': date,
      'hour': '${time.hour}:${time.minute}',
      'doctor': doctor,
      'location': location,
      'notes': notes,
      'createdAt': DateTime.now(),
    };
  }
}
