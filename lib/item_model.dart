// lib/item_model.dart

import 'package:flutter/material.dart';

class Item {
  String name;
  String unit;
  String origin;
  String price;
  List<Segment> segments; // セグメントのリスト

  Item({
    required this.name,
    this.unit = '',
    this.origin = '',
    this.price = '',
    List<Segment>? segments, // リストをnullableにして初期化
  }) : segments = segments ?? []; // ここでリストを変更可能な空リストで初期化

  // JSONからItemオブジェクトを作成するファクトリコンストラクタ
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      unit: json['unit'] ?? '',
      origin: json['origin'] ?? '',
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
      'origin': origin,
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
  String origin; // ここにoriginプロパティを追加
  bool isAdditiveChecked;
  TextEditingController nameController;
  TextEditingController unitController;
  TextEditingController priceController;
  TextEditingController originController; // originのコントローラーを追加

  Segment({
    this.itemName = '',
    this.unit = '',
    this.price = '',
    this.origin = '', // ここに初期値を設定
    this.isAdditiveChecked = false,
    TextEditingController? nameController,
    TextEditingController? unitController,
    TextEditingController? priceController,
    TextEditingController? originController,
  })  : nameController =
            nameController ?? TextEditingController(text: itemName),
        unitController = unitController ?? TextEditingController(text: unit),
        priceController = priceController ?? TextEditingController(text: price),
        originController =
            originController ?? TextEditingController(text: origin);

  // JSONからSegmentオブジェクトを作成するファクトリコンストラクタ
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      itemName: json['itemName'] ?? '',
      unit: json['unit'] ?? '',
      price: json['price'] ?? '',
      origin: json['origin'] ?? '',
      isAdditiveChecked: json['isAdditiveChecked'] ?? false,
    );
  }

  // SegmentオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'unit': unit,
      'price': price,
      'origin': origin,
      'isAdditiveChecked': isAdditiveChecked,
    };
  }
}
