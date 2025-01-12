import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/appstate.dart';

class LoginScreen extends StatelessWidget {
  // TextEditingController instances to store user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to get the user_id from the database based on the email
  Future<int?> getUserIdByEmail(String email) async {
    final db = await DatabaseService().database; // Use the singleton instance of DatabaseService
    final result = await db.query(
      'users',
      columns: ['user_id', 'password'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      // Check if the entered password matches
      final String storedPassword = result.first['password'] as String;
      if (storedPassword == passwordController.text) {
        return result.first['user_id'] as int?;
      }
    }
    return null; // Return null if no matching email or password is found
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
                'Goldigger',
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

                  // Check the user_id by email and password
                  final int? userId = await getUserIdByEmail(email);

                  if (userId != null) {
                    // Set userId globally in AppState
                    AppState().globaluserId = userId;

                    // Navigate to the profile screen
                    Navigator.pushReplacementNamed(context, '/profile');
                  } else {
                    // Show an error message if the email or password is incorrect
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('Invalid email or password.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
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
