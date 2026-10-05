abstract final class AppRoutes {
  static const today = '/today';
  static const medications = '/medications';
  static const medicationNew = '$medications/new';
  static const diary = '/diary';
  static const statistics = '/statistics';

  static String medicationEdit(int id) => '$medications/$id/edit';
}
