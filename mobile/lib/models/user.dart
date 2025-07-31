import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('SUPER_ADMIN')
  superAdmin,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('USER')
  user,
}

@JsonSerializable()
class User {
  final String id;
  final String username;
  final UserRole role;
  final bool? isActive; // Make nullable to handle missing data
  final DateTime? createdAt; // Make nullable
  final DateTime? updatedAt; // Make nullable

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final User user;

  const LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
