import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  int totalPoints = 0;
  List<String> libraryPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = await DatabaseService().database;

    // Fetch user data
    final userResult = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [widget.userId],
    );

    if (userResult.isNotEmpty) {
      setState(() {
        username = userResult[0]['username'] as String;
        totalPoints = userResult[0]['gold'] as int;
      });
    }

    // Fetch user's photos
    final photosResult = await db.query(
      'photos',
      where: 'user_id = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      libraryPhotos = photosResult.map((photo) => photo['url'] as String).toList();
    });
  }

  void _navigateTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF333333), // Dark gray background
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[700],
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Total points: $totalPoints',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editprofile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Library Section
            const Text(
              'Library',
              style: TextStyle(
                fontSize: 18,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: libraryPhotos.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    libraryPhotos[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab is selected
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              _navigateTo('/search');
              break;
            case 1:
              _navigateTo('/home');
              break;
            case 2:
              break;
            case 3:
              _navigateTo('/shop');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
        ],
      ),
    );
  }
}