import 'package:medtrack/core/extensions/date_time_extensions.dart';

abstract final class AppRoutes {
  static const today = '/today';
  static const medications = '/medications';
  static const medicationNew = '$medications/new';
  static const diary = '/diary';
  static const statistics = '/statistics';

  static const drugSearch = '$medications/search';

  static String medicationEdit(int id) => '$medications/$id/edit';

  /// New medication form with [name] prefilled.
  static String medicationNewWithName(String name) =>
      Uri(path: medicationNew, queryParameters: {'name': name}).toString();

  static String drugDetails(String id) =>
      '$drugSearch/${Uri.encodeComponent(id)}';

  static String diaryEntry(DateTime date) => '$diary/entry/${date.isoDate}';
}
