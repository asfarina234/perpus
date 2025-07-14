import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

class DashboardService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti jika API online

  Future<DashboardData> fetchDashboardData() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DashboardData.fromJson(data);
    } else {
      throw Exception('Gagal memuat data dashboard: ${response.statusCode}');
    }
  }
}
