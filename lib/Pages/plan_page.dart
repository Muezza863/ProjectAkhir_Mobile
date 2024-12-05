import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../model/plan.dart';
import '../model/response.dart';
import '../service/notification_service.dart';
import 'home_page.dart';

class PlanPage extends StatefulWidget {
  final TourismPlace place;

  const PlanPage({Key? key, required this.place}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final _formKey = GlobalKey<FormState>();

  // Kontroller untuk field
  TextEditingController _departureDateController = TextEditingController();
  TextEditingController _departureTimeController = TextEditingController();

  // Fungsi untuk menampilkan DatePicker
  Future<void> _pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _departureDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _savePlan() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ambil data dari form
        final newPlan = Plan(
          destination: widget.place.name,
          location: widget.place.address,
          departureDate: _departureDateController.text,
          departureTime: _departureTimeController.text,
        );

        // Simpan ke Hive
        final box = Hive.box<Plan>('plans');
        await box.add(newPlan);

        // Gabungkan tanggal dan waktu keberangkatan
        final dateParts = _departureDateController.text.split('-'); // [yyyy, mm, dd]
        final timeParts = _departureTimeController.text.split(':'); // [hh, mm]

        DateTime eventTime = DateTime(
          int.parse(dateParts[0]), // yyyy
          int.parse(dateParts[1]), // mm
          int.parse(dateParts[2]), // dd
          int.parse(timeParts[0]), // hh
          int.parse(timeParts[1]), // mm
          0, // detik
        );

        // Panggil fungsi notifikasi
        await scheduleNotifications(eventTime);

        // Tampilkan pop-up sukses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Berhasil"),
            content: Text("Rencana perjalanan berhasil disimpan dan notifikasi telah dijadwalkan!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        // Tampilkan pop-up error jika terjadi kegagalan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text("Terjadi kesalahan saat menyimpan rencana perjalanan: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      // Jika form tidak valid, beri pop-up pemberitahuan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Form Tidak Valid"),
          content: Text("Pastikan semua data telah diisi dengan benar."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }


  // Fungsi untuk menampilkan TimePicker dengan format 24 jam
  Future<void> _pickTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: Locale('en', 'US'),
          child: child,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        // Format waktu menjadi skala 24 jam
        final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        _departureTimeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plan Your Trip"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Field untuk Tujuan Wisata
              TextFormField(
                initialValue: widget.place.name,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Tourist Destination",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Field untuk Lokasi
              TextFormField(
                initialValue: widget.place.address,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Field untuk Tanggal Keberangkatan
              TextFormField(
                controller: _departureDateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: "Departure Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select departure date";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Field untuk Waktu Keberangkatan
              TextFormField(
                controller: _departureTimeController,
                readOnly: true,
                onTap: _pickTime,
                decoration: InputDecoration(
                  labelText: "Departure Time",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select departure time";
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Tombol Submit
              ElevatedButton(
                onPressed: _savePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text("Save Travel Plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _departureDateController.dispose();
    _departureTimeController.dispose();
    super.dispose();
  }
}
