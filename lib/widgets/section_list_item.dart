import 'package:flutter/material.dart';

class SectionListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SectionListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
