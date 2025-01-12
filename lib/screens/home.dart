import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/categoryfilter.dart'; // Import the filter widget
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'taskuncom.dart'; // Import για τη σελίδα Task Details
import 'goalpage.dart'; // Import για τη σελίδα Goal Details


class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  int totalGoldPoints = 0;
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> goals = [];
  List<Map<String, dynamic>> progress = [];
  String selectedTaskCategory = 'All'; // Default selected category
  String selectedGoalCategory = 'All'; // Default selected category
  String selectedProgressCategory = 'All'; // Default progress category
  List<Map<String, dynamic>> progressData = [
  {'x': 1, 'y': 20}, // Week 1: 20%
  {'x': 2, 'y': 50}, // Week 2: 50%
  {'x': 3, 'y': 70}, // Week 3: 70%
  {'x': 4, 'y': 100}, // Week 4: 100%
];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
    _loadGoals();
     _loadProgress();
  }

  //navigating function
  void _navigateToDetail(Map<String, dynamic> item) async {
    if (item['type'] == 'Task') {
      final db = await DatabaseService().database;
      final result = await db.query(
        'usertasks',
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, item['id']],
      );

      if (result.isNotEmpty && result.first['is_completed'] == 0) {
        // Navigate to TaskDetailsScreen if the task is NOT completed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(
              userId: widget.userId,
              taskId: item['id'],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(
              userId: widget.userId,
              taskId: item['id'],
            ),
          ),
        );
      }
    } else if (item['type'] == 'Goal') {
      // Navigate to GoalDetailsScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalDetailsScreen(
            userId: widget.userId,
            goalId: item['id'],
          ),
        ),
      );
    }
  }
