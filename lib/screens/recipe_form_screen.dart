import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe; // 編集時は既存のレシピを渡す

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  final List<String> _selectedTags = [];
  final _newTagController = TextEditingController();

  // よく使われるタグの例
  final List<String> _availableTags = ['和食', '洋食', '中華', '簡単', 'ヘルシー', 'デザート'];

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // 編集モードの場合、既存データをロード
      _titleController.text = widget.recipe!.title;
      _instructionsController.text = widget.recipe!.instructions;
      _selectedTags.addAll(widget.recipe!.tags);
      for (var ingredient in widget.recipe!.ingredients) {
        final controller = TextEditingController(text: ingredient);
        _ingredientControllers.add(controller);
      }
    } else {
      // 新規作成の場合は1つの空の材料フィールドを追加
      _ingredientControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _newTagController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _addNewTag() {
    final newTag = _newTagController.text.trim();
    if (newTag.isNotEmpty && !_selectedTags.contains(newTag)) {
      setState(() {
        _selectedTags.add(newTag);
        if (!_availableTags.contains(newTag)) {
          _availableTags.add(newTag);
        }
        _newTagController.clear();
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // 材料リストを作成（空でないもののみ）
      final ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('材料を最低1つ入力してください')),
        );
        return;
      }

      final now = DateTime.now();
      final recipe = Recipe(
        id: _isEditing ? widget.recipe!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        ingredients: ingredients,
        instructions: _instructionsController.text.trim(),
        tags: _selectedTags,
        createdAt: _isEditing ? widget.recipe!.createdAt : now,
        updatedAt: now,
      );

      Navigator.pop(context, recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'レシピ編集' : 'レシピ追加'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // レシピ名入力
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'レシピ名',
                hintText: '例: カレーライス',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'レシピ名を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // タグ選択
            const Text(
              'タグ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (_) => _toggleTag(tag),
                  selectedColor: Colors.orange.shade200,
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // 新規タグ追加
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      labelText: '新しいタグを追加',
                      hintText: '例: イタリアン',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addNewTag,
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),

            // 選択済みタグ表示
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '選択中のタグ:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _toggleTag(tag),
                          backgroundColor: Colors.orange.shade100,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 材料入力
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '材料',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addIngredientField,
                  icon: const Icon(Icons.add),
                  label: const Text('材料を追加'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._ingredientControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: '材料 ${index + 1}',
                          hintText: '例: 玉ねぎ 1個',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeIngredientField(index),
                      tooltip: '削除',
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // 作り方入力
            const Text(
              '作り方',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                hintText: '1. 材料を切る\n2. 炒める\n3. 煮込む',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '作り方を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // 保存ボタン
            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isEditing ? '更新する' : '保存する'),
            ),
          ],
        ),
      ),
    );
  }
}
