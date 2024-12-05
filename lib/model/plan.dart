import 'package:hive/hive.dart';

part 'plan.g.dart';

@HiveType(typeId: 1) // typeId harus unik untuk setiap model Hive
class Plan extends HiveObject {
  @HiveField(0)
  String destination;

  @HiveField(1)
  String location;

  @HiveField(2)
  String departureDate;

  @HiveField(3)
  String departureTime;

  Plan({
    required this.destination,
    required this.location,
    required this.departureDate,
    required this.departureTime,
  });
}
