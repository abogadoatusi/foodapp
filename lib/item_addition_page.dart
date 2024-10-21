import 'package:flutter/material.dart';
import 'item_detail_page.dart'; // これが正しいパスであることを確認
import 'item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSONのエンコード/デコードのためのパッケージ

class ItemAdditionPage extends StatefulWidget {
  @override
  _ItemAdditionPageState createState() => _ItemAdditionPageState();
}

class _ItemAdditionPageState extends State<ItemAdditionPage> {
  List<Item> items = []; // Itemオブジェクトのリスト

  @override
  void initState() {
    super.initState();
    _loadItems(); // アイテムをロード
  }

  // 販売物のデータをローカルストレージからロードする
  void _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemList = prefs.getStringList('items');
    if (itemList != null) {
      setState(() {
        items = itemList
            .map((itemJson) => Item.fromJson(jsonDecode(itemJson)))
            .toList();
      });
    }
  }

  // 販売物のデータをローカルストレージに保存する
  void _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> itemList =
        items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('items', itemList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('品目追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(items[index].name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditItemDialog(index); // 編集ダイアログを表示
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDeleteItem(index); // 削除の確認ダイアログ
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // 各販売物ボタンを押すと詳細ページに遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(
                                item: items[index]), // クラスとして正しく使用
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddItemDialog();
              },
              child: Text('販売物追加'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新しい販売物を追加'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "販売物の名前を入力"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('追加'),
              onPressed: () {
                setState(() {
                  items.add(Item(name: _textFieldController.text));
                  _saveItems(); // アイテムを保存
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 販売物の名前を編集するダイアログを表示
  void _showEditItemDialog(int index) {
    TextEditingController _textFieldController =
        TextEditingController(text: items[index].name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('販売物の名前を編集'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "販売物の新しい名前を入力"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                setState(() {
                  items[index].name = _textFieldController.text;
                  _saveItems(); // アイテムを保存
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 削除確認ダイアログを表示し、削除を実行
  void _confirmDeleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('削除の確認'),
          content: Text('この販売物を削除してもよろしいですか？'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('削除'),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                  _saveItems(); // アイテムを保存
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
