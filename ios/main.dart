
import 'package:flutter/material.dart';

void main() {
  runApp(const TaskBloomApp());
}

const Color forest = Color(0xFF397653);
const Color leaf = Color(0xFF8DBB91);
const Color cream = Color(0xFFF8F5E9);
const Color paleGreen = Color(0xFFE5F0DF);
const Color ink = Color(0xFF283C30);

class GardenTask {
  String title;
    String category;
  String priority;
  bool isDone;
  final DateTime createdAt;
  DateTime? completedAt;

  GardenTask({
    required this.title,
    required this.category,
    required this.priority,
    this.isDone = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TaskBloomApp extends StatelessWidget {
  const TaskBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: forest),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: ink,
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedTab = 0;

  final List<GardenTask> tasks = [];

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(tasks: tasks, refresh: refresh),
      JourneyPage(tasks: tasks),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[selectedTab]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: paleGreen,
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: forest),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: forest),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: forest),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------- HOME PAGE ----------------

class HomePage extends StatefulWidget {
  final List<GardenTask> tasks;
  final VoidCallback refresh;

  const HomePage({
    super.key,
    required this.tasks,
    required this.refresh,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String filter = 'All';
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get completed =>
      widget.tasks.where((task) => task.isDone).length;

  List<GardenTask> get visibleTasks {
    return widget.tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(searchText.toLowerCase());

      final matchesFilter = filter == 'All' ||
          (filter == 'Active' && !task.isDone) ||
          (filter == 'Done' && task.isDone);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> addTask() async {
    final titleController = TextEditingController();
    String category = 'Study';
    String priority = 'Medium';

    final result = await showDialog<GardenTask>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: cream,
              title: const Text('Plant a new task 🌱'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task name',
                        hintText: 'e.g. Learn Flutter',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration:
                          const InputDecoration(labelText: 'Category'),
                      items: ['Study', 'Work', 'Personal', 'Other']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() => category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration:
                          const InputDecoration(labelText: 'Priority'),
                      items: ['Low', 'Medium', 'High']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() => priority = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: forest,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    Navigator.pop(
                      dialogContext,
                      GardenTask(
                        title: title,
                        category: category,
                        priority: priority,
                      ),
                    );
                  },
                  child: const Text('Add task'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();

    if (result != null) {
      setState(() => widget.tasks.add(result));
      widget.refresh();
    }
  }

  void toggleTask(GardenTask task, bool value) {
    setState(() {
      task.isDone = value;
      task.completedAt = value ? DateTime.now() : null;
    });
    widget.refresh();
  }

  void deleteTask(GardenTask task) {
    setState(() => widget.tasks.remove(task));
    widget.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task removed from your garden')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.tasks.length;
    final percentage = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        backgroundColor: forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TaskBloom 🌿',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: forest,
                  ),
                ),
              ),
              const CircleAvatar(
                backgroundColor: paleGreen,
                child: Text('🐱', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$greeting! 🌼',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Small steps make a beautiful garden.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Garden progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDDEDD5), Color(0xFFF0F4DC)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR DAILY GARDEN',
                  style: TextStyle(
                    color: forest,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  total == 0
                      ? '🌱 Ready to plant your first seed?'
                      : percentage == 1
                          ? '🌸 Your garden is blooming!'
                          : '🌿 Keep growing, one task at a time!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 10,
                          backgroundColor: Colors.white,
                          color: forest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(percentage * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: forest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$completed of $total tasks completed today'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: statCard(
                  'Total tasks',
                  '$total',
                  Icons.spa_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: statCard(
                  'Completed',
                  '$completed',
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          const SectionTitle(title: 'Your weekly growth 📊'),
          const SizedBox(height: 12),
          WeeklyBarChart(tasks: widget.tasks),
          const SizedBox(height: 25),

          const SectionTitle(title: 'My tasks 🌱'),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => searchText = value),
            decoration: InputDecoration(
              hintText: 'Search your tasks...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Active', 'Done'].map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: filter == value,
                selectedColor: paleGreen,
                onSelected: (_) => setState(() => filter = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          if (visibleTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('🌷', style: TextStyle(fontSize: 38)),
                  SizedBox(height: 8),
                  Text(
                    'No tasks here yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('Tap “New task” to plant a seed!'),
                ],
              ),
            )
          else
            ...visibleTasks.map((task) => taskCard(task)),
        ],
      ),
    );
  }

  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: forest, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget taskCard(GardenTask task) {
    final priorityColor = task.priority == 'High'
        ? Colors.red.shade700
        : task.priority == 'Low'
            ? forest
            : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isDone,
            activeColor: forest,
            onChanged: (value) {
              toggleTask(task, value ?? false);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${task.category}  •  ${task.priority} priority',
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: () => deleteTask(task),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- WEEKLY BAR CHART ----------------

class WeeklyBarChart extends StatelessWidget {
  final List<GardenTask> tasks;

  const WeeklyBarChart({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    );

    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final counts = List<int>.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));

      return tasks.where((task) {
        final date = task.completedAt;
        return task.isDone &&
            date != null &&
            DateUtils.isSameDay(date, day);
      }).length;
    });

    final maxCount = counts.fold<int>(
      1,
      (previous, count) => count > previous ? count : previous,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Tasks completed this week',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 155,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final count = counts[index];
                final barHeight = 85.0 * count / maxCount;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          color: forest,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: count == 0 ? 5 : barHeight + 5,
                        width: 19,
                        decoration: BoxDecoration(
                          color: count == 0 ? paleGreen : leaf,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[index],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- JOURNEY CALENDAR ----------------

class JourneyPage extends StatefulWidget {
  final List<GardenTask> tasks;

  const JourneyPage({super.key, required this.tasks});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  DateTime displayedMonth = DateTime.now();
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  List<GardenTask> get selectedDayTasks {
    return widget.tasks.where((task) {
      return task.isDone &&
          task.completedAt != null &&
          DateUtils.isSameDay(task.completedAt!, selectedDate);
    }).toList();
  }

  List<GardenTask> get monthCompletedTasks {
    return widget.tasks.where((task) {
      final date = task.completedAt;
      return task.isDone &&
          date != null &&
          date.year == displayedMonth.year &&
          date.month == displayedMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      displayedMonth.year,
      displayedMonth.month,
    );
    final leadingBlanks = firstDay.weekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My Journey 🗓️',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forest,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Every little step helps your garden grow.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        displayedMonth = DateTime(
                          displayedMonth.year,
                          displayedMonth.month - 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${monthName(displayedMonth.month)} ${displayedMonth.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: forest,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        displayedMonth = DateTime(
                          displayedMonth.year,
                          displayedMonth.month + 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 3,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - leadingBlanks + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(
                    displayedMonth.year,
                    displayedMonth.month,
                    dayNumber,
                  );

                  final isSelected = DateUtils.isSameDay(
                    date,
                    selectedDate,
                  );

                  final isToday = DateUtils.isSameDay(
                    date,
                    DateTime.now(),
                  );

                  final hasCompletedTask = widget.tasks.any((task) {
                    return task.isDone &&
                        task.completedAt != null &&
                        DateUtils.isSameDay(task.completedAt!, date);
                  });

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => selectedDate = date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? forest
                            : isToday
                                ? paleGreen
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: leaf)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasCompletedTask ? '🌼' : '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌼'),
                  SizedBox(width: 6),
                  Text(
                    'Completed task day',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          '${selectedDate.day} ${monthName(selectedDate.month)} tasks',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forest,
          ),
        ),
        const SizedBox(height: 10),

        if (selectedDayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: paleGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              '🌱 No completed tasks on this date yet.',
              textAlign: TextAlign.center,
            ),
          )
        else
          ...selectedDayTasks.map(
            (task) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: paleGreen,
                child: Icon(Icons.check, color: forest),
              ),
              title: Text(task.title),
              subtitle: Text('${task.category} • ${task.priority} priority'),
            ),
          ),

        const SizedBox(height: 22),
        const SectionTitle(title: 'Monthly growth 🌷'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: paleGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🌻', style: TextStyle(fontSize: 38)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${monthCompletedTasks.length} tasks completed',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: forest,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('Keep growing every day!'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- PROFILE PAGE ----------------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'My Profile 🌿',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forest,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: paleGreen,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Text('🐱', style: TextStyle(fontSize: 54)),
              ),
              SizedBox(height: 15),
              Text(
                'Garden Explorer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: forest,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Growing better habits, one task at a time.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const SectionTitle(title: 'About TaskBloom 🌱'),
        const SizedBox(height: 12),
        const ProfileInfoTile(
          icon: Icons.spa_outlined,
          title: 'Plant your tasks',
          subtitle: 'Add small goals to your daily garden.',
        ),
        const ProfileInfoTile(
          icon: Icons.bar_chart,
          title: 'Track your growth',
          subtitle: 'See your weekly task completion chart.',
        ),
        const ProfileInfoTile(
          icon: Icons.calendar_month_outlined,
          title: 'Remember your journey',
          subtitle: 'Explore completed tasks in your calendar.',
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Made with 🌱 for a better day',
            style: TextStyle(color: forest),
          ),
        ),
      ],
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: forest, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: ink,
      ),
    );
  }
}

String monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return names[month - 1];
}
