import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wisata/Pages/itinerary_page.dart';
import '../model/plan.dart';
import '../model/travelhistory.dart';

class TravelHistoryPage extends StatefulWidget {
  final Plan plan; // Model `Plan`
  final int index; // Indeks dari daftar plan

  TravelHistoryPage({required this.plan, required this.index});

  @override
  _TravelHistoryPageState createState() => _TravelHistoryPageState();
}

class _TravelHistoryPageState extends State<TravelHistoryPage> {
  late TextEditingController impressionController;
  late TextEditingController storyController;
  late Box<TravelHistory> historyBox;
  late Box<Plan> planBox;

  @override
  void initState() {
    super.initState();
    impressionController = TextEditingController();
    storyController = TextEditingController();
    historyBox = Hive.box<TravelHistory>('travel_history');
    planBox = Hive.box<Plan>('plans');
  }

  void saveTravelHistory() {
    try {
      // Buat objek TravelHistory
      final travelHistory = TravelHistory(
        plan: widget.plan, // Simpan objek Plan
        impression: impressionController.text,
        story: storyController.text,
      );

      // Simpan travel history di Hive
      historyBox.add(travelHistory);

      // Hapus plan dari daftar
      planBox.deleteAt(widget.index);

      // Tampilkan notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Travel history saved successfully!')),
      );

      // Tutup halaman setelah berhasil menyimpan
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ItineraryPage()));
    } catch (e) {
      // Tangani error dan tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save travel history: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Travel History')),
      body: Stack(
        children: [
          Container(
            color: Colors.lightBlue[100],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Destination: ${widget.plan.destination}"),
                Text("Location: ${widget.plan.location}"),
                SizedBox(height: 16),
                TextField(
                  controller: impressionController,
                  decoration: InputDecoration(labelText: 'Impression'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: storyController,
                  decoration: InputDecoration(labelText: 'Story'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveTravelHistory,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
