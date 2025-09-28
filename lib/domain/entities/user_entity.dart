class UserEntity {
  final String uid;
  final String email;
  final String? displayName;

  UserEntity({required this.uid, required this.email, this.displayName});

  factory UserEntity.fromFirebaseUser(
    String uid,
    String email,
    String? displayName,
  ) {
    return UserEntity(uid: uid, email: email, displayName: displayName);
  }
}
