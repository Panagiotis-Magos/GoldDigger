import 'package:flutter/material.dart';
import '../services/database_service.dart';

class GoalPage extends StatefulWidget {
  final int goalId; // Το ID του goal

  const GoalPage({required this.goalId, Key? key}) : super(key: key);

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  Map<String, dynamic>? goalData; // Δεδομένα του goal
  bool isLoading = true; // Φόρτωση δεδομένων

  @override
  void initState() {
    super.initState();
    _fetchGoalData(); // Φόρτωση δεδομένων από τη βάση
  }

  Future<void> _fetchGoalData() async {
    try {
      final db = await DatabaseService().database;
      final result = await db.query(
        'goals', // Όνομα του πίνακα
        where: 'id = ?', // Αναζήτηση με βάση το ID
        whereArgs: [widget.goalId],
      );

      if (result.isNotEmpty) {
        setState(() {
          goalData = result.first; // Πρώτο αποτέλεσμα
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // Κανένα αποτέλεσμα
        });
      }
    } catch (e) {
      print('Error fetching goal data: $e');
      setState(() {
        isLoading = false; // Σφάλμα στη φόρτωση
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Goal'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (goalData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Goal'),
        ),
        body: const Center(child: Text('Goal not found!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(goalData!['name'] ?? 'Goal'),
      ),
      body: Container(
        color: const Color(0xFF333333),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Όνομα του Goal
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.amber,
              child: Text(
                goalData!['name'] ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Κατηγορία του Goal
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.amber[600],
              child: Row(
                children: [
                  const Icon(Icons.category, color: Colors.black),
                  const SizedBox(width: 8.0),
                  Text(
                    goalData!['category'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Περιγραφή
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[800],
              child: Text(
                goalData!['description'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Στατιστικά
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: (goalData!['status'] ?? 0).toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: null, // Το status είναι μόνο για ανάγνωση
                    activeColor: Colors.amber,
                  ),
                ),
                Text(
                  "${goalData!['status'] ?? 0}%",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Πόντοι
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.amber[600],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gold:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${goalData!['gold'] ?? 0}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.attach_money, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Επιλεγμένο το Goal Tab
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/shop');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/mystuff');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Stuff'),
        ],
      ),
    );
  }
}

