import 'package:flutter/material.dart';
import 'item_model.dart'; // Itemモデルをインポート
import 'package:intl/intl.dart'; // 日付操作のためのパッケージ
import 'label_page.dart'; // ラベルページをインポート
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferencesをインポート
import 'dart:convert';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  ItemDetailPage({required this.item});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String? selectedStorageMethod;
  String storageInstruction = ''; // 保存方法の説明を保持する変数
  DateTime? manufacturingDate; // 製造日を保持する変数
  List<String> expirationOptions = []; // 賞味期限と消費期限のオプションリスト

  String? selectedExpirationOption; // 選択された賞味期限または消費期限
  String expirationInstruction = ''; // 賞味期限/消費期限の説明を保持する変数

  String? selectedUnitType; // 選択された単位の種類 ("g" または "個数")

  TextEditingController itemNameController =
      TextEditingController(); // 商品名のコントローラ
  TextEditingController itemDescriptionController =
      TextEditingController(); // 名称のコントローラ
  TextEditingController unitValueController =
      TextEditingController(); // 単位の数値のコントローラ
  TextEditingController priceController = TextEditingController(); // 売値のコントローラ
  TextEditingController manufacturingDateController =
      TextEditingController(); // 製造日のコントローラ

  @override
  void initState() {
    super.initState();
    _loadData(); // ページロード時にデータを読み込む
    _loadSegments(); // セグメントのロード
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      itemNameController.text =
          prefs.getString('itemName_${widget.item.name}') ?? widget.item.name;
      itemDescriptionController.text =
          prefs.getString('itemDescription_${widget.item.name}') ?? '';
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
      String? manufacturingDateString =
          prefs.getString('manufacturingDate_${widget.item.name}');
      if (manufacturingDateString != null) {
        manufacturingDate =
            DateFormat('yyyy-MM-dd').parse(manufacturingDateString);
        manufacturingDateController.text =
            DateFormat('yyyy-MM-dd').format(manufacturingDate!);
        _updateExpirationOptions();
      }
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
        _sortSegments(); // セグメントを並び替える
      });
    }
  }

  void _saveSegments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'item_${widget.item.name}', jsonEncode(widget.item.toJson()));
    _sortSegments(); // セグメントを並び替える
  }

  void _sortSegments() {
    setState(() {
      widget.item.segments.sort((a, b) {
        // 添加物の有無でソートし、添加物があるものを下に
        if (a.isAdditiveChecked && !b.isAdditiveChecked) {
          return 1; // aが添加物あり、bが添加物なしならaを後ろに
        } else if (!a.isAdditiveChecked && b.isAdditiveChecked) {
          return -1; // aが添加物なし、bが添加物ありならaを前に
        } else {
          // 添加物の状態が同じならg数でソート
          double aUnit = double.tryParse(a.unit) ?? 0.0;
          double bUnit = double.tryParse(b.unit) ?? 0.0;
          return bUnit.compareTo(aUnit); // g数が多い順にソート
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
    if (manufacturingDate != null) {
      await prefs.setString('manufacturingDate_${widget.item.name}',
          DateFormat('yyyy-MM-dd').format(manufacturingDate!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('詳細ページ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.item.segments.length,
                itemBuilder: (context, index) {
                  return _buildSegment(widget.item.segments[index], index);
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.item.segments.add(Segment(
                      itemName: '',
                      unit: '',
                      price: '',
                      isAdditiveChecked: false,
                    ));
                    _saveSegments();
                  });
                },
                child: Text('品目追加'),
              ),
              SizedBox(height: 16.0),
              Divider(), // 商品概要部分の開始を示す区切り線
              // 商品概要ページの内容
              _buildSummaryForm(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (itemNameController.text.isEmpty ||
                      itemDescriptionController.text.isEmpty ||
                      priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('全てのフィールドを入力してください')),
                    );
                    return;
                  }
                  _saveData(); // 商品概要のデータを保存
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LabelPage(
                        item: widget.item,
                        itemDescription: itemDescriptionController.text,
                        contentAmount:
                            '${unitValueController.text} $selectedUnitType',
                        expirationDate: selectedExpirationOption ?? '',
                        storageMethod: selectedStorageMethod ?? '',
                        totalPrice:
                            double.tryParse(priceController.text) ?? 0.0,
                        unitValue:
                            double.tryParse(unitValueController.text) ?? 1.0,
                        sellingPrice:
                            double.tryParse(priceController.text) ?? 1.0,
                      ),
                    ),
                  );
                },
                child: Text('確認'),
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
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: segment.nameController,
              decoration: InputDecoration(
                labelText: '品目名',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  segment.itemName = value; // セグメントの品目名を更新
                  _saveSegments(); // セグメントを保存
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: segment.originController,
              decoration: InputDecoration(
                labelText: '産地',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  segment.origin = value; // セグメントの産地を更新
                  _saveSegments(); // セグメントを保存
                });
              },
            ),
            SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('添加物'),
              value: segment.isAdditiveChecked,
              onChanged: (bool? value) {
                setState(() {
                  segment.isAdditiveChecked = value ?? false; // 添加物の状態を更新
                  _saveSegments(); // セグメントを保存
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: segment.unitController,
              decoration: InputDecoration(
                labelText: '単位（g）',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  segment.unit = value; // セグメントの単位を更新
                  _saveSegments(); // セグメントを保存
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: segment.priceController,
              decoration: InputDecoration(
                labelText: '金額',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  segment.price = value; // セグメントの金額を更新
                  _saveSegments(); // セグメントを保存
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.item.segments.removeAt(index);
                  _saveSegments();
                });
              },
              child: Text('削除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: '商品名',
            border: OutlineInputBorder(),
          ),
          controller: itemNameController,
          onChanged: (value) => _saveData(),
        ),
        SizedBox(height: 16.0),
        TextField(
          decoration: InputDecoration(
            labelText: '名称',
            border: OutlineInputBorder(),
          ),
          controller: itemDescriptionController,
          onChanged: (value) => _saveData(),
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  labelText: '単位の数値',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: unitValueController,
                onChanged: (value) {
                  _saveData(); // データの保存
                },
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '単位',
                  border: OutlineInputBorder(),
                ),
                value: selectedUnitType,
                items: ['g', '個数'].map((String value) {
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
        SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '保存方法',
            border: OutlineInputBorder(),
          ),
          value: selectedStorageMethod,
          items: <String>[
            '常温：高温多湿を避け常温で保存',
            '冷蔵：冷蔵（10℃以下）で保存',
            '冷凍：冷凍（-10℃以下）で保存',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.split('：')[0]),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedStorageMethod = newValue;
              storageInstruction =
                  newValue != null ? newValue.split('：')[1] : '';
            });
            _saveData();
          },
        ),
        SizedBox(height: 16.0),
        if (storageInstruction.isNotEmpty)
          Text(
            '保存方法の説明: $storageInstruction',
            style: TextStyle(color: Colors.black54),
          ),
        SizedBox(height: 16.0),
        TextField(
          decoration: InputDecoration(
            labelText: '売値',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: priceController,
          onChanged: (value) => _saveData(),
        ),
        SizedBox(height: 16.0),
        TextField(
          decoration: InputDecoration(
            labelText: '製造日 (YYYY-MM-DD)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.datetime,
          controller: manufacturingDateController,
          onChanged: (value) {
            try {
              manufacturingDate = DateFormat('yyyy-MM-dd').parse(value);
              _updateExpirationOptions();
              _saveData();
            } catch (e) {
              manufacturingDate = null;
              expirationOptions.clear();
            }
          },
        ),
        SizedBox(height: 16.0),
        if (expirationOptions.isNotEmpty)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
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
            style: TextStyle(color: Colors.black54),
          ),
        SizedBox(height: 16.0),
      ],
    );
  }

  void _updateExpirationOptions() {
    if (manufacturingDate != null) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      DateTime expirationDate = manufacturingDate!.add(Duration(days: 5));
      DateTime consumptionDate = manufacturingDate!.add(Duration(days: 4));
      setState(() {
        expirationOptions = [
          '賞味期限：${dateFormat.format(expirationDate)}',
          '消費期限：${dateFormat.format(consumptionDate)}'
        ];
      });
    } else {
      setState(() {
        expirationOptions.clear();
      });
    }
  }
}
