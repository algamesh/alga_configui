import 'package:flutter/material.dart';
import 'package:alga_configuikit/src/second_page.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alga Config UIKit Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DocumentationPage(),
    );
  }
}

/// A Documentation Page which displays a list of facts that can be filtered and collapsed.
///
/// Each fact is represented as an [ExpansionTile] that can be expanded to show more details.
class DocumentationPage extends StatefulWidget {
  const DocumentationPage({Key? key}) : super(key: key);

  @override
  _DocumentationPageState createState() => _DocumentationPageState();
}

class _DocumentationPageState extends State<DocumentationPage> {
  // List of facts to display.
  final List<FactItem> _allFacts = [
    FactItem(
      category: 'General',
      title: 'Getting Started',
      description:
          'Use the circular button in the app bar to enter the configui view.',
    ),
    FactItem(
      category: 'General',
      title: 'Overview',
      description:
          'configui serves to provide consistent and clean way to interact with app configurations.',
    ),
    FactItem(
      category: 'Technical',
      title: 'Architecture',
      description: 'Package will read and write Datacat objects.',
    ),
    FactItem(
      category: 'Technical',
      title: 'Usage',
      description:
          'configui attachment provides apps a one stop view access to their configurations.',
    ),
    FactItem(
      category: 'Miscellaneous',
      title: 'Credits',
      description: 'tchan',
    ),
  ];

  // Currently selected category filter.
  String _selectedCategory = 'All';

  /// Returns a list of all unique categories with an initial 'All' option.
  List<String> get _categories {
    final categories = _allFacts.map((f) => f.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Returns the list of facts filtered by the selected category.
  List<FactItem> get _filteredFacts {
    if (_selectedCategory == 'All') return _allFacts;
    return _allFacts
        .where((fact) => fact.category == _selectedCategory)
        .toList();
  }

  /// Navigates to the configuration page.
  void _goToConfigPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecondPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentation'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.blue),
              onPressed: () => _goToConfigPage(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown for selecting a category filter.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'All';
                });
              },
            ),
          ),
          // Expanded list of collapsible facts.
          Expanded(
            child: ListView(
              children: _filteredFacts.map((fact) {
                return ExpansionTile(
                  title: Text(fact.title),
                  subtitle: Text(fact.category),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(fact.description),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A model representing a fact with a category, title, and description.
class FactItem {
  final String category;
  final String title;
  final String description;

  FactItem({
    required this.category,
    required this.title,
    required this.description,
  });
}
