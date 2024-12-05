import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // GoogleMapController? _googleMapController;
  late MapController _mapController;
  List<Marker> _markers = [];
  String apiKey = "92a2f7e3f4734d3baca64fc9f930f39f"; // API Key Geoapify

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Menampilkan tempat berdasarkan kategori pada load awal (misal Jakarta)
    _loadPlaces();
  }

  // Fungsi untuk menampilkan tempat berdasarkan kategori
  Future<void> _loadPlaces() async {
    try {
      // Menyaring kategori: Entertainment, Tourism, Beach
      final url = Uri.parse(
          "https://api.geoapify.com/v2/places?categories=entertainment,tourism,beach&bias=proximity:110.3695,-7.7956&apiKey=$apiKey"
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          for (var feature in data['features']) {
            final latitude = feature['geometry']['coordinates'][1];
            final longitude = feature['geometry']['coordinates'][0];
            final name = feature['properties']['formatted'] ?? "Unnamed Place";
            final category = feature['properties']['categories'][0] ?? "Unknown";
            final description = feature['properties']['description'] ?? "No description available";
            final icon = _getIconForCategory(category);

            // Menambahkan marker dengan kategori yang sesuai dan deskripsi
            _addMarker(LatLng(latitude, longitude), label: name, icon: icon, description: description);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No places found in the area!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch places data!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  // Fungsi untuk menambahkan marker pada peta
  void _addMarker(LatLng point, {String? label, String? icon, String? description}) {
    setState(() {
      _markers.add(
        Marker(
          point: point,
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showPlaceDescriptionDialog(label, description);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Fungsi untuk menentukan icon berdasarkan kategori tempat
  String _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return 'entertainment';
      case 'tourism':
        return 'tourism';
      case 'beach':
        return 'beach';
      default:
        return 'unknown';
    }
  }

  // Fungsi untuk menampilkan dialog dengan deskripsi tempat
  void _showPlaceDescriptionDialog(String? title, String? description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? "Unknown Place"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description ?? "No description available for this place."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi pencarian kota
  Future<void> _searchCity(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid city name!")),
      );
      return;
    }

    try {
      final url = Uri.parse(
          "https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$apiKey"
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0]; // Ambil lokasi pertama
          final latitude = feature['geometry']['coordinates'][1];
          final longitude = feature['geometry']['coordinates'][0];
          // final name = feature['properties']['formatted'] ?? "Unnamed Place";

          // Pindahkan peta ke lokasi kota yang dicari
          _mapController.move(LatLng(latitude, longitude), 15.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("City not found!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch city data!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue[200],
        title: Text('Maps Page',
          style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _searchCity,
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-7.7956, 110.3695), // Default: Yogyakarta
                maxZoom: 15.0,
                onTap: (tapPosition, point) {
                  // Tambahkan marker di lokasi diketuk
                  _addMarker(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$apiKey",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetToNorth(); // Fungsi untuk mengatur peta agar utara berada di atas
        },
        child: const Icon(Icons.explore), // Ikon kompas
      ),
    );
  }
  void _resetToNorth() {
    _mapController.rotate(0); // Atur rotasi peta menjadi 0 derajat
  }
}
