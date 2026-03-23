enum ActionType { addNote, likeNote }

class SyncAction {
  final String id;
  final ActionType type;
  final Map<String, dynamic> payload;
  final int retryCount;

  SyncAction({
    required this.id,
    required this.type,
    required this.payload,
    this.retryCount = 0,
  });

  SyncAction copyWith({
    String? id,
    ActionType? type,
    Map<String, dynamic>? payload,
    int? retryCount,
  }) {
    return SyncAction(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'retryCount': retryCount,
    };
  }

  factory SyncAction.fromMap(Map<String, dynamic> map) {
    return SyncAction(
      id: map['id'],
      type: ActionType.values.firstWhere((e) => e.name == map['type']),
      payload: Map<String, dynamic>.from(map['payload']),
      retryCount: map['retryCount'] ?? 0,
    );
  }
}
