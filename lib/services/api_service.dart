import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/book.dart'; // sesuaikan path-nya dengan struktur folder project kamu

Future<List<Book>> fetchBooks() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/books'));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final booksJson = jsonData['data_buku'] as List;
    return booksJson.map((book) => Book.fromJson(book)).toList();
  } else {
    throw Exception('Failed to load books');
  }
}
