import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final double progress;
  final List<String> teamMembers;
  final DateTime dueDate;
  final bool isVertical;

  const ProjectCard({
    super.key,
    required this.title,
    required this.progress,
    required this.teamMembers,
    required this.dueDate,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isVertical ? double.infinity : 200.0;
    final cardHeight = isVertical ? 160.0 : 240.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16),
              const SizedBox(width: 4),
              SizedBox(
                height: 24,
                child: Stack(
                  children: [
                    for (var i = 0; i < teamMembers.length; i++)
                      Positioned(
                        left: i * 16.0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            teamMembers[i][0],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM').format(dueDate),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : const Color(0xFFFFD233),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 