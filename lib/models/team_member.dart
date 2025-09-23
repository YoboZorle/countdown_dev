import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final Color avatarColor;
  final DateTime createdAt;

  TeamMember({
    String? id,
    required this.name,
    required this.email,
    required this.role,
    Color? avatarColor,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        avatarColor = avatarColor ?? _generateAvatarColor(name),
        createdAt = createdAt ?? DateTime.now();

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      avatarColor: Color(map['avatar_color']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar_color': avatarColor.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  static Color _generateAvatarColor(String name) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = name.hashCode % colors.length;
    return colors[index];
  }

  TeamMember copyWith({
    String? name,
    String? email,
    String? role,
    Color? avatarColor,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt,
    );
  }
}