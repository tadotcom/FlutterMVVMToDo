import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';

class TodoViewModel extends ChangeNotifier {

  final List<Todo> _todos = [];
  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  int get remainingCount => _todos.length - completedCount;

  // 現在作業中のタスクがあればそのIDを返す
  String? get currentWorkingTodoId {
    final workingTodoIndex = _todos.indexWhere((todo) => todo.isWorking);
    return workingTodoIndex != -1 ? _todos[workingTodoIndex].id : null;
  }

  void addTodo(String title, String description, int emotionLevel) {
    final uuid = Uuid();
    final todo = Todo(
      id: uuid.v4(),
      title: title,
      description: description,
      emotionLevel: emotionLevel,
    );
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void toggleComplete(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      // タスク完了時に作業も終了
      if (!_todos[index].isCompleted && _todos[index].isWorking) {
        toggleWorkTimer(id);
      }

      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
    }
  }

  void updateTodo(String id, String title, String description, int emotionLevel) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title,
        description: description,
        emotionLevel: emotionLevel,
      );
      notifyListeners();
    }
  }

  // 作業時間タイマーの開始・停止
  void toggleWorkTimer(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    // 現在のタスク
    final todo = _todos[index];

    // 完了タスクは作業時間を記録できないように
    if (todo.isCompleted) return;

    // 他のタスクが作業中なら、それを終了する
    final currentWorkingId = currentWorkingTodoId;
    if (currentWorkingId != null && currentWorkingId != id) {
      stopWorkTimer(currentWorkingId);
    }

    if (!todo.isWorking) {
      // 作業開始
      final now = DateTime.now();
      final newSession = WorkSession(startTime: now);

      _todos[index] = todo.copyWith(
        isWorking: true,
        workStartTime: now,
        workSessions: [...todo.workSessions, newSession],
      );
    } else {
      // 作業停止
      stopWorkTimer(id);
    }

    notifyListeners();
  }

  // 作業タイマーを停止
  void stopWorkTimer(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todo = _todos[index];
    if (!todo.isWorking) return;

    final now = DateTime.now();

    // 最新のセッションを更新
    final sessions = [...todo.workSessions];
    if (sessions.isNotEmpty) {
      final lastSession = sessions.last;
      sessions[sessions.length - 1] = WorkSession(
        startTime: lastSession.startTime,
        endTime: now,
      );
    }

    // タスク更新
    _todos[index] = todo.copyWith(
      isWorking: false,
      workEndTime: now,
      workSessions: sessions,
    );

    notifyListeners();
  }

  // 定期的に作業時間を更新するためのメソッド（タイマーに使用）
  void updateWorkingTimes() {
    // 作業中のタスクがあれば通知する（UIを更新するため）
    if (currentWorkingTodoId != null) {
      notifyListeners();
    }
  }
}