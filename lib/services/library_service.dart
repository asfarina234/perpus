import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart'; // pastikan sudah ada file model Book

class LibraryService {
  final String baseUrl = 'https://172.20.10.3:8000/api'; // ganti sesuai API

  Future<List<Book>> fetchBooks(String category) async {
    final url = Uri.parse('$baseUrl/books?category=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'] ?? data;
      return list.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Book>> fetchBooksByCategory(String category) async {
    final url = Uri.parse('$baseUrl/books/category/$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'];
      return list.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil buku kategori $category');
    }
  }

  Future<Map<String, dynamic>> borrowBook(String userId, int bookId) async {
    final url = Uri.parse('$baseUrl/loans/borrowed');
    final response = await http.post(
      url,
      body: jsonEncode({'user_id': userId, 'book_id': bookId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Error server'};
    }
  }

  Future<Map<String, dynamic>> returnBook(String userId, int bookId) async {
    final url = Uri.parse('$baseUrl/loans/returned');
    final response = await http.post(
      url,
      body: jsonEncode({'user_id': userId, 'book_id': bookId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Error server'};
    }
  }
}
