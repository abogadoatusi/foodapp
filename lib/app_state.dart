// lib/app_state.dart

import 'package:flutter/material.dart';
import 'item_model.dart';

class ManufacturerModel {
  String companyName = '';
  String individualName = '';
  String address = '';
  String phoneNumber = '';

  ManufacturerModel({
    this.companyName = '',
    this.individualName = '',
    this.address = '',
    this.phoneNumber = '',
  });

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

  void updateItem(Item newItem) {
    currentItem = newItem;
    notifyListeners(); // UIを更新
  }

  void updateManufacturer(ManufacturerModel newManufacturer) {
    manufacturer = newManufacturer;
    notifyListeners(); // UIを更新
  }

  void updateManufacturerInfo(
      String company, String individual, String addr, String phone) {
    manufacturer.updateManufacturerInfo(company, individual, addr, phone);
    notifyListeners();
  }

  // Emailを更新するメソッド
  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  // Passwordを更新するメソッド
  void updatePassword(String newPassword) {
    password = newPassword;
    notifyListeners();
  }
}
