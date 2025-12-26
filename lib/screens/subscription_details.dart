import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/subscription.dart';
import 'add_subscription.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final int subKey;

  const SubscriptionDetailsScreen({super.key, required this.subKey});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Subscription>('subscriptions');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [subKey]),
      builder: (context, Box<Subscription> b, _) {
        final s = b.get(subKey);

        if (s == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Subscription')),
            body: const Center(child: Text('Subscription not found.')),
          );
        }

        final scheme = Theme.of(context).colorScheme;
        final due = s.nextDueDate.toLocal().toString().split(' ').first;

        return Scaffold(
          appBar: AppBar(
            title: Text(s.subName),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddSubscriptionScreen(
                        existing: s,
                        existingKey: subKey,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child: ListView(
              children: [
                _InfoTile(label: 'Cost', value: '₹${s.cost.toStringAsFixed(0)}'),
                _InfoTile(label: 'Cycle', value: s.cycle),
                _InfoTile(label: 'Next due', value: due),
                _InfoTile(label: 'Category', value: s.category),
                const SizedBox(height: 10),

                // Status / Cancel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.isCancelled
                        ? scheme.errorContainer
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.isCancelled ? 'Cancelled' : 'Active',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () async {
                          s.isCancelled = !s.isCancelled;
                          await s.save();
                        },
                        child: Text(s.isCancelled ? 'Resume' : 'Cancel'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Reminders (in-app setting)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Reminders',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Switch(
                            value: s.remindersOn,
                            onChanged: (v) async {
                              s.remindersOn = v;
                              await s.save();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: s.remindersOn ? 1 : 0.45,
                        child: Row(
                          children: [
                            const Text('Remind me '),
                            DropdownButton<int>(
                              value: s.remindDaysBefore,
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('1 day')),
                                DropdownMenuItem(value: 3, child: Text('3 days')),
                                DropdownMenuItem(value: 7, child: Text('7 days')),
                              ],
                              onChanged: s.remindersOn
                                  ? (v) async {
                                      if (v == null) return;
                                      s.remindDaysBefore = v;
                                      await s.save();
                                    }
                                  : null,
                            ),
                            const Text(' before due date'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '(Web demo) This stores your reminder preference. '
                        'Later we can add real notifications on mobile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Delete
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete subscription'),
                  onPressed: () async {
                    final sure = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete subscription?'),
                        content: Text('Delete "${s.subName}" permanently?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (sure == true) {
                      await b.delete(subKey);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
