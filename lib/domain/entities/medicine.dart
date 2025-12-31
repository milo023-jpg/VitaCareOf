import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MedicineScheduleType { fixed, interval }
enum MedicineRepeatType { daily, daysOfWeek }
enum MedicineDurationType { indefinite, days, until }

class Medicine {
  final String id;

  final String name;
  final String? description;
  final String? type;

  final String patientId;
  final String patientName;

  final bool isActive;

  final MedicineScheduleType scheduleType;

  // FIXED
  final TimeOfDay? time;
  final MedicineRepeatType? repeat;
  final List<int>? daysOfWeek; // 1=lun ... 7=dom (solo si repeat=daysOfWeek)

  // INTERVAL
  final int? intervalHours; // ej: 8
  final TimeOfDay? startTime; // desde esta hora corre cada X horas

  // DURACIÓN
  final MedicineDurationType durationType;
  final int? durationDays;
  final DateTime? endDate;

  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.patientId,
    required this.patientName,
    required this.scheduleType,
    required this.durationType,
    required this.createdAt,
    this.description,
    this.type,
    this.isActive = true,
    this.time,
    this.repeat,
    this.daysOfWeek,
    this.intervalHours,
    this.startTime,
    this.durationDays,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'patientId': patientId,
      'patientName': patientName,
      'isActive': isActive,
      'scheduleType': scheduleType.name,
      'durationType': durationType.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (description != null) 'description': description,
      if (type != null) 'type': type,
    };

    if (scheduleType == MedicineScheduleType.fixed) {
      final t = time!;
      map['time'] = '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
      map['repeat'] = (repeat ?? MedicineRepeatType.daily).name;
      if (repeat == MedicineRepeatType.daysOfWeek && daysOfWeek != null) {
        map['daysOfWeek'] = daysOfWeek;
      }

      // timestamp para ordenar por hora
      map['timestamp'] = t.hour * 60 + t.minute;
    } else {
      final st = startTime!;
      map['intervalHours'] = intervalHours;
      map['startTime'] = '${st.hour}:${st.minute.toString().padLeft(2, '0')}';

      // timestamp para ordenar (por hora inicio)
      map['timestamp'] = st.hour * 60 + st.minute;
    }

    if (durationType == MedicineDurationType.days) {
      map['durationDays'] = durationDays;
    } else if (durationType == MedicineDurationType.until) {
      map['endDate'] = Timestamp.fromDate(endDate!);
    }

    return map;
  }

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TimeOfDay? parseTime(String? s) {
      if (s == null) return null;
      final parts = s.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    final scheduleType =
        MedicineScheduleType.values.byName(data['scheduleType'] ?? 'fixed');

    final durationType =
        MedicineDurationType.values.byName(data['durationType'] ?? 'indefinite');

    return Medicine(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      type: data['type'],
      patientId: data['patientId'],
      patientName: data['patientName'],
      isActive: data['isActive'] ?? true,
      scheduleType: scheduleType,
      time: scheduleType == MedicineScheduleType.fixed ? parseTime(data['time']) : null,
      repeat: scheduleType == MedicineScheduleType.fixed
          ? MedicineRepeatType.values.byName(data['repeat'] ?? 'daily')
          : null,
      daysOfWeek: data['daysOfWeek'] != null
          ? List<int>.from(data['daysOfWeek'])
          : null,
      intervalHours: scheduleType == MedicineScheduleType.interval
          ? (data['intervalHours'] as num?)?.toInt()
          : null,
      startTime: scheduleType == MedicineScheduleType.interval
          ? parseTime(data['startTime'])
          : null,
      durationType: durationType,
      durationDays: durationType == MedicineDurationType.days
          ? (data['durationDays'] as num?)?.toInt()
          : null,
      endDate: durationType == MedicineDurationType.until && data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
