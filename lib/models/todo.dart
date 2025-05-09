class Todo {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  DateTime? workStartTime;     // 作業開始時間
  DateTime? workEndTime;       // 作業終了時間
  List<WorkSession> workSessions = []; // 複数の作業セッションを記録
  bool isWorking = false;      // 現在作業中かどうか

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.workStartTime,
    this.workEndTime,
    this.isWorking = false,
    List<WorkSession>? workSessions,
  }) : this.workSessions = workSessions ?? [];

  factory Todo.fromJson(Map<String, dynamic> json) {
    List<WorkSession> sessions = [];
    if (json['workSessions'] != null) {
      sessions = (json['workSessions'] as List)
          .map((sessionJson) => WorkSession.fromJson(sessionJson))
          .toList();
    }

    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      workStartTime: json['workStartTime'] != null
          ? DateTime.parse(json['workStartTime'])
          : null,
      workEndTime: json['workEndTime'] != null
          ? DateTime.parse(json['workEndTime'])
          : null,
      isWorking: json['isWorking'] ?? false,
      workSessions: sessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'workStartTime': workStartTime?.toIso8601String(),
      'workEndTime': workEndTime?.toIso8601String(),
      'isWorking': isWorking,
      'workSessions': workSessions.map((session) => session.toJson()).toList(),
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? workStartTime,
    DateTime? workEndTime,
    bool? isWorking,
    List<WorkSession>? workSessions,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      isWorking: isWorking ?? this.isWorking,
      workSessions: workSessions ?? this.workSessions,
    );
  }

  // 合計作業時間を計算（秒単位）
  Duration getTotalWorkDuration() {
    Duration total = Duration.zero;

    // 全てのセッションの合計時間を計算
    for (final session in workSessions) {
      total += session.getDuration();
    }

    // 現在作業中の場合、現在のセッションも加算
    if (isWorking && workStartTime != null) {
      total += DateTime.now().difference(workStartTime!);
    }

    return total;
  }

  // 作業時間の表示用フォーマット
  String getFormattedWorkDuration() {
    final duration = getTotalWorkDuration();
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);

    if (hours > 0) {
      return '$hours時間$minutes分';
    } else if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }
}

// 作業セッションを記録するクラス
class WorkSession {
  final DateTime startTime;
  final DateTime? endTime;

  WorkSession({
    required this.startTime,
    this.endTime,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  Duration getDuration() {
    if (endTime == null) {
      return Duration.zero;
    }
    return endTime!.difference(startTime);
  }
}