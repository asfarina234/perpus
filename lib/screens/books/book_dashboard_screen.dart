import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../books/edit_book_screen.dart';

class BookDashboard extends StatefulWidget {
  @override
  _BookDashboardState createState() => _BookDashboardState();
}

class _BookDashboardState extends State<BookDashboard> {
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  void _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final books = await BookService.fetchAllBooks();
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks =
          _allBooks
              .where((book) => book.judul.toLowerCase().contains(query))
              .toList();
    });
  }

  void _confirmDelete(Book book) {
    final parentContext = context;

    showDialog(
      context: parentContext,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Buku'),
            content: Text(
              'Apakah kamu yakin ingin menghapus buku "${book.judul}"?',
            ),
            actions: [
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Hapus'),
                onPressed: () async {
                  Navigator.pop(context);

                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder:
                        (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    print('🔧 Mulai hapus buku id: ${book.id}');
                    final success = await BookService.deleteBook(book.id!);
                    print('✅ Selesai hapus, hasil: $success');

                    if (!parentContext.mounted) return;
                    Navigator.of(parentContext, rootNavigator: true).pop();

                    if (success) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text('✅ Buku berhasil dihapus')),
                      );
                      _fetchBooks();
                    } else {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text('❌ Gagal menghapus buku')),
                      );
                    }
                  } catch (e) {
                    if (parentContext.mounted) {
                      Navigator.of(parentContext, rootNavigator: true).pop();
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text('❌ Terjadi kesalahan: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Data Buku'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Judul Buku',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/add-book');
                if (result == true) {
                  _fetchBooks();
                }
              },
              icon: Icon(Icons.add),
              label: Text('Tambah Buku'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Terjadi kesalahan: $_error'))
                      : _filteredBooks.isEmpty
                      ? const Center(child: Text('Tidak ada buku yang cocok.'))
                      : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.deepPurple.shade100,
                            ),
                            columns: const [
                              DataColumn(label: Text('Gambar')),
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Judul')),
                              DataColumn(label: Text('Kategori')),
                              DataColumn(label: Text('Penulis')),
                              DataColumn(label: Text('Stok')),
                              DataColumn(label: Text('Aksi')),
                            ],
                            rows:
                                _filteredBooks.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final book = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 50,
                                          height: 70,
                                          child:
                                              book.imageUrl.isNotEmpty
                                                  ? Image.network(
                                                    book.imageUrl,
                                                    width: 50,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                        ),
                                                  )
                                                  : Icon(Icons.book, size: 40),
                                        ),
                                      ),

                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(book.judul)),
                                      DataCell(Text(book.category)),
                                      DataCell(Text(book.penulis)),
                                      DataCell(Text(book.stok.toString())),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) =>
                                                                EditBookScreen(
                                                                  book: book,
                                                                ),
                                                      ),
                                                    );
                                                if (result == true) {
                                                  _fetchBooks();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                print(
                                                  'Tombol delete ditekan untuk buku ID: ${book.id}',
                                                );
                                                _confirmDelete(book);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
