class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final bool isActive;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    this.isActive = true,
  });
}