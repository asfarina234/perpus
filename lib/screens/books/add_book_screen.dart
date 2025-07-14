import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  String _selectedCategory = 'fiksi';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        judul: _judulController.text,
        category: _selectedCategory,
        penulis: _penulisController.text,
        stok: int.parse(_stokController.text),
      );

      bool success = await BookService.addBook(newBook);

      if (success) {
        Navigator.pop(context, true); // Kirim sinyal sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil ditambahkan!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menambahkan buku')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Buku'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator:
                    (value) => value!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'fiksi', child: Text('Fiksi')),
                  DropdownMenuItem(
                    value: 'non-fiksi',
                    child: Text('Non-Fiksi'),
                  ),
                ],
                onChanged:
                    (value) => setState(() => _selectedCategory = value!),
              ),
              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator:
                    (value) => value!.isEmpty ? 'Penulis wajib diisi' : null,
              ),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Stok wajib diisi';
                  if (int.tryParse(value) == null)
                    return 'Stok harus berupa angka';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(child: const Text('Simpan'), onPressed: _submitForm),
      ],
    );
  }
}
