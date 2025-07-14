class Book {
  final int? id;
  final String judul;
  final String penulis;
  final String category;
  final String imageUrl;
  final int stok;
  final String synopsis;

  Book({
    this.id,
    required this.judul,
    required this.penulis,
    required this.category,
    this.imageUrl = '',
    required this.stok,
    this.synopsis = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      stok: json['stok'] ?? 0,
      synopsis: json['synopsis'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'penulis': penulis,
      'category': category,
      'imageUrl': imageUrl,
      'stok': stok,
      'synopsis': synopsis,
    };
  }
}
