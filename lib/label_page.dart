import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesをインポート
import 'item_model.dart'; // Itemモデルをインポート
import 'package:provider/provider.dart'; // Providerをインポート
import 'app_state.dart'; // AppStateをインポート
import 'dart:typed_data';
import 'package:flutter/rendering.dart'; // RenderRepaintBoundaryのためのインポート
import 'dart:ui' as ui;
import 'dart:html' as html; // Web用のHTMLライブラリ

class LabelPage extends StatelessWidget {
  final Item item;
  final String itemDescription;
  final String contentAmount;
  final String expirationDate;
  final String storageMethod;
  final double totalPrice; // item_detail_page.dartの金額合計
  final double unitValue; // item_summary_page.dartの単位
  final double sellingPrice; // item_summary_page.dartの売値

  LabelPage({
    required this.item,
    required this.itemDescription,
    required this.contentAmount,
    required this.expirationDate,
    required this.storageMethod,
    required this.totalPrice,
    required this.unitValue,
    required this.sellingPrice,
  });

  final GlobalKey _globalKey = GlobalKey(); // 画像を保存するためのキーを追加

  @override
  Widget build(BuildContext context) {
    // Provider から製造者情報を取得
    final appState = Provider.of<AppState>(context, listen: false);
    final manufacturerName =
        '${appState.manufacturer.companyName} ${appState.manufacturer.individualName}';
    final manufacturerAddress = appState.manufacturer.address;

    _saveData(manufacturerName, manufacturerAddress); // データを保存

    // 原材料名をまとめる
    String ingredients = item.segments.map((segment) {
      return segment.origin.isNotEmpty
          ? '${segment.itemName} (${segment.origin})'
          : segment.itemName;
    }).join('、');

    // 1個あたりの原価、原価率、粗利益を計算
    double costPerUnit = totalPrice / unitValue;
    double costRate = (costPerUnit / sellingPrice) * 100;
    double grossProfit = sellingPrice - costPerUnit;

    return Scaffold(
      appBar: AppBar(
        title: Text('ラベル生成'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _captureAndSavePng(); // ラベルの画像を保存
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // コンテナの高さをテキスト内容に合わせる
                  children: [
                    _buildLabelRow('商品名', item.name),
                    _buildLabelRow('名称', itemDescription),
                    _buildLabelRow('原材料名', ingredients),
                    _buildLabelRow('内容量', contentAmount),
                    _buildLabelRow(
                        '保存方法', storageMethod.split('：')[1]), // 保存方法の説明のみ表示
                    _buildLabelRow('製造者', manufacturerName),
                    _buildLabelRow('所在地', manufacturerAddress),
                    SizedBox(height: 16.0), // 余白を追加
                    Text(
                      expirationDate, // 期限の表示を簡素化
                      style:
                          TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // 新しく追加する情報の表示
            Container(
              padding: EdgeInsets.all(10.0),
              constraints: BoxConstraints(maxWidth: 250), // コンテナの最大幅を250に設定
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('1個あたり原価', '${costPerUnit.round()}円'),
                  _buildInfoRow('原価率', '${costRate.round()}%'),
                  _buildInfoRow('粗利益', '${grossProfit.round()}円'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelRow(String title, String content, {bool boldTitle = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 7.0, // 7ptを指定
            color: Colors.black,
          ),
          children: [
            if (boldTitle)
              TextSpan(
                text: '【$title】',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            TextSpan(text: ' $content'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18.0)), // フォントサイズを18.0に設定
          Text(value, style: TextStyle(fontSize: 18.0)), // フォントサイズを18.0に設定
        ],
      ),
    );
  }

  Future<void> _saveData(
      String manufacturerName, String manufacturerAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('itemName', item.name);
    await prefs.setString('itemDescription', itemDescription);
    await prefs.setString('contentAmount', contentAmount);
    await prefs.setString('expirationDate', expirationDate);
    await prefs.setString(
        'storageMethod', storageMethod.split('：')[1]); // 説明のみ保存
    await prefs.setString('manufacturerName', manufacturerName);
    await prefs.setString('manufacturerAddress', manufacturerAddress);

    // 原材料名を保存
    await prefs.setStringList('ingredients',
        item.segments.map((segment) => segment.itemName).toList());
  }

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Flutter Webの場合、画像をブラウザでダウンロードする
      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "label.png")
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }
}
