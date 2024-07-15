class AllahName {
  final String name;
  final String meaning;
  bool isSelected;

  AllahName({
    required this.name,
    required this.meaning,
    this.isSelected = false,
  });
}

class Dhikr {
  final String name;
  final String meaning;
  bool isSelected;

  Dhikr({
    required this.name,
    required this.meaning,
    this.isSelected = false,
  });
}

class NameEntry {
  String name;
  String meaning;
  bool isSelected;

  NameEntry({required this.name, required this.meaning, this.isSelected = false,});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'meaning': meaning,
    };
  }

  factory NameEntry.fromMap(Map<String, dynamic> map) {
    return NameEntry(
      name: map['name'],
      meaning: map['meaning'],
    );
  }
}


