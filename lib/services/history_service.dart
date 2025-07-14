import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<dynamic>> getBorrowedHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/loans/borrowed'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat riwayat peminjaman');
    }
  }

  Future<List<dynamic>> getReturnedHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/loans/returned'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat riwayat pengembalian');
    }
  }

  Future<List<dynamic>> getUserHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat riwayat pengguna');
    }
  }

  Future<List<dynamic>> getReadHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/loans/read'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat riwayat buku dibaca');
    }
  }
}
