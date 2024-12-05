import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata/Pages/splash_page.dart';
import '../model/travelhistory.dart';
import 'detailhistory_page.dart';
import '../service/camera_services.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Box<TravelHistory> historyBox;
  String _errorMessage = "";
  Map<String, dynamic>? _userData;
  final ImagePickerServices _imagePickerHelper = ImagePickerServices(); // Inisialisasi services
  File? _image; // Variabel untuk menyimpan gambar yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // Membuka box Hive untuk travel history
    historyBox = Hive.box<TravelHistory>('travel_history');
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

  // Fungsi untuk menampilkan modal bottom sheet
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _imagePickerHelper.getImageFromGallery((path) {
                    if (path != null) {
                      setState(() {
                        _image = File(path);
                      });
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _imagePickerHelper.getImageFromCamera((path) {
                    if (path != null) {
                      setState(() {
                        _image = File(path);
                      });
                    }
                  });
                },
              ),
            ],
          ),
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
        title: Text('User Profile',
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
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Informasi Akun
              _buildProfileInfo(),
              SizedBox(height: 20.0),
              // Histori Perjalanan dan Ulasan
              _buildTravelHistory(),
              SizedBox(height: 20.0),
              // Saran
              _saran(),
              SizedBox(height: 5.0),
              // Kesan PAM
              _kesan(),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk informasi akun
  Widget _buildProfileInfo() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImagePickerOptions, // Menampilkan opsi saat avatar di-klik
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _image != null
                    ? FileImage(_image!) as ImageProvider
                    : const AssetImage('assets/images/Profile_avatar_placeholder_large.png'),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            _userData != null ?
            Column(
              children: [
                Text(
                      '${_userData!['full_name']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                Text('${_userData!['email']}'),
              ],
            )
                :_errorMessage.isNotEmpty
                ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                : CircularProgressIndicator(), // Loader saat data belum ada
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                // Tampilkan popup konfirmasi
                bool? confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmation"),
                      content: Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Tutup dialog, return false
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Tutup dialog, return true
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );

                // Jika user menekan OK, lakukan logout
                if (confirmLogout == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token'); // Hapus token dari penyimpanan
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashPage()),
                  );
                }
              },
              icon: Icon(
                Icons.logout, // Ikon pintu keluar
                color: Colors.red,
              ),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Warna latar putih
                side: BorderSide(color: Colors.red), // Border merah
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan riwayat perjalanan dari Hive
  Widget _buildTravelHistory() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: historyBox.listenable(),
              builder: (context, Box<TravelHistory> box, _) {
                if (box.isEmpty) {
                  return Text('There is no travel history.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final travel = box.getAt(index);

                    return ListTile(
                      title: Text(travel?.plan.destination ?? 'No purpose'),
                      subtitle: Text(travel?.impression ?? 'No reviews'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        if (travel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailHistoryPage(travelHistory: travel),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk formulir saran
  Widget _saran() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggestion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Terus kembangkan aplikasi ini dan tambahkan fitur menarik lainnya.",
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk kesan PAM
  Widget _kesan() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kesan Pemrograman Aplikasi Mobile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Kesan dalam mata kuliah Pemrograman Aplikasi Mobile menurut saya adalah mengasyikkan. Karena pada mata kuliah ini, saya diminta untuk mencari dan belajar mandiri melalui tugas-tugas yang diberikan. Walaupun... jalanin aja dehh.",
            ),
          ],
        ),
      ),
    );
  }
}
