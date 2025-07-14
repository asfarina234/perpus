import 'package:flutter/material.dart';
import '../books/book_detail_screen.dart';
import '../books/favorite_books_screen.dart';
import '../../services/book_borrow_service.dart';
import '../../services/book_service.dart';
import '../../models/book.dart';

class BookListScreen extends StatefulWidget {
  final int userId;
  final String category;
  final String role;

  const BookListScreen({
    super.key,
    required this.userId,
    required this.category,
    required this.role,
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];
  List<Book> favoriteBooks = [];

  final BookBorrowService _bookBorrowService = BookBorrowService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final allBooks = await BookService.fetchAllBooks();
      setState(() {
        books = allBooks
            .where(
              (b) => b.category.toLowerCase() == widget.category.toLowerCase(),
            )
            .toList();
      });
    } catch (e) {
      _showMessage('Gagal memuat data buku: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void toggleFavorite(Book book) {
    setState(() {
      final exists = favoriteBooks.any((b) => b.judul == book.judul);
      if (exists) {
        favoriteBooks.removeWhere((b) => b.judul == book.judul);
        _showMessage('${book.judul} dihapus dari favorit');
      } else {
        favoriteBooks.add(book);
        _showMessage('${book.judul} ditambahkan ke favorit');
      }
    });
  }

  Future<void> pinjamBuku(Book book) async {
    if (book.stok <= 0) {
      _showMessage('Stok buku "${book.judul}" habis!');
      return;
    }
    try {
      await _bookBorrowService.borrowBook(book);
      _showMessage('Buku "${book.judul}" berhasil dipinjam!');
    } catch (e) {
      _showMessage('Gagal meminjam buku: $e');
    }
  }

  Future<void> kembalikanBuku(Book book) async {
    try {
      await _bookBorrowService.returnBook(book);
      _showMessage('Buku "${book.judul}" berhasil dikembalikan!');
    } catch (e) {
      _showMessage('Gagal mengembalikan buku: $e');
    }
  }

  Future<void> markAsRead(Book book) async {
    try {
      await _bookBorrowService.markAsRead(book);
      _showMessage('Buku "${book.judul}" ditandai sebagai dibaca!');
    } catch (e) {
      _showMessage('Gagal menandai buku: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildBookTile(Book book) {
    final isFavorited = favoriteBooks.any((b) => b.judul == book.judul);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: book.imageUrl.isNotEmpty
            ? Image.network(
                book.imageUrl,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 50),
              )
            : const Icon(Icons.book, size: 50, color: Colors.grey),
        title: Text(book.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${book.penulis} • Stok: ${book.stok}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () => toggleFavorite(book),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => pinjamBuku(book),
            ),
            IconButton(
              icon: const Icon(Icons.assignment_return),
              onPressed: () => kembalikanBuku(book),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => markAsRead(book),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(
                title: book.judul,
                author: book.penulis,
                imageUrl: book.imageUrl,
                synopsis: book.synopsis,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = widget.role == 'admin'
        ? books.where((b) => b.stok > 0).toList()
        : books;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Buku - ${widget.category}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              final updatedFavorites = await Navigator.push<List<Book>>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FavoritesScreen(favoriteBooks: favoriteBooks),
                ),
              );
              if (updatedFavorites != null) {
                setState(() => favoriteBooks = updatedFavorites);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBooks,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: filteredBooks.isEmpty
                    ? const Center(child: Text('Tidak ada buku tersedia.'))
                    : ListView.builder(
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) =>
                            _buildBookTile(filteredBooks[index]),
                      ),
              ),
            ),
    );
  }
}
