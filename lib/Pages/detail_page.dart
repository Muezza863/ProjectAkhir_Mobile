import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/response.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

import 'plan_page.dart';

class DetailPage extends StatefulWidget {
  final TourismPlace place;

  const DetailPage({Key? key, required this.place}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Page"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar utama
            Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.place.image_url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama tempat
                  Row(
                    children: [
                      Expanded(
                        child:
                          Text(
                            widget.place.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                      ),
                      Spacer(),
                      Icon(Icons.star, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        widget.place.rating.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Alamat
                  Text(
                    widget.place.address,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  // Deskripsi
                  Text(
                    widget.place.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Biaya masuk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Entry Fee ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          CurrencyDropdown(place: widget.place),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 100,)
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child:
          FloatingActionButton(
            backgroundColor: Colors.blue[200],
            onPressed: (){ Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanPage(place: widget.place),
              ),
            );}, // Memuat tempat berdasarkan kategori
            child: Text("Plan"),
          ),
      ),
    );
  }
}

class CurrencyDropdown extends StatefulWidget {
  final TourismPlace place;

  const CurrencyDropdown({Key? key, required this.place}) : super(key: key);

  @override
  _CurrencyDropdownState createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  String _selectedCurrency = 'USD'; // Mata uang default
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'JPY', 'GBP'];
  double? _convertedAmount;
  bool _isLoading = false;

  Future<void> _convertCurrency(String newCurrency) async {
    final String apiKey = '969268f8cbcd0e7f5e7b145b';
    final double amount = widget.place.entry_fee_usd.toDouble(); // Pastikan menggunakan double

    if (newCurrency == 'USD') {
      setState(() {
        _convertedAmount = widget.place.entry_fee_usd.toDouble();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // URL untuk mendapatkan nilai tukar dari API
    final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/pair/USD/$newCurrency');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        double exchangeRate = data['conversion_rate'];
        setState(() {
          _convertedAmount = amount * exchangeRate;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        print('entry_fee_usd type: ${widget.place.entry_fee_usd.runtimeType}');
        _convertedAmount = null;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double value, String currency) {
    switch (currency) {
      case 'IDR':
        return NumberFormat.currency(
          locale: 'id_ID', // Format Indonesia
          symbol: 'Rp. ', // Simbol untuk IDR
          decimalDigits: 0,
        ).format(value);
      case 'USD':
        return NumberFormat.currency(
          locale: 'en_US', // Format Amerika Serikat
          symbol: '\$', // Simbol untuk USD
          decimalDigits: 2,
        ).format(value);
      case 'EUR':
        return NumberFormat.currency(
          locale: 'de_DE', // Format Eropa (Jerman)
          symbol: '€', // Simbol untuk EUR
          decimalDigits: 2,
        ).format(value);
      case 'JPY':
        return NumberFormat.currency(
          locale: 'ja_JP', // Format Jepang
          symbol: '¥', // Simbol untuk JPY
          decimalDigits: 0, // Biasanya tidak ada desimal untuk JPY
        ).format(value);
      case 'GBP':
        return NumberFormat.currency(
          locale: 'en_GB', // Format Inggris
          symbol: '£', // Simbol untuk GBP
          decimalDigits: 2,
        ).format(value);
      default:
        return NumberFormat.currency(
          locale: 'en_US', // Default ke format Amerika Serikat
          symbol: '\$', // Default simbol
          decimalDigits: 2,
        ).format(value);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dropdown untuk memilih mata uang
        DropdownButton<String>(
          value: _selectedCurrency, // Mata uang yang terpilih
          onChanged: (String? newCurrency) {
            if (newCurrency != null) {
              setState(() {
                _selectedCurrency = newCurrency; // Ubah nilai dropdown
              });
              _convertCurrency(newCurrency); // Jalankan fungsi konversi
            }
          },
          items: _currencies.map<DropdownMenuItem<String>>((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
        ),

        SizedBox(width: 135),

        // Loader ketika sedang memuat data
        if (_isLoading)
          CircularProgressIndicator(),

        // Teks hasil konversi
        if (!_isLoading && _convertedAmount != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _formatCurrency(_convertedAmount!, _selectedCurrency),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}