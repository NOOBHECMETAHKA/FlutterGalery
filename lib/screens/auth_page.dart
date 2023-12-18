import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galary/config/routes.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleRegister(BuildContext context) async {
    // Сохраняем данные в SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', usernameController.text);
    prefs.setString('password', passwordController.text);
  }

  void _handleLogin(BuildContext context) async {
    // Получаем данные из SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUsername = prefs.getString('username') ?? '';
    String savedPassword = prefs.getString('password') ?? '';

    // Проверяем введенные данные
    if (usernameController.text == savedUsername &&
        passwordController.text == savedPassword) {
      // Если данные верны, переходим на следующий экран
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, homeRoute);
    } else {
      // Выводим сообщение об ошибке
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Неверный логин или пароль'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(icon: Icon(Icons.security), labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration:const InputDecoration(icon: Icon(Icons.lock), labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _handleLogin(context);
              },
              label: const Text('Авторизоваться'),
              icon: const Icon(Icons.login),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                _handleRegister(context);
              },
              label: const Text('Регистрация'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
