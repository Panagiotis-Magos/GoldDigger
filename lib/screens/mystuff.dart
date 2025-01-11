import 'package:flutter/material.dart';
import '../services/database_service.dart';

class MyStuffScreen extends StatefulWidget {
  final int userId; // ID του χρήστη

  const MyStuffScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyStuffScreenState createState() => _MyStuffScreenState();
}

class _MyStuffScreenState extends State<MyStuffScreen> {
  List<Map<String, dynamic>> accessories = [];
  List<Map<String, dynamic>> styles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Φόρτωση δεδομένων από τη βάση
  }

  Future<void> _fetchData() async {
    try {
      final db = await DatabaseService().database;

      // Ανάκτηση των αξεσουάρ του χρήστη
      final accessoryResults = await db.rawQuery('''
        SELECT i.item_id, i.name, i.description, i.type, i.price, ui.is_equipped
        FROM items i
        INNER JOIN useritems ui ON i.item_id = ui.item_id
        WHERE ui.user_id = ?
      ''', [widget.userId]);

      // Διαχωρισμός σε Accessories και Styles (με βάση τον τύπο)
      final List<Map<String, dynamic>> accessoriesList = [];
      final List<Map<String, dynamic>> stylesList = [];

      for (var item in accessoryResults) {
        if (item['type'] == 'accessory') {
          accessoriesList.add(item);
        } else if (item['type'] == 'style') {
          stylesList.add(item);
        }
      }

      setState(() {
        accessories = accessoriesList;
        styles = stylesList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user items: $e');
      setState(() {
        isLoading = false;
      });
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
        title: const Text('My Stuff'),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('Accessories', accessories),
          const SizedBox(height: 20),
          _buildSection('Styles', styles),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: items.map((item) {
        return ListTile(
          title: Text(item['name']),
          subtitle: Text(item['description'] ?? ''),
          trailing: Checkbox(
            value: item['is_equipped'] == 1,
            onChanged: (value) async {
              final db = await DatabaseService().database;

              // Ενημέρωση στη βάση για την επιλογή/απενεργοποίηση
              await db.update(
                'useritems',
                {'is_equipped': value! ? 1 : 0},
                where: 'user_id = ? AND item_id = ?',
                whereArgs: [widget.userId, item['item_id']],
              );

              _fetchData(); // Ανανεώνει τα δεδομένα μετά την αλλαγή
            },
          ),
        );
      }).toList(),
    );
  }
}