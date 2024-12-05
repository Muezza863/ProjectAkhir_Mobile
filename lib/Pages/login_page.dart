import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata/Pages/home_page.dart';
import 'package:wisata/Pages/signup_page.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true; // Status untuk menyembunyikan atau menampilkan password
  bool _showPassword = false; // Status untuk checkbox "Show Password"
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Fungsi untuk menampilkan dialog pop-up
  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup pop-up
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Kirim data login ke server
      final response = await http.post(
        Uri.parse("http://192.168.143.110/project/wisata/login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Jika login berhasil, simpan token dan username ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('username', _usernameController.text); // Simpan username

        // Debugging: Print nilai yang disimpan
        // print("Username saved: ${prefs.getString('username')}");
        // print("Token saved: ${prefs.getString('token')}");

        // Navigasi ke halaman Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Tampilkan pesan error jika login gagal
        _showPopup("Error", data['massage']);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(data['message'] ?? 'Login failed')),
        // );
      }
    } catch (e) {
      // Tampilkan error jika ada masalah saat login
      _showPopup('Error', '$e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }


  setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Container(
          //   color: Colors.orangeAccent.withOpacity(0.13),
          // ),
          // ClipRRect(
          //   borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(35),  // Menambahkan radius pada sudut kiri bawah
          //     bottomRight: Radius.circular(35), // Menambahkan radius pada sudut kanan bawah
          //   ),
          //   child:
      Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login.jpg'),
                  fit: BoxFit.cover, // Gambar akan menutupi area container
                ),
              ),
            ),

          Positioned(
            top: 275, // Mengatur posisi form login agar berada tepat di bawah gambar
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Memberikan padding untuk form
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // Shadow di bawah form
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16), // Jarak antara input username dan password
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscured, // Untuk menyembunyikan password
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _showPassword,
                              onChanged: (bool? value) {
                                setState(() {
                                  _showPassword = value ?? false;
                                  _isObscured = !_showPassword; // Mengatur status _isObscured
                                });
                              },
                            ),
                            Text("Show Password"),
                          ],
                        ),
                        //SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: _login,
                          child: Center(child: Text("Login", style: TextStyle(fontSize: 15),)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.7),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(double.infinity, 50), // Lebar tombol menyesuaikan container
                          ),
                        ),

                        Row(
                          children: [
                            Text("Don't have an account yet?"),
                            TextButton(onPressed: (){
                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context)=>SignupPage()
                              )
                              );
                            }, child: Text("create an account")),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
