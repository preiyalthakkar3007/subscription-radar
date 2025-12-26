import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  String subName;

  @HiveField(1)
  double cost;

  @HiveField(2)
  String cycle; // monthly / yearly

  @HiveField(3)
  int nextDueMs; // milliseconds since epoch

  @HiveField(4)
  String category;

  Subscription({
    required this.subName,
    required this.cost,
    required this.cycle,
    required this.nextDueMs,
    this.category = 'Other',
  });

  DateTime get nextDueDate => DateTime.fromMillisecondsSinceEpoch(nextDueMs);
}
