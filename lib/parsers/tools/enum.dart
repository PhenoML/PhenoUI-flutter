T decodeEnumValue<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) {
    return fallback;
  }
  return values.byName(name);
}