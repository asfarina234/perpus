import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _penulisController;
  late TextEditingController _categoryController;
  late TextEditingController _stokController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.book.judul);
    _penulisController = TextEditingController(text: widget.book.penulis);
    _categoryController = TextEditingController(text: widget.book.category);
    _stokController = TextEditingController(text: widget.book.stok.toString());
    _imageUrlController = TextEditingController(text: widget.book.imageUrl);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _categoryController.dispose();
    _stokController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final updatedBook = Book(
        id: widget.book.id,
        judul: _judulController.text,
        penulis: _penulisController.text,
        category: _categoryController.text,
        imageUrl: _imageUrlController.text,
        stok: int.tryParse(_stokController.text) ?? 0,
      );

      final success = await BookService.updateBook(updatedBook);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Buku berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Gagal memperbarui buku')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Penulis tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori (fiksi/nonfiksi)',
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Kategori tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Stok tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link Gambar Buku (opsional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBook,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
