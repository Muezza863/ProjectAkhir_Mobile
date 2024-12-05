import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './../model/plan.dart';
import './plandetail_page.dart'; // Import halaman detail

class ItineraryPage extends StatefulWidget {
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  late Box<Plan> planBox;

  @override
  void initState() {
    super.initState();
    planBox = Hive.box<Plan>('plans');
  }

  // Fungsi untuk menghapus item
  Future<void> deletePlan(int index) async {
    await planBox.deleteAt(index);
    setState(() {}); // Refresh widget after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan deleted')),
    );
  }

  // Fungsi untuk menampilkan pop-up konfirmasi sebelum menghapus
  Future<void> _showDeleteConfirmationDialog(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this plan?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deletePlan(index); // Proceed with deletion
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue[200],
        title: Text(
          'Itinerary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.lightBlue[100],
          ),
          ValueListenableBuilder(
            valueListenable: planBox.listenable(),
            builder: (context, Box<Plan> box, _) {
              if (box.isEmpty) {
                return Center(
                  child: Text(
                    "No Itineraries Planned",
                    style: TextStyle(fontSize: 30),
                  ),
                );
              }

              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final plan = box.getAt(index);
                  final DateTime departureDate =
                  DateTime.parse(plan!.departureDate);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlanDetailPage(
                                plan: plan,
                                index: index,
                              ),
                            ),
                          );
                        },
                        title: Text(plan.destination),
                        subtitle: Text(
                          "${plan.location}\nDeparture: ${plan.departureDate} at ${plan.departureTime} WIB",
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteConfirmationDialog(index); // Show confirmation dialog
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