//loading functions
  Future<void> _loadUserData() async {
    try {
      final db = await DatabaseService().database;

      // Fetch user details
      final userResult = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [widget.userId],
      );

      if (userResult.isNotEmpty) {
        setState(() {
          username = userResult[0]['username'] as String;
          totalGoldPoints = userResult[0]['gold'] as int;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTasks() async {
    try {
      final db = await DatabaseService().database;

      // Fetch tasks using a join query

      final taskResult = await db.rawQuery('''
        SELECT tasks.*, usertasks.is_completed
        FROM usertasks
        JOIN tasks ON usertasks.task_id = tasks.task_id
        WHERE usertasks.user_id = ?;
      ''', [widget.userId]);

      setState(() {
        tasks = taskResult; // Assign the result to the tasks list
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

    Future<void> _loadGoals() async {
    try {
      final db = await DatabaseService().database;

      // Fetch goals using a join query

      final goalsResult = await db.rawQuery('''
        SELECT goals.*, usergoals.is_completed,usergoals.progress
        FROM usergoals
        JOIN goals ON usergoals.goal_id = goals.goal_id
        WHERE usergoals.user_id = ?;
      ''', [widget.userId]);

      setState(() {
        goals = goalsResult; // Assign the result to the goals list
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

Future<void> _loadProgress() async {
  try {
    final db = await DatabaseService().database;

    // Fetch completed_at timestamps for completed tasks
    final progressResult = await db.rawQuery('''
      SELECT usertasks.completed_at
      FROM usertasks
      WHERE usertasks.user_id = ? AND usertasks.is_completed = 1;
    ''', [widget.userId]);

    // Convert the raw data into a list of timestamps
    List<String> timestamps = progressResult.map((row) => row['completed_at'] as String).toList();
    /*
    // Group data by week
    final weeklyData = processProgressData(progressResult);

    setState(() {
      progress = weeklyData; // Store the graphable data
      print(progress);
    });
    */
    setState(() {
      progress = progressResult; // Store the graphable data
    });
  } catch (e) {
    print('Error loading progress: $e');
  }
}
// ----- FILTERS
  // Getter for dynamically filtering tasks
  List<Map<String, dynamic>> get filteredTasks {
    if (selectedTaskCategory == 'All') {
      return tasks; // Show all tasks
    }
    return tasks.where((task) => task['category'] == selectedTaskCategory).toList();
  }
  //Similar map for goals
  List<Map<String, dynamic>> get filteredGoals {
    if (selectedGoalCategory == 'All') {
      return goals; // Show all tasks
    }
    return goals.where((goal) => goal['category'] == selectedGoalCategory).toList();
  }
  // Filter for data (wish it works)
List<Map<String, dynamic>> get filterProgressData {
  final now = DateTime.now();

  if (selectedProgressCategory == 'Month') {
    // Filter for the last 4 weeks
    //print(now);
    final fourWeeksAgo = now.subtract(Duration(days: 28));
    //print(fourWeeksAgo);
    //print("just before processing-getter");
    return processProgressData(progress.where((entry) {
      final dateStr = entry['completed_at'];
      if (dateStr == null) return false; // Skip null dates
      final date = DateTime.tryParse(dateStr);
      bool check = date != null && date.isAfter(fourWeeksAgo) && date.isBefore(now);
      //print("$dateStr, $check");
      return date != null && date.isAfter(fourWeeksAgo) && date.isBefore(now);
    }).toList());
  } else if (selectedProgressCategory == 'Year') {
    // Filter for the last 52 weeks
    final oneYearAgo = now.subtract(Duration(days: 365));
    //print(oneYearAgo);
    return processProgressData(progress.where((entry) {
      final dateStr = entry['completed_at'];
      if (dateStr == null) return false; // Skip null dates
      final date = DateTime.tryParse(dateStr);
      return date != null && date.isAfter(oneYearAgo) && date.isBefore(now);
    }).toList());
  } else {
    // Show all progress data
    //print("just before processing-getter");
    return processProgressData(progress);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          '@$username',
          style: const TextStyle(color: Colors.amber, fontSize: 25),
        ),
        centerTitle: true,
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 40, // Adjust vertical placement
              right: 265, // Adjust horizontal placement
              child: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.amber, size: 50),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile'); // Navigate to profile page
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Tasks Section
              _buildTaskListWithExpansion(),

              // My Goals Section
              _buildGoalListWithExpansion(),

              // My Progress Section
              _buildProgressWithExpansion(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Search tab is selected
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

//generic build functions for building tasks and goals parts of the app
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTaskList() {
    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text('No tasks available.', style: TextStyle(color: Colors.white)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return GestureDetector(
          onTap: () {
            // Handle task tap here
            // Navigate to TaskDetailsScreen
            _navigateToDetail({
              'type': 'Task',
              'id': task['task_id'],
            });
            print('Task tapped: ${task['title']}');
            // You can navigate to another screen or show a dialog, etc.
          },
          child: ListTile(
            leading: Checkbox(
              value: task['is_completed'] == 1,
              onChanged: (bool? value) {
                setState(() {
                  task['is_completed'] = value == true ? 1 : 0;
                });
              },
              activeColor: Colors.amber,
            ),
            title: Text(
              task['title'],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${task['gold_reward']}', style: const TextStyle(color: Colors.amber)),
                const Icon(Icons.star, color: Colors.amber),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildGoalList() {
    if (filteredGoals.isEmpty) {
      return const Center(
        child: Text('No tasks available.', style: TextStyle(color: Colors.white)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = filteredGoals[index];
        return GestureDetector(
          onTap: () {
            // Handle goal tap here
            _navigateToDetail({
              'type': 'Goal',
              'id': goal['goal_id'],
            });
            print('Goal tapped: ${goal['title']}');
            // You can navigate to another screen or show a dialog, etc.
          },
          child: ListTile(
            leading: Checkbox(
              value: goal['is_completed'] == 1,
              onChanged: (bool? value) {
                setState(() {
                  goal['is_completed'] = value == true ? 1 : 0;
                });
              },
              activeColor: Colors.amber,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['title'],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: goal['progress']/goal['target'], // Bind progress value
                  backgroundColor: Colors.grey[800], // Bar background color
                  color: Colors.amber, // Bar progress color
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${goal['reward']}', style: const TextStyle(color: Colors.amber)),
                const Icon(Icons.star, color: Colors.amber),
              ],
            ),
          ),
        );
      },
    );
  }


// ------ Progress graph hell
Widget _buildProgressGraph() {
  // Filter progress data based on the selectedProgressCategory
  //List<Map<String, dynamic>> filteredProgress = _filterProgressData();

  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Over Time',
          style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 40,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          'Week ${value.toInt()}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.white),
                  bottom: BorderSide(color: Colors.white),
                ),
              ),
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  isCurved: false,
                  spots: filterProgressData
                      .map((point) => FlSpot(point['week'].toDouble(), point['count'].toDouble()))
                      .toList(),
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

List<Map<String, dynamic>> processProgressData(List<Map<String, dynamic>> progress) {
  // Parse the timestamps and count tasks per week
  //print("just started processing-processor");
  Map<int, int> weeklyCounts = {};
  if (progress.isEmpty) {
  return []; // Return an empty list if there's no data to process
}
  DateTime earliest= DateTime.parse(progress[0]['completed_at']);
  for (var entry in progress){
    if (entry['completed_at'] != null) {
      DateTime date = DateTime.parse(entry['completed_at']);
      if(date.isBefore(earliest)){ earliest=date;}
    }
  }
  for (var entry in progress) {
    if (entry['completed_at'] != null) {
      // Convert completed_at to DateTime
      DateTime date = DateTime.parse(entry['completed_at']);
      int week = _getContinuousWeekNumber(date,earliest);

      // Increment the count for this week
      if (weeklyCounts.containsKey(week)) {
        weeklyCounts[week] = weeklyCounts[week]! + 1;
      } else {
        weeklyCounts[week] = 1;
      }
    }
  }

  // Convert the map into a list of graphable data points
List<Map<String, dynamic>> graphData = [];
weeklyCounts.forEach((week, count) {
  graphData.add({'week': week, 'count': count ?? 0}); // Use 0 if count is null
});
graphData.sort((a, b) => a['week'].compareTo(b['week']));

//print(graphData);
  return graphData;
}

// Helper function to get the ISO week number
int _getContinuousWeekNumber(DateTime date, DateTime earliestDate) {
  // Calculate the number of days between the current date and the earliest date
  final daysSinceStart = date.difference(earliestDate).inDays;

  // Convert days to weeks and add 1 to make it 1-based
  return (daysSinceStart / 7).floor() + 1;
}


//-------------final build functions that enter the main program
  Widget _buildTaskListWithExpansion() {
    return ExpansionTile(
      title: const Text(
        'My Tasks',
        style: TextStyle(color: Colors.amber, fontSize: 18),
      ),
      initiallyExpanded: true, // Start expanded
      children: [
        FilterWidget(
          categories: ['Traveling', 'Productivity', 'Social Life', 'All'],
          onCategorySelected: (category) {
            setState(() {
              selectedTaskCategory = category;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildTaskList(), // Reuse the _buildTaskList function
      ],
    );
  }

    Widget _buildGoalListWithExpansion() {
    return ExpansionTile(
      title: const Text(
        'My Goals',
        style: TextStyle(color: Colors.amber, fontSize: 18),
      ),
      initiallyExpanded: true, // Start expanded
      children: [
        FilterWidget(
          categories: ['Traveling', 'Productivity', 'Social Life', 'All'],
          onCategorySelected: (category) {
            setState(() {
              selectedGoalCategory = category;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildGoalList(), // Reuse the _buildTaskList function
      ],
    );
  }


Widget _buildProgressWithExpansion() {
  return ExpansionTile(
    title: const Text(
      'My Progress',
      style: TextStyle(color: Colors.amber, fontSize: 18),
    ),
    initiallyExpanded: true, // Start expanded
    children: [
      FilterWidget(
        categories: ['Month', 'Year', 'All'], // Filtering options
        onCategorySelected: (category) {
          setState(() {
            selectedProgressCategory = category; // Update the selected filter
            print(filterProgressData);
          });
        },
      ),
      const SizedBox(height: 10),
      _buildProgressGraph(), // Dynamically build the graph based on the filter
    ],
  );
}


}