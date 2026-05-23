import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lock_provider.dart';
import '../widgets/app_tile.dart';

class AppListScreen extends StatelessWidget {
  const AppListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LockProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Lock'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'all') p.lockAll();
              if (v == 'none') p.unlockAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Lock all')),
              PopupMenuItem(value: 'none', child: Text('Unlock all')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: p.search,
            ),
          ),
          Expanded(
            child: p.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: p.apps.length,
                    itemBuilder: (_, i) => AppTile(
                      app: p.apps[i],
                      onToggle: p.toggle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}