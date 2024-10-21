import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class LabelPage extends StatefulWidget {
  final Item item;
  final String itemDescription;
  final String contentAmount;
  final String expirationDate;
  final String storageMethod;
  final double totalPrice;
  final double unitValue;
  final double sellingPrice;
  final double totalQuantity; // 追加

  LabelPage({
    required this.item,
    required this.itemDescription,
    required this.contentAmount,
    required this.expirationDate,
    required this.storageMethod,
    required this.totalPrice,
    required this.unitValue,
    required this.sellingPrice,
    required this.totalQuantity, // 追加
  });

  @override
  _LabelPageState createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController materialCostController = TextEditingController();
  final TextEditingController pricePerUnitController = TextEditingController();

  double materialCost = 0.0;

  @override
  void initState() {
    super.initState();
    pricePerUnitController.text = widget.sellingPrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final manufacturerName =
        '${appState.manufacturer.companyName} ${appState.manufacturer.individualName}';
    final manufacturerAddress = appState.manufacturer.address;
    final manufacturerPhone = appState.manufacturer.phoneNumber;

    _saveData(manufacturerName, manufacturerAddress, manufacturerPhone);

    String ingredients = widget.item.segments.map((segment) {
      return segment.origin.isNotEmpty
          ? '${segment.itemName} (${segment.origin})'
          : segment.itemName;
    }).join('、');

    double totalMaterialCost = widget.item.segments
        .fold(0, (sum, segment) => sum + _calculateSegmentCost(segment));
    totalMaterialCost += materialCost;

    double costPerUnit =
        (widget.unitValue != 0) ? totalMaterialCost / widget.unitValue : 0.0;
    double pricePerUnit = double.tryParse(pricePerUnitController.text) ?? 0.0;

    double costRate =
        (pricePerUnit != 0) ? (costPerUnit / pricePerUnit) * 100 : 0.0;
    double grossProfit = pricePerUnit - costPerUnit;

    double contentAmountValue = double.tryParse(widget.contentAmount) ?? 1.0;
    double pricePerContent = pricePerUnit * contentAmountValue;
    double costPerContent = costPerUnit * contentAmountValue;
    double grossProfitPerContent = pricePerContent - costPerContent;

    // 総数あたりの計算
    double pricePerTotalQuantity = pricePerUnit * widget.totalQuantity;
    double costPerTotalQuantity = costPerUnit * widget.totalQuantity;
    double grossProfitPerTotalQuantity =
        pricePerTotalQuantity - costPerTotalQuantity;

    return Scaffold(
      appBar: AppBar(
        title: Text('ラベル生成'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _captureAndSavePng();
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLabelRow('商品名', widget.item.name),
                    _buildLabelRow('名称', widget.itemDescription),
                    _buildLabelRow('原材料名', ingredients),
                    _buildLabelRow(widget.expirationDate, ''),
                    _buildLabelRow('内容量', widget.contentAmount),
                    _buildLabelRow('保存方法', widget.storageMethod.split('：')[1]),
                    _buildLabelRow('製造者', manufacturerName),
                    _buildLabelRow('住所', manufacturerAddress),
                    _buildLabelRow('電話番号', manufacturerPhone),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10.0),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: materialCostController,
                    decoration: InputDecoration(
                      labelText: '資材費（全体）',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        materialCost = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: pricePerUnitController,
                    decoration: InputDecoration(
                      labelText: '1個あたり売値（円）',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        pricePerUnitController.text = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildInfoRow('1個あたり原価', '${costPerUnit.round()}円'),
                  _buildInfoRow('1個あたり粗利', '${grossProfit.round()}円'),
                  _buildInfoRow('原価率', '${costRate.round()}%'),
                  Divider(),
                  _buildInfoRow('内容量あたりの原価', '${costPerContent.round()}円'),
                  _buildInfoRow('内容量あたりの売値', '${pricePerContent.round()}円'),
                  _buildInfoRow(
                      '内容量あたりの粗利', '${grossProfitPerContent.round()}円'),
                  Divider(),
                  _buildInfoRow('総数あたりの原価', '${costPerTotalQuantity.round()}円'),
                  _buildInfoRow(
                      '総数あたりの売値', '${pricePerTotalQuantity.round()}円'),
                  _buildInfoRow(
                      '総数あたりの粗利', '${grossProfitPerTotalQuantity.round()}円'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSegmentCost(Segment segment) {
    double unit = double.tryParse(segment.unit) ?? 0.0;
    double totalAmount = double.tryParse(segment.totalAmount) ?? 1.0;
    double purchasePrice = double.tryParse(segment.purchasePrice) ?? 0.0;
    if (totalAmount == 0) return 0.0;
    return (unit / totalAmount) * purchasePrice;
  }

  Widget _buildLabelRow(String title, String content, {bool boldTitle = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 7.0,
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
          Text(title, style: TextStyle(fontSize: 18.0)),
          Text(value, style: TextStyle(fontSize: 18.0)),
        ],
      ),
    );
  }

  Future<void> _saveData(
      String manufacturerName, String manufacturerAddress, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('itemName', widget.item.name);
    await prefs.setString('itemDescription', widget.itemDescription);
    await prefs.setString('contentAmount', widget.contentAmount);
    await prefs.setString('expirationDate', widget.expirationDate);
    await prefs.setString('storageMethod', widget.storageMethod.split('：')[1]);
    await prefs.setString('manufacturerName', manufacturerName);
    await prefs.setString('manufacturerAddress', manufacturerAddress);
    await prefs.setString('manufacturerPhone', phone);

    await prefs.setStringList('ingredients',
        widget.item.segments.map((segment) => segment.itemName).toList());
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      materialCost = prefs.getDouble('materialCost') ?? 0.0;
    });
  }

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

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
