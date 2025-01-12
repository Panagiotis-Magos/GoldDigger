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

      // Ανάκτηση μόνο των items με type = 1 (accessories)
      final itemResults = await db.rawQuery('''
        SELECT 
          items.*,
          photos.url AS image_url,
          CASE 
            WHEN useritems.item_id IS NOT NULL THEN 1 
            ELSE 0 
          END AS isPurchased
        FROM items
        LEFT JOIN photos ON items.photo_id = photos.photo_id
        LEFT JOIN useritems ON items.item_id = useritems.item_id AND useritems.user_id = ?
        WHERE items.type = 1
      ''', [widget.userId]);

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
                    const SizedBox(width: 8), // Μικρό κενό ανάμεσα στο κείμενο και την εικόνα
                    Image.asset(
                      'assets/images/gold_bar.png', // Διαδρομή της εικόνας
                      width: 24, // Πλάτος εικόνας
                      height: 24, // Ύψος εικόνας
                    ),
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
                final imagePath = item['image_url'] ?? 'assets/images/default.png';
                final isPurchased = (item['isPurchased'] as int) == 1;

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
                          imagePath,
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${item['price']}',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 5), // Κενό ανάμεσα στον αριθμό και την εικόνα
      Image.asset(
        'assets/images/gold_bar.png', // Διαδρομή της εικόνας
        width: 16, // Πλάτος εικόνας
        height: 16, // Ύψος εικόνας
      ),
    ],
  ),
),

                      ElevatedButton(
                        onPressed: isPurchased
                            ? null
                            : () => _buyItem(item['item_id'] as int, item['price'] as int),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPurchased ? Colors.grey : Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isPurchased ? 'Purchased' : 'Buy',
                          style: TextStyle(
                            color: isPurchased ? Colors.white70 : Colors.black,
                          ),
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
