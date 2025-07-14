import 'package:flutter/material.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../screens/books/book_dashboard_screen.dart';
import '../../screens/logout_screen.dart';
import '../../screens/login_screen.dart';
import '../loans/loan_list_screen.dart';
import '../loans/loan_history_screen.dart';

class AdminDashboard extends StatefulWidget {
  final int userId;
  final String userName;

  const AdminDashboard({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  late Future<DashboardData> dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData = DashboardService().fetchDashboardData();
  }

  // === Menu Sidebar ===
  Widget buildSidebar(bool isWide) {
    return ListView(
      padding: const EdgeInsets.only(top: 28, left: 12, right: 12),
      children: [
        buildMenuHeader('HOME'),
        buildMenuTile(0, Icons.dashboard, 'Dashboard'),
        const SizedBox(height: 18),
        buildMenuHeader('MASTER DATA'),
        buildMenuTile(1, Icons.people, 'Data Anggota'),
        buildMenuTile(2, Icons.menu_book, 'Data Buku'),
        const SizedBox(height: 18),
        buildMenuHeader('TRANSAKSI'),
        buildMenuTile(3, Icons.assignment, 'Peminjaman'),
        buildMenuTile(4, Icons.history, 'Riwayat Peminjaman'),
        const SizedBox(height: 18),
        buildMenuHeader('AKSI'),
        buildMenuTile(5, Icons.logout, 'Logout'),
      ],
    );
  }

  Widget buildMenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildMenuTile(int index, IconData icon, String title) {
    final bool isActive = selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.blue : Colors.black87,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.black87,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Card Dashboard ===
  Widget buildInfoCard(
    String title,
    int count,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // === Tabel Data Anggota ===
  Widget buildAnggotaTable(List<Anggota> anggotaList) {
    return DataTable(
      columnSpacing: 18,
      headingRowHeight: 36,
      columns: const [
        DataColumn(label: Text('No')),
        DataColumn(label: Text('Nama')),
        DataColumn(label: Text('Jurusan')),
        DataColumn(label: Text('Nomor Telepon')),
        DataColumn(label: Text('Gender')),
      ],
      rows: List.generate(anggotaList.length, (index) {
        final anggota = anggotaList[index];
        final bool isMale =
            anggota.gender?.toLowerCase() == 'pria' ||
            anggota.gender?.toLowerCase() == 'laki-laki';
        return DataRow(
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(anggota.nama)),
            DataCell(Text(anggota.jurusan ?? '-')),
            DataCell(Text(anggota.nomorTelepon ?? '-')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMale ? Colors.blue : Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  anggota.gender?.toUpperCase() ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // === Body Utama per Halaman ===
  Widget buildPageContent(DashboardData data) {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  buildInfoCard(
                    'Total Anggota',
                    data.totalAnggota,
                    Icons.people,
                    [Colors.blue, Colors.blueAccent],
                  ),
                  buildInfoCard('Total Buku', data.totalBuku, Icons.menu_book, [
                    Colors.teal,
                    Colors.tealAccent,
                  ]),
                  buildInfoCard(
                    'Total Peminjaman',
                    data.totalPeminjaman,
                    Icons.assignment,
                    [Colors.orange, Colors.deepOrange],
                  ),
                  buildInfoCard(
                    'Total Terlambat',
                    data.totalTerlambat,
                    Icons.schedule_outlined,
                    [Colors.red, Colors.redAccent],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Data Anggota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              buildAnggotaTable(data.anggotaList),
            ],
          ),
        );

      case 1:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: buildAnggotaTable(data.anggotaList),
        );

      case 2:
        return BookDashboard();

      case 3:
        return LoanListScreen(); // Buat halaman baru

      case 4:
        return const LoanHistoryScreen(); // Ganti dari 'Coming Soon'

      case 5:
        return const LogoutScreen(); // Panggil screen logout beneran

      default:
        return const Center(child: Text('Halaman Tidak Ditemukan'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth >= 800;

        return Scaffold(
          appBar:
              isWideScreen
                  ? null
                  : AppBar(
                    title: Text('Halo, ${widget.userName}'),
                    backgroundColor: Colors.blueAccent,
                  ),
          drawer:
              isWideScreen ? null : Drawer(child: buildSidebar(isWideScreen)),
          body: Row(
            children: [
              if (isWideScreen)
                SizedBox(
                  width: 260,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: buildSidebar(isWideScreen),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (isWideScreen)
                      Container(
                        height: 56,
                        color: Colors.blueAccent,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Halo, ${widget.userName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Expanded(
                      child: FutureBuilder<DashboardData>(
                        future: dashboardData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Gagal memuat data: ${snapshot.error}',
                              ),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('Data tidak ditemukan.'),
                            );
                          } else {
                            return buildPageContent(snapshot.data!);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
