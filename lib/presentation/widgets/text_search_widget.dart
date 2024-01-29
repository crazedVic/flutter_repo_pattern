import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_provider.dart';

class TextSearchWidget extends StatefulWidget {
  const TextSearchWidget({super.key});

  @override
  State<TextSearchWidget> createState() => _TextSearchWidgetState();
}

class _TextSearchWidgetState extends State<TextSearchWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Add listener to the text controller
    _searchController.addListener(() {
      setState(() {}); // Rebuild the widget on text change
    });
  }

  @override
  void dispose() {
    // Remove the listener and dispose the controller
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search',
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
          },
        )
            : IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            final searchQuery = _searchController.text;
            if (searchQuery.isNotEmpty) {
              Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(search: searchQuery);
            }
          },
        ),
      ),
      onSubmitted: (value) {
        final searchQuery = _searchController.text;
        if (searchQuery.isNotEmpty) {
          Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(search: searchQuery);
        }
      },
    );
  }
}
