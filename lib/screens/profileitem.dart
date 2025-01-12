import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedAccessoryUrl;
String? selectedStyleUrl;

  String username = '';
  int totalPoints = 0;
  List<String> libraryPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  try {
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
      orderBy: 'uploaded_at DESC',
    );

    setState(() {
      libraryPhotos = photosResult.map((photo) => photo['url'] as String).toList();
    });

    // Fetch selected accessory
    final accessoryResult = await db.rawQuery('''
      SELECT photos.url
      FROM useritems
      INNER JOIN items ON useritems.item_id = items.item_id
      INNER JOIN photos ON items.photo_id = photos.photo_id
      WHERE useritems.user_id = ? AND useritems.is_equipped = 1 AND items.type = 1
    ''', [widget.userId]);

    // Fetch selected style
    final styleResult = await db.rawQuery('''
      SELECT photos.url
      FROM useritems
      INNER JOIN items ON useritems.item_id = items.item_id
      INNER JOIN photos ON items.photo_id = photos.photo_id
      WHERE useritems.user_id = ? AND useritems.is_equipped = 1 AND items.type = 0
    ''', [widget.userId]);

    // Ενημέρωση των τιμών με default εικόνες αν δεν υπάρχουν αποτελέσματα
    setState(() {
      selectedAccessoryUrl = accessoryResult.isNotEmpty
          ? accessoryResult.first['url'] as String
          : 'assets/images/defaultac.png';

      selectedStyleUrl = styleResult.isNotEmpty
          ? styleResult.first['url'] as String
          : 'assets/images/defaultstyle.png';
    });
  } catch (e) {
    print('Error loading user data: $e');
  }
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
              Stack(
  alignment: Alignment.center,
  children: [
    // Background style (αν υπάρχει επιλεγμένο)
    if (selectedStyleUrl != null)
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(selectedStyleUrl!),
            fit: BoxFit.cover,
          ),
        ),
      ),
    // Προφίλ χρήστη (avatar)
    CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[700],
      child: Icon(Icons.person, size: 40, color: Colors.white),
    ),
    // Accessory (αν υπάρχει επιλεγμένο)
    if (selectedAccessoryUrl != null)
      Positioned(
        bottom: -10,
        child: Image.asset(
          selectedAccessoryUrl!,
          width: 40,
          height: 40,
        ),
      ),
  ],
),

                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username (User ID: ${widget.userId})',
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
              child: libraryPhotos.isEmpty
                  ? Center(
                      child: Text(
                        'No photos available.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: libraryPhotos.length,
                      itemBuilder: (context, index) {
                        return _buildImage(libraryPhotos[index]);
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
              _navigateTo('/searchscreen');
              break;
            case 1:
              _navigateTo('/home');
              break;
            case 2:
              _navigateTo('/shop');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets')) {
      // Load from assets
      return Image.asset(url, fit: BoxFit.cover);
    } else {
      // Assume the file is stored locally (internal/external)
      final file = File(url);
      return file.existsSync()
          ? Image.file(file, fit: BoxFit.cover)
          : Icon(Icons.broken_image, color: Colors.grey); // Handle missing file
    }
  }
}
