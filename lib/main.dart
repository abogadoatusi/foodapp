import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Providerパッケージをインポート
import 'sign_up_page.dart';
import 'password_reset_page.dart';
import 'manufacturer_registration_page.dart';
import 'app_state.dart'; // AppStateをインポート

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context); // AppStateを取得

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  appState.updateEmail(value); // emailを更新
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  appState.updatePassword(value); // passwordを更新
                },
              ),
              SizedBox(height: 24.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text(
                  'アカウントを作成',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  print('Login button pressed');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManufacturerRegistrationPage()),
                  );
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  print('Google login button pressed');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManufacturerRegistrationPage()),
                  );
                },
                child: Text('google'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
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
