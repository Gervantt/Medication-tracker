/// Symptoms offered as ready-made tags. They are stored by [name]; custom
/// symptoms are stored as the text the user entered.
enum PredefinedSymptom {
  headache,
  nausea,
  weakness;

  static PredefinedSymptom? tryParse(String value) {
    for (final symptom in values) {
      if (symptom.name == value) return symptom;
    }
    return null;
  }
}
