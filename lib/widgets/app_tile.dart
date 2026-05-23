import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppTile extends StatelessWidget {
  final AppInfo app;
  final ValueChanged<AppInfo> onToggle;

  const AppTile({super.key, required this.app, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final icon = app.icon != null ? MemoryImage(app.icon!) : null;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        backgroundImage: icon,
        child: icon == null ? const Icon(Icons.apps) : null,
      ),
      title: Text(app.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(app.packageName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11)),
      trailing: Switch(
        value: app.isLocked,
        onChanged: (_) => onToggle(app),
      ),
    );
  }
}