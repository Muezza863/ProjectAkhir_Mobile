import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Background Gambar
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash.jpg'),
                fit: BoxFit.cover, // Gambar menutupi seluruh layar
              ),
            ),
          ),
          Container(
            color: Colors.blue.withOpacity(0.2),
          ),
          Container(
            color: Colors.white.withOpacity(0.25),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Mengatur alignment seluruh Column ke kiri
                children: [
                  // Padding(padding: EdgeInsets.all(15)),
                  SizedBox(height: 100),
                  Align(
                    alignment:
                        Alignment.centerLeft, // Menjadikan teks rata kiri
                    child: Text(
                      "Need",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 50),
                    child: Text(
                      "Vacation?",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                      "Let's Join With Us",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 175,),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()
                                  )
                              );
                            },
                            child: Text("Create an account"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()
                                  )
                              );
                            },
                            child: Text("Login"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
