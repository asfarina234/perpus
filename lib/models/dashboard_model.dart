class DashboardData {
  final int totalAnggota;
  final int totalBuku;
  final int totalPeminjaman;
  final int totalTerlambat;
  final List<Anggota> anggotaList;

  DashboardData({
    required this.totalAnggota,
    required this.totalBuku,
    required this.totalPeminjaman,
    required this.totalTerlambat,
    required this.anggotaList,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalAnggota: json['totalAnggota'] ?? 0,
      totalBuku: json['totalBuku'] ?? 0,
      totalPeminjaman: json['totalPeminjaman'] ?? 0,
      totalTerlambat: json['totalTerlambat'] ?? 0,
      anggotaList:
          (json['anggotaList'] as List<dynamic>)
              .map((e) => Anggota.fromJson(e))
              .toList(),
    );
  }
}

class Anggota {
  final String nama;
  final String jurusan;
  final String? nomorTelepon;
  final String? gender;

  Anggota({
    required this.nama,
    required this.jurusan,
    required this.nomorTelepon,
    required this.gender,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      nama: json['nama'] ?? '-',
      jurusan: json['jurusan'] ?? '-', // jika jurusan belum disediakan
      nomorTelepon: json['nomorTelepon'], // sesuai JSON
      gender: json['gender'], // sesuai JSON
    );
  }
}
