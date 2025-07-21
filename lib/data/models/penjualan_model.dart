import 'package:myatk/data/models/barang_model.dart';

class PenjualanModel {
  final int id;
  final String tanggal;
  final String faktur;
  final int barangId;
  final int qty;
  final int total;
  final String createdAt;
  final String updatedAt;
  final BarangModel? barang;

  PenjualanModel({
    required this.id,
    required this.tanggal,
    required this.faktur,
    required this.barangId,
    required this.qty,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.barang,
  });

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    return PenjualanModel(
      id: json['id'],
      tanggal: json['tanggal'],
      faktur: json['faktur'],
      barangId: json['barang_id'],
      qty: json['qty'],
      total: json['total'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      barang: json['barang'] != null ? BarangModel.fromJson(json['barang']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'faktur': faktur,
      'barang_id': barangId,
      'qty': qty,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PenjualanRequestModel {
  final String tanggal;
  final String faktur;
  final int barangId;
  final int qty;
  // total tidak dimasukkan ke request karena akan dihitung otomatis di server
  // berdasarkan harga barang dan qty

  PenjualanRequestModel({
    required this.tanggal,
    required this.faktur,
    required this.barangId,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    // Perbaiki sesuai dengan yang diharapkan API
    // Pastikan field "barang_id" digunakan, bukan "barangId"
    return {
      'tanggal': tanggal,
      'faktur': faktur,
      'barang_id': barangId,
      'qty': qty,
    };
  }
}

class CheckoutRequestModel {
  final String tanggal;
  final String faktur;
  final List<CheckoutItemModel> items;

  CheckoutRequestModel({
    required this.tanggal,
    required this.faktur,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'faktur': faktur,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CheckoutItemModel {
  final int barangId;
  final int qty;

  CheckoutItemModel({
    required this.barangId,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'barang_id': barangId,
      'qty': qty,
    };
  }
} 