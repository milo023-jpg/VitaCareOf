class Patient {
  final String id;
  final String name;

  Patient({required this.id, required this.name});

  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    return Patient(id: id, name: data['name']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
