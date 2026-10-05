import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/reminders/data/reminder_payload.dart';

void main() {
  final payload = ReminderPayload(
    medicationId: 42,
    scheduledAt: DateTime(2026, 10, 6, 8, 30),
  );

  group('ReminderPayload', () {
    test('survives an encode/decode round trip', () {
      expect(ReminderPayload.tryDecode(payload.encode()), payload);
    });

    test('returns null for missing or malformed payloads', () {
      for (final raw in [null, '', 'not json', '{"medicationId":"x"}']) {
        expect(ReminderPayload.tryDecode(raw), isNull);
      }
    });

    test('notification id is stable, positive and distinct per slot', () {
      final sameSlot = ReminderPayload(
        medicationId: 42,
        scheduledAt: DateTime(2026, 10, 6, 8, 30),
      );
      final otherTime = ReminderPayload(
        medicationId: 42,
        scheduledAt: DateTime(2026, 10, 6, 8, 31),
      );
      final otherMedication = ReminderPayload(
        medicationId: 43,
        scheduledAt: DateTime(2026, 10, 6, 8, 30),
      );

      expect(payload.notificationId, sameSlot.notificationId);
      expect(payload.notificationId, isNot(otherTime.notificationId));
      expect(payload.notificationId, isNot(otherMedication.notificationId));
      expect(payload.notificationId, inInclusiveRange(0, 0x7FFFFFFF));
    });
  });
}
