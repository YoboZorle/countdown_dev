import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TaskPriority _selectedPriority = TaskPriority.medium;
  Color _selectedColor = Colors.blue;
  final List<String> _selectedTags = [];
  final List<String> _selectedAssignees = [];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final List<String> _availableTags = [
    'development',
    'design',
    'bug',
    'feature',
    'documentation',
    'testing',
    'meeting',
    'urgent',
  ];

  final List<String> _availableAssignees = [
    'John',
    'Sarah',
    'Mike',
    'Emma',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 50.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                onTap: _selectDate,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag),
                        const SizedBox(width: 8),
                        Text(
                          'Priority',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<TaskPriority>(
                      segments: const [
                        ButtonSegment(
                          value: TaskPriority.low,
                          label: Text('Low'),
                          icon: Icon(Icons.arrow_downward, size: 16),
                        ),
                        ButtonSegment(
                          value: TaskPriority.medium,
                          label: Text('Medium'),
                          icon: Icon(Icons.remove, size: 16),
                        ),
                        ButtonSegment(
                          value: TaskPriority.high,
                          label: Text('High'),
                          icon: Icon(Icons.arrow_upward, size: 16),
                        ),
                      ],
                      selected: {_selectedPriority},
                      onSelectionChanged: (Set<TaskPriority> newSelection) {
                        setState(() {
                          _selectedPriority = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette),
                        const SizedBox(width: 8),
                        Text(
                          'Color',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                width: 3,
                              )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.label),
                        const SizedBox(width: 8),
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(width: 8),
                        Text(
                          'Assign To',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _availableAssignees.map((person) {
                        final isSelected = _selectedAssignees.contains(person);
                        return FilterChip(
                          avatar: CircleAvatar(
                            child: Text(person[0]),
                          ),
                          label: Text(person),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAssignees.add(person);
                              } else {
                                _selectedAssignees.remove(person);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        color: _selectedColor,
        tags: _selectedTags,
        assignedTo: _selectedAssignees,
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(task);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}