import 'package:hive/hive.dart';

part 'itinerary.g.dart';

@HiveType(typeId: 0)
class Itinerary {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String location;

  @HiveField(2)
  final String description;

  Itinerary({required this.date, required this.location, required this.description});
}
