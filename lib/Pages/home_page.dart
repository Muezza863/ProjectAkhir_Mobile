import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata/Pages/detail_page.dart';
import 'package:wisata/Pages/itinerary_page.dart';
import 'package:wisata/Pages/maps_page.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  // Halaman yang dapat dipilih melalui BottomNavigationBar
  static List<Widget> _widgetOptions = <Widget>[
  HomePage(),
  MapsPage(),
  ItineraryPage(),
  ProfilePage(),
  ];

  void _onItemTapped(int index) {
  setState(() {
  _selectedIndex = index;
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: Colors.blue[50], // Background halaman biru muda
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined, color: Colors.black),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note, color: Colors.black),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),  // Ikon profile
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue, // Latar belakang biru
        selectedItemColor: Colors.black, // Warna item yang dipilih tetap putih
        unselectedItemColor: Colors.white, // Warna item yang tidak dipilih juga putih
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // URL API dari GitHub
  final String apiUrl =
      'https://muezza863.github.io/data_tourismplace/55_destinations.json';

  String _errorMessage = "";
  Map<String, dynamic>? _userData;

  // Mengambil data dari API GitHub
  Future<List<TourismPlace>> fetchTourismPlaces() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => TourismPlace.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tourism places');
    }
  }

  late Future<List<TourismPlace>> futureTourismPlaces;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    futureTourismPlaces = fetchTourismPlaces(); // Mengambil data dari API
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username'); // Ambil username dari SharedPreferences

      if (username == null) {
        setState(() {
          _errorMessage = "No username found";
        });
        return;
      }

      // Kirim request ke server
      final response = await http.post(
        Uri.parse("http://192.168.143.110/project/wisata/get_userdata.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username}),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _userData = data['data']; // Simpan seluruh data user ke _userData
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? "Unknown error";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.lightBlue[100],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Welcome, ",
                                style: TextStyle(
                                  fontSize: 27,
                                ),
                              ),
                              _userData != null ?
                              Align(
                                child: Text(
                                  "${_userData!['last_name']}",
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              )
                                  : _errorMessage.isNotEmpty
                                  ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                                  : CircularProgressIndicator(), // Loader saat data belum ada
                            ],
                          ),
                          Spacer(),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                            AssetImage('assets/images/Profile_avatar_placeholder_large.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search your destination',
                      prefixIcon: Icon(Icons.search),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.purple[50],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 30),
                    child: Text(
                      "Recommendations",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                  ),
                  FutureBuilder<List<TourismPlace>>(
                      future: futureTourismPlaces,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No places found.'));
                        } else {
                          final tourismPlaces = snapshot.data!;
                          return SizedBox(
                            height: 365, // Tinggi card list
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                final place = tourismPlaces[index];
                                return GestureDetector(
                                  onTap: () { Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(place: place),
                                    ),
                                  );},
                                  child:
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: index == 2 ? 10 : 0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                        child: Container(
                                          width: 200, // Lebar tiap card
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Stack(
                                                children: [
                                                  // Gambar
                                                  Container(
                                                    height: 200,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius
                                                          .circular(10),
                                                    ),
                                                    child: Image.network(
                                                      place.image_url,
                                                      height: 150,
                                                      width: 200,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error,
                                                          stackTrace) =>
                                                          Icon(Icons.image, size: 100),
                                                    ),
                                                  ),
                                                  // Icon favorit di pojok kanan atas
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: () { Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => DetailPage(place: place),
                                                        ),
                                                      );},
                                                          child: Center(
                                                            child: Stack(
                                                              alignment: Alignment
                                                                  .center,
                                                              // Menempatkan teks di tengah bintang
                                                              children: [
                                                                Icon(
                                                                  Icons.star,
                                                                  // Ikon bintang
                                                                  color: Colors
                                                                      .orange,
                                                                  // Warna bintang kuning
                                                                  size: 50, // Ukuran bintang, sesuaikan dengan kebutuhan
                                                                ),
                                                                Text(
                                                                  place.rating.toString(),
                                                                  // Teks rating
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    // Warna teks
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              // Judul, alamat, dan harga
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            place.name,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                            ),
                                                            softWrap: true, // Agar teks bisa otomatis pindah baris
                                                            overflow: TextOverflow.visible, // Tidak memotong teks
                                                          ),
                                                          Text(place.address,softWrap: true,),
                                                          SizedBox(height: 4),
                                                          Text("Entry fee: \$${place.entry_fee_usd.toString()}"),
                                                        ],
                                                      ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                );
                              },
                            ),
                          );
                        }
                      }
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 30),
                    child: Text(
                      "List of Tourist Attractions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                  ),

                  FutureBuilder<List<TourismPlace>>(
                    future: futureTourismPlaces,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No places found.'));
                      } else {
                        final tourismPlaces = snapshot.data!;
                        return SizedBox(
                          height: 500, // Tinggi container
                          child: GridView.builder(
                            itemCount: tourismPlaces.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Jumlah kolom
                              mainAxisSpacing: 10, // Spasi vertikal antar item
                              crossAxisSpacing: 10, // Spasi horizontal antar item
                              childAspectRatio: 0.75, // Rasio aspek card (lebar:tinggi)
                            ),
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) {
                              final place = tourismPlaces[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(place: place),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            // Gambar
                                            Container(
                                              height: 120,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.network(
                                                place.image_url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(Icons.image, size: 100),
                                              ),
                                            ),
                                            // Icon favorit di pojok kanan atas
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Center(
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.orange,
                                                      size: 30,
                                                    ),
                                                    Text(
                                                      place.rating.toString(),
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        // Judul, alamat, dan harga
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              place.address,
                                              style: TextStyle(fontSize: 12),
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Entry fee: \$${place.entry_fee_usd.toString()}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TourismPlace {
  String name;
  String address;
  String description;
  String image_url;
  double entry_fee_usd;
  double rating;

  TourismPlace({
    required this.name,
    required this.address,
    required this.description,
    required this.image_url,
    required this.entry_fee_usd,
    required this.rating,
  });

  factory TourismPlace.fromJson(Map<String, dynamic> json) {
    return TourismPlace(
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? '',
      description: json['description'] ?? 'No description available',
      image_url: json['image_url'] ??
          'https://ih1.redbubble.net/image.4905811447.8675/flat,750x,075,f-pad,750x1000,f8f8f8.jpg',
      entry_fee_usd: (json['entry_fee_usd'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}