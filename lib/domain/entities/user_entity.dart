class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime? createdAt;

  UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.createdAt,
  });

  factory UserEntity.fromFirebaseUser(
    String uid,
    String email,
    String? displayName, {
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: createdAt,
    );
  }

  // Convertir a Map para almacenamiento (Firestore, etc.)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Crear desde Map
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  // Método copyWith para actualizaciones inmutables
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserEntity &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoURL.hashCode;
  }
}