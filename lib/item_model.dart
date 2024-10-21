import 'package:flutter/material.dart';

class Item {
  String name;
  String unit;
  String price;
  List<Segment> segments; // セグメントのリスト

  Item({
    required this.name,
    this.unit = '',
    this.price = '',
    List<Segment>? segments, // リストをnullableにして初期化
  }) : segments = segments ?? []; // ここでリストを変更可能な空リストで初期化

  // JSONからItemオブジェクトを作成するファクトリコンストラクタ
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      unit: json['unit'] ?? '',
      price: json['price'] ?? '',
      segments: json['segments'] != null
          ? (json['segments'] as List)
              .map((segmentJson) => Segment.fromJson(segmentJson))
              .toList()
          : [],
    );
  }

  // ItemオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'price': price,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }
}

// セグメントクラスの定義
class Segment {
  String itemName;
  String unit;
  String price;
  bool isAdditiveChecked;
  String totalAmount; // 内容量（g）
  String purchasePrice; // 購入時の金額
  String origin; // 追加されたプロパティ
  TextEditingController nameController;
  TextEditingController unitController;
  TextEditingController priceController;
  TextEditingController totalAmountController; // totalAmountのコントローラ
  TextEditingController purchasePriceController; // purchasePriceのコントローラ
  TextEditingController originController; // originのコントローラ

  // コンストラクタ
  Segment({
    this.itemName = '',
    this.unit = '',
    this.price = '',
    this.isAdditiveChecked = false,
    this.totalAmount = '',
    this.purchasePrice = '',
    this.origin = '', // 追加されたプロパティ
    TextEditingController? nameController,
    TextEditingController? unitController,
    TextEditingController? priceController,
    TextEditingController? totalAmountController,
    TextEditingController? purchasePriceController,
    TextEditingController? originController,
  })  : nameController =
            nameController ?? TextEditingController(text: itemName),
        unitController = unitController ?? TextEditingController(text: unit),
        priceController = priceController ?? TextEditingController(text: price),
        totalAmountController =
            totalAmountController ?? TextEditingController(text: totalAmount),
        purchasePriceController = purchasePriceController ??
            TextEditingController(text: purchasePrice),
        originController =
            originController ?? TextEditingController(text: origin);

  // JSONからSegmentオブジェクトを作成するファクトリコンストラクタ
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      itemName: json['itemName'] ?? '',
      unit: json['unit'] ?? '',
      price: json['price'] ?? '',
      isAdditiveChecked: json['isAdditiveChecked'] ?? false,
      totalAmount: json['totalAmount'] ?? '', // 追加
      purchasePrice: json['purchasePrice'] ?? '', // 追加
      origin: json['origin'] ?? '', // 追加
    );
  }

  // SegmentオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'unit': unit,
      'price': price,
      'isAdditiveChecked': isAdditiveChecked,
      'totalAmount': totalAmount, // 追加
      'purchasePrice': purchasePrice, // 追加
      'origin': origin, // 追加
    };
  }
}
