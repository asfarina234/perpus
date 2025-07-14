import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../screens/books/book_detail_screen.dart'; // Sesuaikan path jika perlu
import '../services/book_borrow_service.dart';

class HistoryService {
  Future<List<Map<String, dynamic>>> getReturnedHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'book_id': 'book125',
        'judul_buku': 'Advanced Flutter',
        'author': 'Alice Johnson',
        'image_url': 'https://via.placeholder.com/150',
        'synopsis': 'Materi lanjutan pengembangan aplikasi Flutter.',
        'tanggal_kembali': '2025-05-30',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getReadHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'book_id': 'book126',
        'judul_buku': 'Design Patterns',
        'author': 'Bob Martin',
        'image_url': 'https://via.placeholder.com/150',
        'synopsis': 'Buku tentang pola desain software terbaik.',
        'tanggal_baca': '2025-06-03',
      },
    ];
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<Map<String, dynamic>> _borrowed = [];
  List<Map<String, dynamic>> _returned = [];
  List<Map<String, dynamic>> _read = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Buku Dipinjam
      final borrowedStringList = prefs.getStringList('borrowed_books') ?? [];
      final borrowedLocal =
          borrowedStringList.map((jsonStr) {
            final Map<String, dynamic> map = json.decode(jsonStr);
            return {
              'judul_buku': map['title'] ?? '',
              'author': map['author'] ?? '',
              'image_url': map['imageUrl'] ?? '',
              'synopsis': map['synopsis'] ?? '',
              'tanggal_pinjam': map['tanggal_pinjam'] ?? '',
            };
          }).toList();

      // Buku Dikembalikan
      final returnedStringList = prefs.getStringList('returned_books') ?? [];
      final returnedLocal =
          returnedStringList.map((jsonStr) {
            final Map<String, dynamic> map = json.decode(jsonStr);
            return {
              'judul_buku': map['title'] ?? '',
              'author': map['author'] ?? '',
              'image_url': map['imageUrl'] ?? '',
              'synopsis': map['synopsis'] ?? '',
              'tanggal_kembali': map['tanggal_kembali'] ?? '',
            };
          }).toList();

      // Buku Dibaca
      final readStringList = prefs.getStringList('read_books') ?? [];
      final readLocal =
          readStringList.map((jsonStr) {
            final Map<String, dynamic> map = json.decode(jsonStr);
            return {
              'judul_buku': map['title'] ?? '',
              'author': map['author'] ?? '',
              'image_url': map['imageUrl'] ?? '',
              'synopsis': map['synopsis'] ?? '',
              'tanggal_baca': map['tanggal_baca'] ?? '',
            };
          }).toList();

      setState(() {
        _borrowed = borrowedLocal;
        _returned = returnedLocal;
        _read = readLocal;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openBookDetail(Map<String, dynamic> bookData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookDetailScreen(
              title: bookData['judul_buku'] ?? '',
              author: bookData['author'] ?? '',
              imageUrl: bookData['image_url'] ?? '',
              synopsis: bookData['synopsis'] ?? '',
            ),
      ),
    );
  }

  Widget _buildHistorySection(
    String title,
    List<Map<String, dynamic>> data,
    String dateField,
    void Function(Map<String, dynamic>) onTapCallback,
  ) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          '$title: Tidak ada data',
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...data.map(
          (item) => ListTile(
            leading:
                item['image_url'] != null && item['image_url'] != ''
                    ? Image.network(
                      item['image_url'],
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                    : const Icon(Icons.book),
            title: Text(item['judul_buku']),
            subtitle: Text('${_formatLabel(dateField)}: ${item[dateField]}'),
            onTap: () => onTapCallback(item),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatLabel(String field) {
    switch (field) {
      case 'tanggal_pinjam':
        return 'Tanggal Pinjam';
      case 'tanggal_kembali':
        return 'Tanggal Kembali';
      case 'tanggal_baca':
        return 'Tanggal Baca';
      default:
        return 'Tanggal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Buku')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistorySection(
                      '📚 Buku Dibaca',
                      _read,
                      'tanggal_baca',
                      _openBookDetail,
                    ),
                    _buildHistorySection(
                      '📖 Buku Dipinjam',
                      _borrowed,
                      'tanggal_pinjam',
                      _openBookDetail,
                    ),
                    _buildHistorySection(
                      '✅ Buku Dikembalikan',
                      _returned,
                      'tanggal_kembali',
                      _openBookDetail,
                    ),
                  ],
                ),
              ),
    );
  }
}
