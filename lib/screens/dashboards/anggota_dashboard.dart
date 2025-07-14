import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';

class AnggotaDashboardScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AnggotaDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AnggotaDashboardScreen> createState() => _AnggotaDashboardScreenState();
}

class _AnggotaDashboardScreenState extends State<AnggotaDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi sesuai index
    switch (index) {
      case 0:
        // Home - misal tetap di halaman ini atau navigasi ke halaman home lain
        break;
      case 1:
        // Search - contoh navigasi ke halaman Search (buat halaman Search kalau ada)
        // Navigator.pushNamed(context, '/search');
        break;
      case 2:
        // Account - contoh navigasi ke halaman Account (buat halaman Account kalau ada)
        // Navigator.pushNamed(context, '/account');
        break;
      case 3:
        // Profile - navigasi ke halaman profile dengan token/userId, contoh:
        Navigator.pushNamed(context, '/profile', arguments: widget.userId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Get Started'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildMenuItem(Icons.menu_book, "Catalog", context),
                    _buildMenuItem(Icons.favorite, "Favorites", context),
                    _buildMenuItem(Icons.history, "History", context),
                    _buildMenuItem(Icons.settings, "Settings", context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped, // Handle tap event
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == "Catalog") {
          _showCategoryDialog(context);
        } else {
          Navigator.pushNamed(
            context,
            '/history',
          ); // Tambahkan aksi menu lain bila perlu
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue.shade700),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pilih Kategori Buku"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Fiksi"),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToBookList(context, "Fiksi");
                },
              ),
              ListTile(
                title: const Text("Non-Fiksi"),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToBookList(context, "Non-Fiksi");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToBookList(BuildContext context, String category) {
    Navigator.pushNamed(
      context,
      '/book_list',
      arguments: {
        'userId': widget.userId,
        'category': category,
        'role': 'anggota',
      },
    );
  }
}
