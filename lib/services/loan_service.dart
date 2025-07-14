import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loan.dart';

class LoanService {
  final String baseUrl = 'http://172.20.10.3:8000/api';

  Future<List<Loan>> fetchLoans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/loans'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data']; // ✅ Ambil dari "data"
      return data.map((json) => Loan.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data peminjaman');
    }
  }

  Future<List<Loan>> fetchLoanHistoryAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('$baseUrl/loans/history-all'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Loan.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat peminjaman');
    }
  }

  Future<void> pinjamBuku(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse('$baseUrl/loans/borrow'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'book_id': bookId.toString()},
    );

    if (response.statusCode != 200) {
      print('❌ Error response: ${response.body}');
      throw Exception('Gagal meminjam buku');
    }
  }
}
