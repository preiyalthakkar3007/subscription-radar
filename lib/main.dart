import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/subscription.dart';
import 'screens/add_subscription.dart';
import 'screens/subscription_details.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  await Hive.openBox<Subscription>('subscriptions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);

    return MaterialApp(
      title: 'Subscription Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  double _monthlyCost(Subscription s) {
    final isYearly = s.cycle.toLowerCase().startsWith('y');
    return isYearly ? (s.cost / 12.0) : s.cost;
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Subscription>('subscriptions');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Radar'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Subscription> b, _) {
          final subs = b.values.toList();
          final keys = b.keys.cast<int>().toList();

          if (subs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 54, color: scheme.primary),
                    const SizedBox(height: 12),
                    const Text(
                      'No subscriptions yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap Add to create one.\nThen tap a card for details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          double totalMonthly = 0;
          double totalYearly = 0;
          int dueSoon = 0;
          int cancelled = 0;

          final now = DateTime.now();

          for (final s in subs) {
            totalMonthly += _monthlyCost(s);

            final isYearly = s.cycle.toLowerCase().startsWith('y');
            totalYearly += isYearly ? s.cost : (s.cost * 12);

            final diffDays = s.nextDueDate.difference(now).inDays;
            if (diffDays >= 0 && diffDays <= 7) dueSoon++;

            if (s.isCancelled) cancelled++;
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                // Small summary tiles (what you asked for)
                Row(
                  children: [
                    _MiniStat(
                      title: 'Monthly',
                      value: '₹${totalMonthly.toStringAsFixed(0)}',
                      icon: Icons.payments,
                    ),
                    const SizedBox(width: 10),
                    _MiniStat(
                      title: 'Yearly',
                      value: '₹${totalYearly.toStringAsFixed(0)}',
                      icon: Icons.calendar_month,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MiniStat(
                      title: 'Due (7d)',
                      value: '$dueSoon',
                      icon: Icons.event,
                      accent: scheme.tertiaryContainer,
                    ),
                    const SizedBox(width: 10),
                    _MiniStat(
                      title: 'Cancelled',
                      value: '$cancelled',
                      icon: Icons.block,
                      accent: scheme.errorContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: ListView.builder(
                    itemCount: subs.length,
                    itemBuilder: (context, i) {
                      final s = subs[i];
                      final due = s.nextDueDate.toLocal().toString().split(' ').first;

                      final tileColor = s.isCancelled
                          ? scheme.errorContainer.withOpacity(0.35)
                          : scheme.surfaceContainerHighest;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubscriptionDetailsScreen(subKey: keys[i]),
                              ),
                            );
                          },
                          onLongPress: () async {
                            final sure = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete subscription?'),
                                content: Text('Delete "${s.subName}"?'),
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
                              await b.delete(keys[i]);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: scheme.primaryContainer,
                                  child: Text(
                                    s.subName.isNotEmpty ? s.subName[0].toUpperCase() : '?',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.subName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (s.isCancelled)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: scheme.errorContainer,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: const Text(
                                                'Cancelled',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${s.cycle} • Due: $due • ${s.category}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${s.cost.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '≈ ₹${_monthlyCost(s).toStringAsFixed(0)}/mo',
                                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accent;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent ?? scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
