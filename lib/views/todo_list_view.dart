import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../view_models/todo_view_model.dart';
import 'todo_add_view.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({Key? key}) : super(key: key);

  @override
  _TodoListViewState createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1秒ごとに定期的に更新して、作業中のタイマーを更新
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final viewModel = Provider.of<TodoViewModel>(context, listen: false);
      viewModel.updateWorkingTimes();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODOリスト'),
        backgroundColor: colorScheme.surfaceVariant,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          final todos = viewModel.todos;

          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TODOがありません',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下のボタンから追加してください',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 統計情報カード
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.pending_actions,
                          '残りのタスク',
                          '${viewModel.remainingCount}',
                          colorScheme.primary,
                        ),
                        _buildStatItem(
                          context,
                          Icons.task_alt,
                          '完了したタスク',
                          '${viewModel.completedCount}',
                          colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // TODOリスト
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Dismissible(
                        key: Key(todo.id),
                        background: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          viewModel.removeTodo(todo.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${todo.title}を削除しました'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              action: SnackBarAction(
                                label: '元に戻す',
                                onPressed: () {
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isCompleted
                                        ? Theme.of(context).colorScheme.onSurfaceVariant
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (todo.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          todo.description,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    if (todo.workSessions.isNotEmpty || todo.isWorking)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '作業時間: ${todo.getFormattedWorkDuration()}',
                                              style: TextStyle(
                                                color: todo.isWorking
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurfaceVariant,
                                                fontWeight: todo.isWorking
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                leading: Checkbox(
                                  value: todo.isCompleted,
                                  shape: const CircleBorder(),
                                  onChanged: (_) {
                                    viewModel.toggleComplete(todo.id);
                                  },
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 作業時間記録ボタン
                                    IconButton(
                                      icon: Icon(
                                        todo.isWorking
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled_outlined,
                                        color: todo.isWorking
                                            ? colorScheme.primary
                                            : todo.isCompleted
                                            ? colorScheme.onSurfaceVariant.withOpacity(0.3)
                                            : null,
                                      ),
                                      tooltip: todo.isCompleted
                                          ? '完了したタスクは作業記録できません'
                                          : todo.isWorking
                                          ? '作業を一時停止'
                                          : '作業を開始',
                                      onPressed: todo.isCompleted
                                          ? null  // 完了タスクは無効化
                                          : () {
                                        viewModel.toggleWorkTimer(todo.id);
                                      },
                                    ),
                                    // 編集ボタン
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        _showEditTodoDialog(context, viewModel, todo as Todo);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showEditTodoDialog(context, viewModel, todo as Todo);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_task),
        label: const Text('新しいタスク'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoAddView()),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showEditTodoDialog(BuildContext context, TodoViewModel viewModel, Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          title: const Text('TODOを編集'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'タイトル',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: '詳細',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  maxLines: 3,
                ),
                if (todo.workSessions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '合計作業時間: ${todo.getFormattedWorkDuration()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (todo.isWorking)
              TextButton.icon(
                onPressed: () {
                  viewModel.toggleWorkTimer(todo.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.pause),
                label: const Text('作業を停止'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (!todo.isWorking && !todo.isCompleted)
              TextButton.icon(
                onPressed: () {
                  viewModel.toggleWorkTimer(todo.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('作業を開始'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  viewModel.updateTodo(
                    todo.id,
                    titleController.text,
                    descriptionController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('更新'),
            ),
          ],
        );
      },
    );
  }
}