import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wisata/Pages/travelhistory_page.dart';
import './../model/plan.dart';

class PlanDetailPage extends StatefulWidget {
  final Plan plan;
  final int index; // Menambahkan index

  PlanDetailPage({required this.plan, required this.index}); // Menerima index

  @override
  _PlanDetailPageState createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  final List<String> timeZones = ['WIB', 'WIT', 'WITA', 'London', 'New York', 'Tokyo'];
  String selectedTimeZone = 'WIB'; // Default zona waktu
  String convertedTime = '';

  @override
  void initState() {
    super.initState();
    convertedTime = widget.plan.departureTime; // Awalnya sama dengan waktu default (WIB)
  }

  String convertTime(String departureTime, String fromZone, String toZone) {
    // Peta offset zona waktu relatif terhadap UTC
    final timeZoneOffsets = {
      'WIB': 7,
      'WITA': 8,
      'WIT': 9,
      'London': 0,
      'New York': -5,
      'Tokyo': 9,
    };

    // Format waktu input dan output
    final timeFormat = DateFormat('HH:mm');

    try {
      // Parse waktu dari input
      DateTime parsedTime = timeFormat.parse(departureTime);

      // Tambahkan offset waktu zona asal (dari WIB ke UTC)
      DateTime utcTime = parsedTime.subtract(
        Duration(hours: timeZoneOffsets[fromZone]!),
      );

      // Konversi dari UTC ke zona waktu tujuan
      DateTime converted = utcTime.add(
        Duration(hours: timeZoneOffsets[toZone]!),
      );

      // Return hasil format waktu baru
      return timeFormat.format(converted);
    } catch (e) {
      return departureTime; // Return waktu asli jika terjadi error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text('Plan Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destination: ${widget.plan.destination}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Location: ${widget.plan.location}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Departure Date: ${widget.plan.departureDate}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Time Zone: ',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: selectedTimeZone,
                  onChanged: (newZone) {
                    setState(() {
                      selectedTimeZone = newZone!;
                      convertedTime = convertTime(
                        widget.plan.departureTime,
                        'WIB', // Asumsi default time zone dari Plan adalah WIB
                        selectedTimeZone,
                      );
                    });
                  },
                  items: timeZones.map((zone) {
                    return DropdownMenuItem(
                      value: zone,
                      child: Text(zone),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Departure Time: $convertedTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke TravelHistoryPage dan bawa data plan dan index
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TravelHistoryPage(
                        plan: widget.plan, // Kirim data plan yang diterima
                        index: widget.index, // Kirim index
                      ),
                    ),
                  );
                },
                child: Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
