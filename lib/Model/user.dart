// user_model.dart
class User {
  final String username;
  final String password;

  User({required this.username, required this.password});

  User copyWith({String? username, String? password}) {
    return User(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
