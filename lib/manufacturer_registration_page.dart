import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Providerをインポート
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesをインポート
import 'item_addition_page.dart'; // item_addition_page.dart をインポート
import 'app_state.dart'; // AppStateをインポート

class ManufacturerRegistrationPage extends StatefulWidget {
  @override
  _ManufacturerRegistrationPageState createState() =>
      _ManufacturerRegistrationPageState();
}

class _ManufacturerRegistrationPageState
    extends State<ManufacturerRegistrationPage> {
  // TextEditingControllerを追加
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController individualNameController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // データのロード
  }

  // データのロード
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      companyNameController.text = prefs.getString('companyName') ?? '';
      individualNameController.text = prefs.getString('individualName') ?? '';
      addressController.text = prefs.getString('address') ?? '';
      phoneNumberController.text = prefs.getString('phoneNumber') ?? '';
    });
  }

  // データの保存
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('companyName', companyNameController.text);
    await prefs.setString('individualName', individualNameController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('phoneNumber', phoneNumberController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('製造者登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: companyNameController, // コントローラーを設定
                decoration: InputDecoration(
                  labelText: '会社名（学校）',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _saveData(), // データの保存
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: individualNameController, // コントローラーを設定
                decoration: InputDecoration(
                  labelText: '個人名',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _saveData(), // データの保存
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: addressController, // コントローラーを設定
                decoration: InputDecoration(
                  labelText: '住所',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _saveData(), // データの保存
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: phoneNumberController, // コントローラーを設定
                decoration: InputDecoration(
                  labelText: '電話番号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _saveData(), // データの保存
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // AppStateを更新
                  Provider.of<AppState>(context, listen: false)
                      .updateManufacturer(
                    ManufacturerModel(
                      companyName: companyNameController.text,
                      individualName: individualNameController.text,
                      address: addressController.text,
                      phoneNumber: phoneNumberController.text,
                    ),
                  );

                  print('製造者登録が完了しました');

                  // item_addition_pageに遷移する
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ItemAdditionPage()),
                  );
                },
                child: Text('製造者登録'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
