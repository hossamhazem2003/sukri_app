class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password
  });

  /// Convert Firestore DocumentSnapshot to User
  factory User.fromDocument(Map<String, dynamic> doc, String id) {
    return User(
      id: id,
      firstName: doc['firstName'] ?? '',
      lastName: doc['lastName'] ?? '',
      username: doc['username'] ?? '',
      email: doc['email'] ?? '',
      password: doc['password'] ?? ''
    );
  }

  /// Convert User to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password
    };
  }
}
