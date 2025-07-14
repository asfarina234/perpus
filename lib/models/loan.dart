class Loan {
  final String nama;
  final String jurusan;
  final String gender;
  final String judulBuku;
  final String status;

  Loan({
    required this.nama,
    required this.jurusan,
    required this.gender,
    required this.judulBuku,
    required this.status,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      nama: json['nama'] ?? '',
      jurusan: json['jurusan'] ?? '',
      gender: json['gender'] ?? '',
      judulBuku: json['judul_buku'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
