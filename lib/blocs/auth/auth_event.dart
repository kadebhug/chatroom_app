import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  final String? phone;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, username, phone];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}
