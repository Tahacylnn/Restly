class BreakItem {
  final String id;
  final String type;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? endedAt;
  BreakItem({required this.id, required this.type, required this.startAt, required this.endAt, this.endedAt});
  factory BreakItem.fromJson(Map<String,dynamic> j) => BreakItem(
    id: j['id'],
    type: j['type'],
    startAt: DateTime.parse(j['start_at'] ?? j['startAt'] ?? DateTime.now().toIso8601String()),
    endAt: DateTime.parse(j['end_at'] ?? j['endAt'] ?? DateTime.now().toIso8601String()),
    endedAt: j['ended_at'] != null ? DateTime.parse(j['ended_at']) : null
  );
}
