class User {
  const User({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.isDoctor,
  });

  final String uid;
  final String name;
  final String phoneNumber;
  final bool isDoctor;
}
