import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String title;
  final String description;
  final String patientId;
  final String patientName;
  final DateTime date;
  final TimeOfDay time;

  // 🔹 OPCIONALES
  final String? doctor;
  final String? location;
  final String? notes;
  final List<String>? attachments;
  final DateTime? customReminder;
  final String? customReminderText;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.time,
    this.doctor,
    this.location,
    this.notes,
    this.attachments,
    this.customReminder,
    this.customReminderText,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'patientId': patientId,
      'patientName': patientName,
      'date': Timestamp.fromDate(date),
      'time': '${time.hour}:${time.minute}',
      'timestamp': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),

      //  OPCIONALES (solo si existen)
      if (doctor != null) 'doctor': doctor,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
      if (customReminder != null) 'customReminder': Timestamp.fromDate(customReminder!),
      if (customReminderText != null) 'customReminderText': customReminderText,
    };
  }

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timeParts = (data['time'] as String).split(':');

    return Appointment(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      patientId: data['patientId'],
      patientName: data['patientName'],
      date: (data['date'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      doctor: data['doctor'],
      location: data['location'],
      notes: data['notes'],
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : null,
      customReminder: data['customReminder'] != null
          ? (data['customReminder'] as Timestamp).toDate()
          : null,
      customReminderText: data['customReminderText'],
    );
  }
}
