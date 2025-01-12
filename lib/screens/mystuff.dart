import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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

      // Ανάκτηση των Accessories του χρήστη
      final accessoryResults = await db.rawQuery('''
        SELECT i.item_id, i.name, i.description, i.type, ui.is_equipped
        FROM items i
        INNER JOIN useritems ui ON i.item_id = ui.item_id
        WHERE ui.user_id = ? AND i.type = 1
      ''', [widget.userId]);

      // Ανάκτηση όλων των Styles
      final styleResults = await db.rawQuery('''
        SELECT i.item_id, i.name, i.description, i.type,
          COALESCE(ui.is_equipped, 0) as is_equipped
        FROM items i
        LEFT JOIN useritems ui ON i.item_id = ui.item_id AND ui.user_id = ?
        WHERE i.type = 0
      ''', [widget.userId]);

      setState(() {
        accessories = accessoryResults;
        styles = styleResults;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _equipItem(int itemId, String category) async {
    try {
      final db = await DatabaseService().database;

      // Βεβαιωνόμαστε ότι υπάρχει εγγραφή για το item στον πίνακα useritems
      await db.insert(
        'useritems',
        {
          'user_id': widget.userId,
          'item_id': itemId,
          'is_equipped': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Αγνοεί αν υπάρχει ήδη
      );

      // Απενεργοποίηση όλων των αντικειμένων της κατηγορίας
      await db.update(
        'useritems',
        {'is_equipped': 0},
        where: 'user_id = ? AND item_id IN (SELECT item_id FROM items WHERE type = ?)',
        whereArgs: [widget.userId, category == 'Accessories' ? 1 : 0],
      );

      // Ενεργοποίηση του επιλεγμένου αντικειμένου
      await db.update(
        'useritems',
        {'is_equipped': 1},
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [widget.userId, itemId],
      );

      // Ανανέωση της λίστας
      _fetchData();
    } catch (e) {
      print('Error equipping item: $e');
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
          trailing: Radio<bool>(
            value: true,
            groupValue: item['is_equipped'] == 1,
            onChanged: (value) {
              if (value == true) {
                _equipItem(item['item_id'] as int, title); // Ενεργοποίηση του αντικειμένου
              }
            },
          ),
        );
      }).toList(),
    );
  }
}


