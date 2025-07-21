class BarangModel {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String gambar;
  final String keterangan;
  final String kategori;
  final String createdAt;
  final String updatedAt;
  int jumlahKeranjang = 0;

  BarangModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.gambar,
    required this.keterangan,
    required this.kategori,
    required this.createdAt,
    required this.updatedAt,
    this.jumlahKeranjang = 0,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
      gambar: json['gambar'],
      keterangan: json['keterangan'],
      kategori: json['kategori'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'gambar': gambar,
      'keterangan': keterangan,
      'kategori': kategori,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 