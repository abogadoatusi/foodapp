import 'package:flutter/material.dart';
import 'item_model.dart';

class ManufacturerModel {
  String companyName;
  String individualName;
  String address;
  String phoneNumber;

  // 初期値を空文字列で設定
  ManufacturerModel({
    this.companyName = '',
    this.individualName = '',
    this.address = '',
    this.phoneNumber = '',
  });

  // 製造者情報を更新するメソッド
  void updateManufacturerInfo(
      String company, String individual, String addr, String phone) {
    companyName = company;
    individualName = individual;
    address = addr;
    phoneNumber = phone;
  }
}

class AppState extends ChangeNotifier {
  ManufacturerModel manufacturer = ManufacturerModel();
  Item currentItem = Item(name: '');
  String email = ''; // Emailを保持するフィールド
  String password = ''; // Passwordを保持するフィールド

  // アイテム情報を更新するメソッド
  void updateItem(Item newItem) {
    currentItem = newItem;
    notifyListeners(); // UIを更新
  }

  // 製造者情報を更新するメソッド
  void updateManufacturer(ManufacturerModel newManufacturer) {
    manufacturer = newManufacturer;
    notifyListeners(); // UIを更新
  }

  // 製造者情報の個別フィールドを更新するメソッド
  void updateManufacturerInfo(
      String company, String individual, String addr, String phone) {
    manufacturer.updateManufacturerInfo(company, individual, addr, phone);
    notifyListeners();
  }

  // Emailを更新するメソッド
  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners(); // UIを更新
  }

  // Passwordを更新するメソッド
  void updatePassword(String newPassword) {
    password = newPassword;
    notifyListeners(); // UIを更新
  }
}
