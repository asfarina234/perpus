import 'package:flutter/material.dart';
import '../../models/book.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Book> favoriteBooks;

  const FavoritesScreen({super.key, required this.favoriteBooks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buku Favorit')),
      body:
          favoriteBooks.isEmpty
              ? const Center(child: Text('Belum ada buku favorit.'))
              : ListView.builder(
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return ListTile(
                    leading: Image.network(
                      book.imageUrl,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.book,
                            size: 50,
                            color: Colors.grey,
                          ),
                    ),
                    title: Text(book.judul),
                    subtitle: Text(book.penulis),
                    trailing: Icon(Icons.favorite, color: Colors.red),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BookDetailScreen(
                                title: book.judul,
                                author: book.penulis,
                                imageUrl: book.imageUrl,
                                synopsis: book.synopsis,
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
