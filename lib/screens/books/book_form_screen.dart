import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;
  final bool isEdit;

  const BookFormScreen({super.key, this.book}) : isEdit = book != null;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  final List<String> _kategoriList = ['Fiksi', 'Non-Fiksi'];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.judul ?? '');
    _authorController = TextEditingController(text: widget.book?.penulis ?? '');
    _imageUrlController.text = widget.book?.imageUrl ?? '';
    _stokController.text = widget.book?.stok.toString() ?? '';
    _selectedCategory = widget.book?.category ?? _kategoriList.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.book?.id,
        judul: _titleController.text,
        penulis: _authorController.text,
        category: _selectedCategory ?? '',
        imageUrl: _imageUrlController.text,
        stok: int.tryParse(_stokController.text) ?? 0,
      );

      bool success;
      if (widget.isEdit) {
        success = await BookService.updateBook(book);
      } else {
        success = await BookService.addBook(book);
      }

      if (success && mounted) {
        Navigator.pop(context, true); // Kirim sinyal sukses
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan buku')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit Buku' : 'Tambah Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator:
                    (value) => value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (value) => value!.isEmpty ? 'Penulis wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items:
                    _kategoriList.map((kategori) {
                      return DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Kategori wajib dipilih'
                            : null,
              ),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok Buku'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (opsional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.isEdit ? 'Simpan Perubahan' : 'Tambah Buku'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
