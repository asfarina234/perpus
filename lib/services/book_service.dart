import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// 🔸 Ambil semua buku (tanpa filter)
  static Future<List<Book>> fetchAllBooks() async {
    final url = Uri.parse('$baseUrl/books');
    try {
      final response = await http.get(url).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil semua buku: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat ambil semua buku: $e');
    }
  }

  /// 🔸 Ambil daftar buku berdasarkan kategori
  static Future<List<Book>> fetchBooks(String category) async {
    final url = Uri.parse('$baseUrl/books?category=$category');
    try {
      final response = await http.get(url).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data buku per kategori');
      }
    } catch (e) {
      throw Exception('Kesalahan saat ambil buku per kategori: $e');
    }
  }

  /// 🔸 Ambil daftar buku favorit user
  static Future<List<Book>> fetchFavoriteBooks(String userId) async {
    final url = Uri.parse('$baseUrl/books/favorites?userId=$userId');
    try {
      final response = await http.get(url).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil buku favorit');
      }
    } catch (e) {
      throw Exception('Kesalahan saat ambil buku favorit: $e');
    }
  }

  /// 🔸 Tambah buku baru
  static Future<bool> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books'), // misal: http://127.0.0.1:8000/api/books
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('ERROR ADD BOOK: $e');
      return false;
    }
  }

  /// 🔸 Update buku
  static Future<bool> updateBook(Book book) async {
    final url = Uri.parse('$baseUrl/books/${book.id}');
    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'judul': book.judul,
              'penulis': book.penulis,
              'category': book.category,
              'stok': book.stok,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update gagal: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Kesalahan saat update buku: $e');
      return false;
    }
  }

  /// 🔸 Hapus buku
  static Future<bool> deleteBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    print('📦 TOKEN yang dikirim: $token');
    final url = Uri.parse('$baseUrl/books/$id');
    print('📡 DELETE URL: $url');

    try {
      final response = await http
          .delete(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 5));

      print('📥 DELETE status: ${response.statusCode}');
      print('📥 DELETE response: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error delete: $e');
      return false;
    }
  }
}
