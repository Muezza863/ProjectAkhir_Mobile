import 'package:hive/hive.dart';

import 'plan.dart';

part 'travelhistory.g.dart';

@HiveType(typeId: 1)
class TravelHistory extends HiveObject {
  @HiveField(0)
  final Plan plan; // Menyimpan objek Plan

  @HiveField(1)
  final String impression;

  @HiveField(2)
  final String story;

  TravelHistory({
    required this.plan,
    required this.impression,
    required this.story,
  });
}
