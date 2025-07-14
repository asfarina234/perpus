import 'package:flutter/material.dart';
import '../../screens/pinjam_buku_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String synopsis;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.synopsis,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.book, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              'Penulis: $author',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(synopsis, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PinjamBukuScreen(
                          title: title,
                          author: author,
                          imageUrl: imageUrl,
                        ),
                  ),
                );
              },
              child: const Text('Pinjam'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur kembalikan belum diimplementasi'),
                  ),
                );
              },
              child: const Text('Kembalikan'),
            ),
          ],
        ),
      ),
    );
  }
}
