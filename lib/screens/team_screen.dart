import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team_member.dart';
import '../widgets/team_avatar.dart';

class TeamScreen extends StatelessWidget {
   TeamScreen({super.key});

  final List<TeamMember> teamMembers = [
    TeamMember(
      id: '1',
      name: 'John Doe',
      email: 'john@company.com',
      role: 'Frontend Developer',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    ),
     TeamMember(
      id: '2',
      name: 'Sarah Smith',
      email: 'sarah@company.com',
      role: 'Backend Developer',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
     TeamMember(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@company.com',
      role: 'UI/UX Designer',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
     TeamMember(
      id: '4',
      name: 'Emma Wilson',
      email: 'emma@company.com',
      role: 'Product Manager',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: TeamAvatar(
                imageUrl: member.avatarUrl,
                name: member.name,
                isActive: member.isActive,
              ),
              title: Text(
                member.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.role),
                  Text(
                    member.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.message, size: 20),
                        SizedBox(width: 8),
                        Text('Message'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.task_alt, size: 20),
                        SizedBox(width: 8),
                        Text('Assign Task'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}