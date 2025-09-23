import 'package:flutter/material.dart';

class TeamAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isActive;
  final double size;

  const TeamAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.isActive = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (_, __) {},
          child: imageUrl.isEmpty
              ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: size / 2.5),
          )
              : null,
        ),
        if (isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size / 4,
              height: size / 4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}