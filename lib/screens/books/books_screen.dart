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
      final message =
          result['message'] ??
          (success ? 'Berhasil meminjam buku' : 'Gagal meminjam buku');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        setState(() {
          _futureBooks = _libraryService.fetchBooks('fiksi');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Buku')),
      body: FutureBuilder<List<Book>>(
        future: _futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('Belum ada buku'));
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    book.imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(book.judul),
                  subtitle: Text('${book.penulis} | ${book.category}'),
                  trailing: ElevatedButton(
                    onPressed: () => _borrowBook(book.id!),
                    child: const Text('Pinjam'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
