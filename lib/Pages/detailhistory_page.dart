import 'package:flutter/material.dart';
import '../model/travelhistory.dart';

class DetailHistoryPage extends StatelessWidget {
  final TravelHistory travelHistory;

  // Menerima objek TravelHistory sebagai parameter
  DetailHistoryPage({required this.travelHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text('Travel Details'),
      ),
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
                // Informasi Detail Plan
                _buildPlanDetails(),
                SizedBox(height: 20),
                // Kesan
                _buildImpression(),
                SizedBox(height: 20),
                // Cerita
                _buildStory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan detail Plan
  Widget _buildPlanDetails() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Destination', travelHistory.plan.destination),
            _buildDetailRow('Location', travelHistory.plan.location),
            _buildDetailRow('Departure Date', travelHistory.plan.departureDate),
            _buildDetailRow('Departure time', travelHistory.plan.departureTime),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan kesan
  Widget _buildImpression() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impression',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              travelHistory.impression,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan cerita
  Widget _buildStory() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              travelHistory.story,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
