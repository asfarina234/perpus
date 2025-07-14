import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/library_service.dart';

class BooksScreen extends StatefulWidget {
  final String userId;
  const BooksScreen({super.key, required this.userId});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final LibraryService _libraryService = LibraryService();
  late Future<List<Book>> _futureBooks;

  @override
  void initState() {
    super.initState();
    _futureBooks = _libraryService.fetchBooks('fiksi');
  }

  Future<void> _borrowBook(int bookId) async {
    try {
      final result = await _libraryService.borrowBook(widget.userId, bookId);
      final success = result['success'] ?? false;
      final message = result['message'] ??
          (success ? 'Berhasil meminjam buku' : 'Gagal meminjam buku');

      _showSnackBar(message, success: success);

      if (success) {
        setState(() {
          _futureBooks = _libraryService.fetchBooks('fiksi');
        });
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', success: false);
    }
  }

  void _showSnackBar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku Fiksi'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu_book),
          )
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('Belum ada buku yang tersedia.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureBooks = _libraryService.fetchBooks('fiksi');
              });
            },
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        book.imageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    title: Text(book.judul,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${book.penulis} • ${book.category}'),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _borrowBook(book.id!),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Pinjam'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
