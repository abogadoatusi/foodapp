import 'package:flutter/material.dart';
import 'item_model.dart'; // Itemモデルをインポート
import 'package:intl/intl.dart'; // 日付操作のためのパッケージ
import 'label_page.dart'; // ラベルページをインポート
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferencesをインポート
import 'dart:convert'; // JSON操作のためのパッケージ

class ItemDetailPage extends StatefulWidget {
  final Item item; // 商品情報を保持するItemモデル

  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String? selectedStorageMethod; // 保存方法の選択
  String storageInstruction = ''; // 保存方法の説明を保持
  DateTime manufacturingDate = DateTime.now(); // 製造日
  List<String> expirationOptions = []; // 賞味期限と消費期限のオプションリスト

  String? selectedExpirationOption; // 賞味期限または消費期限の選択
  String expirationInstruction = ''; // 賞味期限/消費期限の説明

  String? selectedUnitType = 'g'; // 単位の種類 ("g" または "個数")
  int expirationDays = 0; // 入力された消費期限日数

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController totalQuantityController = TextEditingController();
  TextEditingController unitValueController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController expirationDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // ページロード時にデータを読み込む
    _loadSegments(); // セグメント（各品目）のロード
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      itemNameController.text =
          prefs.getString('itemName_${widget.item.name}') ?? widget.item.name;
      itemDescriptionController.text =
          prefs.getString('itemDescription_${widget.item.name}') ?? '';
      totalQuantityController.text =
          prefs.getString('totalQuantity_${widget.item.name}') ?? '';
      unitValueController.text =
          prefs.getString('unitValue_${widget.item.name}') ?? '';
      selectedUnitType =
          prefs.getString('selectedUnitType_${widget.item.name}') ?? 'g';
      selectedStorageMethod =
          prefs.getString('selectedStorageMethod_${widget.item.name}') ??
              '常温：高温多湿を避け常温で保存';
      storageInstruction =
          prefs.getString('storageInstruction_${widget.item.name}') ??
              '高温多湿を避け常温で保存';
      priceController.text =
          prefs.getString('price_${widget.item.name}') ?? widget.item.price;
      selectedExpirationOption =
          prefs.getString('selectedExpirationOption_${widget.item.name}');
      expirationInstruction =
          prefs.getString('expirationInstruction_${widget.item.name}') ?? '';
      expirationDays = prefs.getInt('expirationDays_${widget.item.name}') ??
          0; // 保存された消費期限日数を取得
      expirationDaysController.text = expirationDays.toString(); // コントローラに値を設定
      _updateExpirationOptions(); // 賞味期限/消費期限の更新
    });
  }

  void _loadSegments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemJson = prefs.getString('item_${widget.item.name}');
    if (itemJson != null) {
      setState(() {
        widget.item.segments = List<Segment>.from(
          (jsonDecode(itemJson)['segments'] as List).map(
            (segmentJson) => Segment.fromJson(segmentJson),
          ),
        );
      });
    }

    // 初期表示時にセグメントが空の場合に1つの空セグメントを追加
    if (widget.item.segments.isEmpty) {
      setState(() {
        widget.item.segments.add(Segment(
          itemName: '',
          unit: '',
          price: '',
          isAdditiveChecked: false,
          totalAmount: '',
          purchasePrice: '',
        ));
      });
    }

    _sortSegments(); // セグメントの並び替え
  }

  void _saveSegments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'item_${widget.item.name}', jsonEncode(widget.item.toJson()));
    _sortSegments();
  }

  void _sortSegments() {
    setState(() {
      widget.item.segments.sort((a, b) {
        if (a.isAdditiveChecked && !b.isAdditiveChecked) {
          return 1;
        } else if (!a.isAdditiveChecked && b.isAdditiveChecked) {
          return -1;
        } else {
          double aUnit = double.tryParse(a.unit) ?? 0.0;
          double bUnit = double.tryParse(b.unit) ?? 0.0;
          return bUnit.compareTo(aUnit);
        }
      });
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'itemName_${widget.item.name}', itemNameController.text);
    await prefs.setString(
        'itemDescription_${widget.item.name}', itemDescriptionController.text);
    await prefs.setString(
        'totalQuantity_${widget.item.name}', totalQuantityController.text);
    await prefs.setString(
        'unitValue_${widget.item.name}', unitValueController.text);
    await prefs.setString(
        'selectedUnitType_${widget.item.name}', selectedUnitType ?? 'g');
    await prefs.setString('selectedStorageMethod_${widget.item.name}',
        selectedStorageMethod ?? '');
    await prefs.setString(
        'storageInstruction_${widget.item.name}', storageInstruction);
    await prefs.setString('price_${widget.item.name}', priceController.text);
    await prefs.setString('selectedExpirationOption_${widget.item.name}',
        selectedExpirationOption ?? '');
    await prefs.setString(
        'expirationInstruction_${widget.item.name}', expirationInstruction);
    await prefs.setInt(
        'expirationDays_${widget.item.name}', expirationDays); // 消費期限日数を保存
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ登録'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.item.segments.length,
                itemBuilder: (context, index) {
                  return _buildSegment(widget.item.segments[index], index);
                },
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              _buildSummaryForm(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _saveData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LabelPage(
                        item: widget.item,
                        itemDescription: itemDescriptionController.text,
                        contentAmount: unitValueController.text,
                        expirationDate: selectedExpirationOption ?? '',
                        storageMethod: selectedStorageMethod ?? '',
                        totalPrice:
                            double.tryParse(priceController.text) ?? 0.0,
                        unitValue:
                            double.tryParse(unitValueController.text) ?? 1.0,
                        sellingPrice:
                            double.tryParse(priceController.text) ?? 1.0,
                        totalQuantity:
                            double.tryParse(totalQuantityController.text) ??
                                1.0,
                      ),
                    ),
                  );
                },
                child: const Text('確認'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(Segment segment, int index) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: segment.nameController,
              decoration: const InputDecoration(
                labelText: '原材料名',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  segment.itemName = value;
                  _saveSegments();
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: segment.unitController,
              decoration: const InputDecoration(
                labelText: '1ロットあたりの使用量（g)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  segment.unit = value;
                  _saveSegments();
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: segment.totalAmountController,
              decoration: const InputDecoration(
                labelText: '原材料内容量（g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  segment.totalAmount = value;
                  _saveSegments();
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: segment.purchasePriceController,
              decoration: const InputDecoration(
                labelText: '購入時の金額(税込）',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  segment.purchasePrice = value;
                  _saveSegments();
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              '材料費: ${_calculateCost(segment)}円',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: const Text('添加物'),
              value: segment.isAdditiveChecked,
              onChanged: (bool? value) {
                setState(() {
                  segment.isAdditiveChecked = value ?? false;
                  _saveSegments();
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.item.segments.add(Segment(
                    itemName: '',
                    unit: '',
                    price: '',
                    isAdditiveChecked: false,
                    totalAmount: '',
                    purchasePrice: '',
                  ));
                  _saveSegments();
                });
              },
              child: const Text('品目追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.item.segments.removeAt(index);
                  _saveSegments();
                });
              },
              child: const Text('削除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateCost(Segment segment) {
    double unit = double.tryParse(segment.unit) ?? 0.0;
    double totalAmount = double.tryParse(segment.totalAmount) ?? 1.0;
    double purchasePrice = double.tryParse(segment.purchasePrice) ?? 0.0;
    if (totalAmount == 0) return 0.0;
    return (unit / totalAmount) * purchasePrice;
  }

  Widget _buildSummaryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '商品名',
            border: OutlineInputBorder(),
          ),
          controller: itemNameController,
          onChanged: (value) => _saveData(),
        ),
        const SizedBox(height: 16.0),
        TextField(
          decoration: const InputDecoration(
            labelText: '名称',
            border: OutlineInputBorder(),
          ),
          controller: itemDescriptionController,
          onChanged: (value) => _saveData(),
        ),
        const SizedBox(height: 16.0),
        TextField(
          decoration: const InputDecoration(
            labelText: '総数',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: totalQuantityController,
          onChanged: (value) => _saveData(),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '単位の数値',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: unitValueController,
                onChanged: (value) {
                  _saveData();
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '単位',
                  border: OutlineInputBorder(),
                ),
                value: selectedUnitType,
                items: ['g', '個'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnitType = newValue;
                  });
                  _saveData();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextField(
          decoration: const InputDecoration(
            labelText: '消費日数 (日数)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: expirationDaysController,
          onChanged: (value) {
            setState(() {
              expirationDays = int.tryParse(value) ?? 0;
              _updateExpirationOptions();
              _saveData();
            });
          },
        ),
        const SizedBox(height: 16.0),
        if (expirationOptions.isNotEmpty)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '賞味期限/消費期限',
              border: OutlineInputBorder(),
            ),
            value: expirationOptions.contains(selectedExpirationOption)
                ? selectedExpirationOption
                : null,
            items: expirationOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedExpirationOption = newValue;
                expirationInstruction = newValue != null
                    ? (newValue.contains('賞味期限')
                        ? '賞味期限：製造日＋５以上'
                        : '消費期限：製造日＋４以内')
                    : '';
                _saveData();
              });
            },
          ),
        if (expirationInstruction.isNotEmpty)
          Text(
            '期限の説明: $expirationInstruction',
            style: const TextStyle(color: Colors.black54),
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  void _updateExpirationOptions() {
    if (expirationDays > 0) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      DateTime expirationDate =
          manufacturingDate.add(Duration(days: expirationDays));
      if (expirationDays >= 5) {
        setState(() {
          expirationOptions = ['賞味期限：${dateFormat.format(expirationDate)}'];
        });
      } else {
        setState(() {
          expirationOptions = ['消費期限：${dateFormat.format(expirationDate)}'];
        });
      }
    } else {
      setState(() {
        expirationOptions.clear();
      });
    }
  }
}
