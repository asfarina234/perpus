import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book.dart';

class BookBorrowService {
  final String baseUrl =
      'http://172.20.10.3:8000/api'; // Ganti dengan IP backend kamu

  // Kirim peminjaman ke backend
  Future<void> borrowBookToBackend(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.post(
      Uri.parse('$baseUrl/loans/borrow'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'book_id': bookId}), // ✅ ini penting
    );

    if (response.statusCode == 200) {
      print('✅ Buku berhasil dipinjam ke backend!');
    } else {
      print('❌ Gagal meminjam buku: ${response.statusCode} ${response.body}');
      throw Exception('Gagal pinjam buku');
    }
  }

  // Fungsi utama peminjaman (ke backend + lokal)
  Future<void> borrowBook(Book book) async {
    try {
      if (book.id != null) {
        await borrowBookToBackend(book.id!);
      }

      final prefs = await SharedPreferences.getInstance();
      final borrowedList = prefs.getStringList('borrowed_books') ?? [];

      final exists = borrowedList.any((jsonStr) {
        final map = json.decode(jsonStr);
        return map['judul'] == book.judul;
      });

      if (!exists) {
        final newBook = {
          'judul': book.judul,
          'penulis': book.penulis,
          'imageUrl': book.imageUrl,
          'synopsis': book.synopsis,
          'tanggal_pinjam': DateTime.now().toIso8601String(),
        };

        borrowedList.add(json.encode(newBook));
        await prefs.setStringList('borrowed_books', borrowedList);
      }
    } catch (e) {
      print('❌ Error saat meminjam: $e');
      rethrow;
    }
  }

  // Fungsi pengembalian buku
  Future<void> returnBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final borrowedList = prefs.getStringList('borrowed_books') ?? [];

    borrowedList.removeWhere((jsonStr) {
      final map = json.decode(jsonStr);
      return map['judul'] == book.judul;
    });

    await prefs.setStringList('borrowed_books', borrowedList);

    final returnedList = prefs.getStringList('returned_books') ?? [];
    final returnedBook = {
      'judul': book.judul,
      'penulis': book.penulis,
      'imageUrl': book.imageUrl,
      'synopsis': book.synopsis,
      'tanggal_kembali': DateTime.now().toIso8601String(),
    };

    returnedList.add(json.encode(returnedBook));
    await prefs.setStringList('returned_books', returnedList);
  }

  // Fungsi tandai buku sebagai sudah dibaca
  Future<void> markAsRead(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList('read_books') ?? [];

    final exists = readList.any((jsonStr) {
      final map = json.decode(jsonStr);
      return map['judul'] == book.judul;
    });

    if (!exists) {
      final readBook = {
        'judul': book.judul,
        'penulis': book.penulis,
        'imageUrl': book.imageUrl,
        'synopsis': book.synopsis,
        'tanggal_baca': DateTime.now().toIso8601String(),
      };

      readList.add(json.encode(readBook));
      await prefs.setStringList('read_books', readList);
    }
  }
}
