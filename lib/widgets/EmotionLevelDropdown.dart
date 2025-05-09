import 'package:flutter/material.dart';

class EmotionLevelDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const EmotionLevelDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: value,
              isExpanded: true, // 幅いっぱいに広げる
              menuMaxHeight: 280, // メニューの最大高さを制限
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 垂直方向のパディングを小さく
              ),
              items: [
                _buildSimpleDropdownMenuItem(1, '😊 簡単', context),
                _buildSimpleDropdownMenuItem(2, '😐 普通', context),
                _buildSimpleDropdownMenuItem(3, '😓 やや難しい', context),
                _buildSimpleDropdownMenuItem(4, '😩 やる気が出ない', context),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // シンプルなドロップダウンメニューアイテムを作成
  DropdownMenuItem<int> _buildSimpleDropdownMenuItem(int value, String label, BuildContext context) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// 感情レベルに対応する絵文字とアイコンを取得するためのヘルパークラス
class EmotionLevelHelper {
  // 感情レベルに対応する絵文字を返す
  static String getEmoji(int level) {
    switch (level) {
      case 1:
        return '😊';
      case 2:
        return '😐';
      case 3:
        return '😓';
      case 4:
        return '😩';
      default:
        return '😐';
    }
  }

  // 感情レベルに対応するIconDataを返す
  static IconData getIconData(int level) {
    switch (level) {
      case 1:
        return Icons.sentiment_very_satisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_dissatisfied;
      case 4:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // 感情レベルに対応する色を返す
  static Color getColor(int level, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return colorScheme.primary;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  // 感情レベルの説明テキストを返す
  static String getDescription(int level) {
    switch (level) {
      case 1:
        return '作業に対してポジティブな気持ちがあり、負担を感じない';
      case 2:
        return '可もなく不可もなく、淡々とこなせる';
      case 3:
        return '注意が必要だったり、少し疲れを感じる';
      case 4:
        return '作業に対して強い負担や抵抗感がある';
      default:
        return '可もなく不可もなく、淡々とこなせる';
    }
  }
}