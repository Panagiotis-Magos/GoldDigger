import 'package:flutter/material.dart';
import '../services/database_service.dart';

class SearchScreen extends StatefulWidget {
  final int userId;

  const SearchScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String _filter = 'All'; // Default filter
  List<String> filters = ['All', 'Tasks', 'Goals'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final db = await DatabaseService().database;

      // Prepare SQL queries based on the filter
      String sql;
      List<String> args = ['%$query%'];

      if (_filter == 'Tasks') {
        sql = "SELECT * FROM tasks WHERE title LIKE ?";
      } else if (_filter == 'Goals') {
        sql = "SELECT * FROM goals WHERE title LIKE ?";
      } else {
        sql = """
          SELECT 'Task' AS type, task_id AS id, title, category
          FROM tasks WHERE title LIKE ?
          UNION ALL
          SELECT 'Goal' AS type, goal_id AS id, title, category
          FROM goals WHERE title LIKE ?
        """;
        args = ['%$query%', '%$query%'];
      }

      final results = await db.rawQuery(sql, args);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error performing search: $e');
    }
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    if (item['type'] == 'Task') {
      Navigator.pushNamed(context, '/taskdetail', arguments: {'taskId': item['id']});
    } else if (item['type'] == 'Goal') {
      Navigator.pushNamed(context, '/goaldetail', arguments: {'goalId': item['id']});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _performSearch(), // Trigger search on Enter
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[300]),
                filled: true,
                fillColor: Colors.grey[850], // Darker color for better visibility
                hintStyle: const TextStyle(color: Colors.grey), // Lighter hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white), // White text for better contrast
            ),
          ),

          // Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: filters.map((filter) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _filter = filter;
                    _performSearch();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _filter == filter ? Colors.amber : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _filter == filter ? Colors.black : Colors.grey[800],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Search Results
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(item),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Icon(
                        item['type'] == 'Task' ? Icons.check_box : Icons.flag,
                        color: Colors.amber,
                      ),
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['category']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Search tab is selected
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/shop');
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
