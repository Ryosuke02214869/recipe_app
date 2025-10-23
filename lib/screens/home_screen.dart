import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = [];
  String? selectedTag;
  List<String> availableTags = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    recipes = [
      Recipe(
        id: '1',
        title: 'カレーライス',
        ingredients: ['玉ねぎ', 'にんじん', 'じゃがいも', '豚肉', 'カレールー'],
        instructions: '1. 野菜を切る\n2. 肉と野菜を炒める\n3. 水を加えて煮込む\n4. カレールーを溶かす',
        tags: ['和食', '簡単'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Recipe(
        id: '2',
        title: 'パスタカルボナーラ',
        ingredients: ['パスタ', 'ベーコン', '卵', '粉チーズ', '黒胡椒'],
        instructions: '1. パスタを茹でる\n2. ベーコンを炒める\n3. 卵と粉チーズを混ぜる\n4. パスタと和える',
        tags: ['洋食', '簡単'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Recipe(
        id: '3',
        title: '肉じゃが',
        ingredients: ['じゃがいも', '玉ねぎ', '牛肉', 'にんじん', '醤油', 'みりん', '砂糖'],
        instructions: '1. 材料を切る\n2. 肉を炒める\n3. 野菜を加えて炒める\n4. 調味料と水を加えて煮込む',
        tags: ['和食'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    _updateAvailableTags();
  }

  void _updateAvailableTags() {
    final tags = <String>{};
    for (var recipe in recipes) {
      tags.addAll(recipe.tags);
    }
    availableTags = tags.toList()..sort();
  }

  List<Recipe> get filteredRecipes {
    if (selectedTag == null) {
      return recipes;
    }
    return recipes.where((recipe) => recipe.tags.contains(selectedTag)).toList();
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      recipes.add(recipe);
      _updateAvailableTags();
    });
  }

  void _updateRecipe(Recipe updatedRecipe) {
    setState(() {
      final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (index != -1) {
        recipes[index] = updatedRecipe;
        _updateAvailableTags();
      }
    });
  }

  void _deleteRecipe(String id) {
    setState(() {
      recipes.removeWhere((r) => r.id == id);
      _updateAvailableTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ一覧'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // タグフィルター
          if (availableTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('すべて'),
                      selected: selectedTag == null,
                      onSelected: (selected) {
                        setState(() {
                          selectedTag = null;
                        });
                      },
                    ),
                  ),
                  ...availableTags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(tag),
                        selected: selectedTag == tag,
                        onSelected: (selected) {
                          setState(() {
                            selectedTag = selected ? tag : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          // レシピ一覧
          Expanded(
            child: filteredRecipes.isEmpty
                ? const Center(
                    child: Text(
                      'レシピがありません\n+ボタンから追加してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            recipe.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipe.tags.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    spacing: 4,
                                    children: recipe.tags.map((tag) {
                                      return Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatDate(recipe.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            final result = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                  recipe: recipe,
                                ),
                              ),
                            );

                            if (result != null) {
                              if (result['action'] == 'delete') {
                                _deleteRecipe(recipe.id);
                              } else if (result['action'] == 'update') {
                                _updateRecipe(result['recipe'] as Recipe);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Recipe>(
            context,
            MaterialPageRoute(
              builder: (context) => const RecipeFormScreen(),
            ),
          );

          if (result != null) {
            _addRecipe(result);
          }
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
