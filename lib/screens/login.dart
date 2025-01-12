import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/appstate.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<int?> getUserIdByEmail(String email, String password) async {
    try {
      final db = await DatabaseService().database;

      // Query the database for the user by email
      final result = await db.query(
        'users',
        columns: ['user_id', 'password'],
        where: 'email = ?',
        whereArgs: [email],
      );

      // Debug: Log query result
      print('Query result for email $email: $result');

      if (result.isNotEmpty) {
        final String storedPassword = result.first['password'] as String;

        // Debug: Log entered and stored passwords
        print('Stored password: $storedPassword');
        print('Entered password: $password');

        if (storedPassword == password) {
          return result.first['user_id'] as int;
        } else {
          print('Password does not match.');
        }
      } else {
        print('No user found with email: $email');
      }
    } catch (e) {
      print('Error during login verification: $e');
    }

    return null;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo or Title
              Text(
                'Goaldigger',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 40),

              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  final String email = emailController.text.trim();
                  final String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    _showErrorDialog(context, 'Please fill in all fields.');
                    return;
                  }

                  try {
                    final int? userId = await getUserIdByEmail(email, password);

                    if (userId != null) {
                      AppState().globaluserId = userId;
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      _showErrorDialog(context, 'Invalid email or password.');
                    }
                  } catch (e) {
                    print('Error during login: $e');
                    _showErrorDialog(context, 'An unexpected error occurred.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

