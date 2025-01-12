import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ShopScreen extends StatefulWidget {
  final int userId; // ID του χρήστη

  const ShopScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Map<String, dynamic>> items = [];
  int userGold = 0; // Χρυσός χρήστη
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Φόρτωση δεδομένων
  }

  Future<void> _fetchData() async {
    try {
      final db = await DatabaseService().database;

      // Ανάκτηση όλων των αντικειμένων προς αγορά
      final itemResults = await db.query('items');

      // Ανάκτηση του χρυσού του χρήστη
      final userResult = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [widget.userId],
      );

      setState(() {
        items = itemResults;
        userGold = userResult.isNotEmpty ? userResult.first['gold'] as int : 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching shop data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _buyItem(int itemId, int price) async {
    try {
      final db = await DatabaseService().database;

      if (userGold >= price) {
        // Εισαγωγή στο useritems
        await db.insert('useritems', {
          'user_id': widget.userId,
          'item_id': itemId,
          'is_equipped': 0,
        });

        // Ενημέρωση του χρυσού
        await db.update(
          'users',
          {'gold': userGold - price},
          where: 'user_id = ?',
          whereArgs: [widget.userId],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item bought successfully!')),
        );

        _fetchData(); // Ενημέρωση δεδομένων
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough gold!')),
        );
      }
    } catch (e) {
      print('Error buying item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to buy item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.amber,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Gold = ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      '$userGold',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.attach_money, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 3,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Image.asset(
                          'assets/images/${item['name'].toLowerCase().replaceAll(" ", "_")}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${item['price']} Gold',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _buyItem(
                            item['item_id'] as int, item['price'] as int),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // shop is selected
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/searchscreen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
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
}