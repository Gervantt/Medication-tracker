import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Identifies the intake slot a notification belongs to.
/// Serialized into the notification payload string.
class ReminderPayload extends Equatable {
  const ReminderPayload({
    required this.medicationId,
    required this.scheduledAt,
  });

  final int medicationId;
  final DateTime scheduledAt;

  /// Returns `null` for missing or malformed payloads.
  static ReminderPayload? tryDecode(String? payload) {
    if (payload == null) return null;
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return ReminderPayload(
        medicationId: json['medicationId'] as int,
        scheduledAt: DateTime.fromMillisecondsSinceEpoch(
          json['scheduledAt'] as int,
        ),
      );
    } on Object {
      return null;
    }
  }

  String encode() => jsonEncode({
    'medicationId': medicationId,
    'scheduledAt': scheduledAt.millisecondsSinceEpoch,
  });

  /// Stable 31-bit notification id of the slot, so re-scheduling the same
  /// slot replaces its notification instead of duplicating it.
  int get notificationId {
    final minutes = scheduledAt.millisecondsSinceEpoch ~/ 60000;
    return ((minutes & 0xFFFFF) << 11) | (medicationId & 0x7FF);
  }

  @override
  List<Object> get props => [medicationId, scheduledAt];
}
