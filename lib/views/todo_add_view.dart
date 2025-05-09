import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/todo_view_model.dart';
import '../widgets/EmotionLevelDropdown.dart';

class TodoAddView extends StatefulWidget {
  const TodoAddView({Key? key}) : super(key: key);

  @override
  _TodoAddViewState createState() => _TodoAddViewState();
}

class _TodoAddViewState extends State<TodoAddView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isImportant = false;
  int _emotionLevel = 2; // デフォルトは「普通」

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいタスク'),
        backgroundColor: colorScheme.surfaceVariant,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'タスクの詳細',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'タイトル',
                    hintText: 'タスクの名前を入力',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '詳細（任意）',
                    hintText: 'タスクの詳細を入力',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16.0),
                // 重要なタスクスイッチ
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      title: const Text('重要なタスク'),
                      subtitle: const Text('優先度の高いタスクとしてマークする'),
                      value: _isImportant,
                      onChanged: (value) {
                        setState(() {
                          _isImportant = value;
                        });
                      },
                      secondary: Icon(
                        Icons.priority_high,
                        color: _isImportant ? colorScheme.primary : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // 感情レベル選択ドロップダウン
                // モバイル画面では高さの制約があるため、必要に応じてカスタマイズ
                buildEmotionLevelSelector(context, colorScheme),
                const SizedBox(height: 36.0),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final viewModel = Provider.of<TodoViewModel>(context, listen: false);
                      viewModel.addTodo(
                        _titleController.text,
                        _descriptionController.text,
                        _emotionLevel,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('新しいタスクを追加しました'),
                          backgroundColor: colorScheme.primaryContainer,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('タスクを追加'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // カスタムの感情レベル選択ウィジェット
  Widget buildEmotionLevelSelector(BuildContext context, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_emotions,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '感情レベル',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 感情を表すアイコンを表示
            Icon(
              EmotionLevelHelper.getIconData(_emotionLevel),
              color: EmotionLevelHelper.getColor(_emotionLevel, context),
              size: 32,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _emotionLevel,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('😊 簡単'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('😐 普通'),
                ),
                DropdownMenuItem<int>(
                  value: 3,
                  child: Text('😓 やや難しい'),
                ),
                DropdownMenuItem<int>(
                  value: 4,
                  child: Text('😩 やる気が出ない'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _emotionLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 4),
            // 選択中の感情レベルの説明テキスト
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                EmotionLevelHelper.getDescription(_emotionLevel),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}