// lib/password_reset_page.dart

import 'package:flutter/material.dart';

class PasswordResetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('パスワードリセット'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // パスワードリセットページへのナビゲーション
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordResetPage()),
                  );
                },
                child: Text('パスワードをリセット'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.red[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
