abstract class FigmaEnumInterface {
  String? get figmaName;
}

mixin FigmaEnum on Enum implements FigmaEnumInterface {}

extension FigmaEnumValue<T extends FigmaEnum> on Iterable<T> {
  T? byName(String? name) {
    if (name != null) {
      for (var value in this) {
        String figmaName = value.figmaName ?? value.name;
        if (figmaName == name) return value;
      }
    }
    return null;
  }

  T byNameDefault(String? name, T fallback) {
    T? value = this.byName(name);
    if (value == null) {
      return fallback;
    }
    return value;
  }
}

extension EnumValue<T extends Enum> on Iterable<T> {
  T byNameDefault(String? name, T fallback) {
    if (name == null) {
      return fallback;
    }
    try {
      return byName(name);
    } catch (_) {
      return fallback;
    }
  }

  T convert<K extends Enum>(K source) {
    return byName(source.name);
  }

  T convertDefault<K extends Enum>(K source, T fallback) {
    return byNameDefault(source.name, fallback);
  }
}

