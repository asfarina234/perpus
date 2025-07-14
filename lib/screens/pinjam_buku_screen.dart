import 'package:flutter/material.dart';

class PinjamBukuScreen extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;

  const PinjamBukuScreen({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjam Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Penulis: $author'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logika pinjam bisa ditambahkan di sini (misalnya panggil API)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buku berhasil dipinjam!')),
                );
              },
              child: const Text('Konfirmasi Pinjam'),
            ),
          ],
        ),
      ),
    );
  }
}
