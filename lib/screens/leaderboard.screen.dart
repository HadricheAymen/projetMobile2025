import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quiz_result.dart';
import '../widgets/settings_icon_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<QuizResult> allResults = [];
  List<QuizResult> filteredResults = [];
  List<dynamic> categories = [];
  List<String> difficulties = ['All', 'easy', 'medium', 'hard'];
  List<int> questionCounts = [0, 5, 10, 15];

  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  int selectedQuestionCount = 0; // 0 means "All"
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    await _fetchCategories();
    await _loadResults();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://opentdb.com/api_category.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = [
            {'id': 0, 'name': 'All'},
            ...data['trivia_categories'],
          ];
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('quiz_results') ?? [];

    final loadedResults =
        results
            .map((result) => QuizResult.fromJson(json.decode(result)))
            .toList();

    setState(() {
      allResults = loadedResults;
      filteredResults = loadedResults;
    });

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredResults =
          allResults.where((result) {
            // Apply category filter
            if (selectedCategory != 'All') {
              final category = categories.firstWhere(
                (cat) => cat['name'] == selectedCategory,
                orElse: () => {'id': 0, 'name': 'All'},
              );
              final categoryId = category['id'].toString();
              if (category['name'] != 'All' && result.category != categoryId) {
                return false;
              }
            }
            // Apply difficulty filter
            if (selectedDifficulty != 'All' &&
                result.difficulty != selectedDifficulty) {
              return false;
            }
            // Apply question count filter
            if (selectedQuestionCount != 0 &&
                result.totalQuestions != selectedQuestionCount) {
              return false;
            }
            return true;
          }).toList();

      // Sort by score (highest first)
      filteredResults.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  Future<void> _clearAllResults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Results'),
            content: const Text(
              'Are you sure you want to delete all quiz results? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_results');

    setState(() {
      allResults = [];
      filteredResults = [];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All quiz results have been cleared')),
      );
    }
  }

  String getCategoryName(String categoryValue) {
    try {
      final id = int.tryParse(categoryValue);
      if (id != null) {
        final category = categories.firstWhere(
          (cat) => cat['id'] == id,
          orElse: () => {'name': categoryValue},
        );
        return category['name'];
      } else {
        return categoryValue;
      }
    } catch (e) {
      return categoryValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.035,
          ),
        ),
        actions: const [SettingsIconButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 24),
            child: Column(
              children: [
                // Filters
                _buildFilters(colorScheme, size, isSmallScreen),
                SizedBox(height: isSmallScreen ? 10 : 18),
                Text(
                  'Top Scores',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        isSmallScreen ? size.width * 0.06 : size.width * 0.04,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 12),
                Expanded(
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredResults.isEmpty
                          ? const Center(child: Text('No results found'))
                          : ListView.separated(
                            itemCount: filteredResults.length,
                            separatorBuilder:
                                (_, __) =>
                                    SizedBox(height: isSmallScreen ? 6 : 12),
                            itemBuilder: (context, index) {
                              final result = filteredResults[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 12 : 18,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: colorScheme.primary
                                        .withOpacity(0.1),
                                    radius:
                                        isSmallScreen
                                            ? size.width * 0.045
                                            : size.width * 0.03,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize:
                                            isSmallScreen
                                                ? size.width * 0.045
                                                : size.width * 0.03,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${result.nickname}: ${result.score}/${result.totalQuestions}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          isSmallScreen
                                              ? size.width * 0.045
                                              : size.width * 0.03,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Catégorie: ${getCategoryName(result.category)}\n'
                                    'Difficulté: ${result.difficulty.capitalize()}\n'
                                    'Date: ${result.timestamp.toLocal().toString().substring(0, 16)}',
                                    style: TextStyle(
                                      fontSize:
                                          isSmallScreen
                                              ? size.width * 0.032
                                              : size.width * 0.02,
                                    ),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 10 : 18),
                  child: ElevatedButton.icon(
                    onPressed: _clearAllResults,
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size:
                          isSmallScreen ? size.width * 0.06 : size.width * 0.04,
                    ),
                    label: Text(
                      'Reset All Results',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen
                                ? size.width * 0.04
                                : size.width * 0.025,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: colorScheme.surface,
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 32,
                        vertical: isSmallScreen ? 10 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme, Size size, bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                isDense: true,
                isExpanded: true,
                dropdownColor:
                    colorScheme.surface, // <-- Set dropdown background
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 12,
                    vertical: isSmallScreen ? 8 : 14,
                  ),
                ),
                style: TextStyle(
                  fontSize:
                      isSmallScreen ? size.width * 0.04 : size.width * 0.025,
                  color: colorScheme.onSurface, // <-- Set text color
                ),
                items:
                    categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(
                          category['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.04
                                    : size.width * 0.025,
                            color: colorScheme.onSurface, // <-- Set text color
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    _applyFilters();
                  });
                },
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedDifficulty,
                isDense: true,
                isExpanded: true,
                dropdownColor:
                    colorScheme.surface, // <-- Set dropdown background
                decoration: InputDecoration(
                  labelText: 'Difficulté',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 12,
                    vertical: isSmallScreen ? 8 : 14,
                  ),
                ),
                style: TextStyle(
                  fontSize:
                      isSmallScreen ? size.width * 0.04 : size.width * 0.025,
                  color: colorScheme.onSurface, // <-- Set text color
                ),
                items:
                    difficulties.map((difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(
                          difficulty.capitalize(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.04
                                    : size.width * 0.025,
                            color: colorScheme.onSurface, // <-- Set text color
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 12),
        DropdownButtonFormField<int>(
          value: selectedQuestionCount,
          dropdownColor: colorScheme.surface,
          decoration: InputDecoration(
            labelText: 'Nombre de questions',
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 18,
              vertical: isSmallScreen ? 8 : 14,
            ),
          ),
          style: TextStyle(
            fontSize: isSmallScreen ? size.width * 0.04 : size.width * 0.025,
          ),
          items:
              questionCounts.map((count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(
                    count == 0 ? 'All' : count.toString(),
                    style: TextStyle(
                      fontSize:
                          isSmallScreen
                              ? size.width * 0.04
                              : size.width * 0.025,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedQuestionCount = value!;
              _applyFilters();
            });
          },
        ),
      ],
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
