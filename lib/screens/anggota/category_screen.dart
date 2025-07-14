import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Category")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text("Fiksi"),
            onTap: () {
              // Navigate to Fiksi book list
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book_outlined),
            title: Text("Non Fiksi"),
            onTap: () {
              // Navigate to Non Fiksi book list
            },
          ),
        ],
      ),
    );
  }
}
