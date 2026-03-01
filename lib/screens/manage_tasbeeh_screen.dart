import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dhikr.dart';
import '../providers/tasbeeh_provider.dart';
import '../utils/app_theme.dart';

class ManageTasbeehScreen extends StatelessWidget {
  const ManageTasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<TasbeehProvider>(
          builder: (context, tasbeeh, _) {
            return Column(
              children: [
                _buildHeader(context),
                _buildProgressCard(tasbeeh),
                Expanded(child: _buildDhikrList(context, tasbeeh)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<TasbeehProvider>(
        builder: (context, tasbeeh, _) {
          return FloatingActionButton(
            onPressed: () => _showAddDialog(context, tasbeeh),
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add, color: Colors.black),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.surfaceLight.withAlpha(128))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Manage Tasbeeh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(TasbeehProvider tasbeeh) {
    final completed = tasbeeh.dhikrs.where((d) => d.isComplete).length;
    final total = tasbeeh.dhikrs.length;
    final progress = (tasbeeh.dailyProgress * 100).toInt();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162E1C), Color(0xFF0F2415)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAILY TARGETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('$progress%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$completed of $total completed', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: tasbeeh.dailyProgress,
                    backgroundColor: AppTheme.backgroundDark,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withAlpha(25),
              border: Border.all(color: AppTheme.primary.withAlpha(76), width: 2),
            ),
            child: Icon(Icons.spa, size: 36, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrList(BuildContext context, TasbeehProvider tasbeeh) {
    if (tasbeeh.dhikrs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text('No dhikrs yet', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
            const SizedBox(height: 4),
            Text('Tap + to add your first dhikr', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasbeeh.dhikrs.length,
      itemBuilder: (context, index) {
        final dhikr = tasbeeh.dhikrs[index];
        return Dismissible(
          key: Key(dhikr.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(50),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.redAccent),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.surfaceDark2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Delete Dhikr?', style: TextStyle(color: Colors.white)),
                content: Text('Remove "${dhikr.name}" from your list?', style: TextStyle(color: Colors.grey[400])),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
                ],
              ),
            );
          },
          onDismissed: (_) => tasbeeh.removeDhikr(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.surfaceLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dhikr.isComplete ? AppTheme.primary.withAlpha(25) : AppTheme.backgroundDark,
                  ),
                  child: Icon(
                    dhikr.isComplete ? Icons.check : Icons.spa,
                    size: 22,
                    color: dhikr.isComplete ? AppTheme.primary : Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dhikr.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (dhikr.translation.isNotEmpty)
                        Text(dhikr.translation, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: dhikr.progress,
                          backgroundColor: AppTheme.backgroundDark,
                          valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showEditDialog(context, tasbeeh, index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${dhikr.count}/${dhikr.target}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      const SizedBox(height: 2),
                      Icon(Icons.edit, size: 14, color: Colors.grey[500]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, TasbeehProvider tasbeeh) {
    final nameController = TextEditingController();
    final translationController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Dhikr', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Dhikr Name', hintStyle: TextStyle(color: Colors.grey[600])),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: translationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Translation', hintStyle: TextStyle(color: Colors.grey[600])),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Target Count', hintStyle: TextStyle(color: Colors.grey[600])),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    tasbeeh.addDhikr(Dhikr(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      translation: translationController.text,
                      target: int.tryParse(targetController.text) ?? 33,
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Dhikr', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TasbeehProvider tasbeeh, int index) {
    final dhikr = tasbeeh.dhikrs[index];
    final targetController = TextEditingController(text: '${dhikr.target}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit ${dhikr.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Target Count',
                labelStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newTarget = int.tryParse(targetController.text);
                  if (newTarget != null && newTarget > 0) {
                    tasbeeh.updateTarget(index, newTarget);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update Target', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
