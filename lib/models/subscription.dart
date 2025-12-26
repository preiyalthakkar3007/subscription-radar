import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  String subName;

  @HiveField(1)
  double cost;

  @HiveField(2)
  String cycle; // Monthly / Yearly

  @HiveField(3)
  int nextDueMs; // milliseconds since epoch

  @HiveField(4)
  String category;

  // NEW FIELDS (added at the end to avoid breaking old data)
  @HiveField(5)
  bool isCancelled;

  @HiveField(6)
  bool remindersOn;

  @HiveField(7)
  int remindDaysBefore; // e.g. 1, 3, 7

  Subscription({
    required this.subName,
    required this.cost,
    required this.cycle,
    required this.nextDueMs,
    this.category = 'Other',
    this.isCancelled = false,
    this.remindersOn = false,
    this.remindDaysBefore = 3,
  });

  DateTime get nextDueDate => DateTime.fromMillisecondsSinceEpoch(nextDueMs);
}
