enum PartOfSpeech { noun, verb, adjective, phrase, number, adverb }

enum Gender { masculine, feminine, neuter }

class VocabExample {
  final String czech;
  final String vietnamese;

  const VocabExample({required this.czech, required this.vietnamese});

  factory VocabExample.fromJson(Map<String, dynamic> json) =>
      VocabExample(czech: json['czech'] as String, vietnamese: json['vietnamese'] as String);

  Map<String, dynamic> toJson() => {'czech': czech, 'vietnamese': vietnamese};
}

class VocabItem {
  final String id;
  final String czech;
  final String vietnamese;
  final String pronunciation;
  final String? audioFile;
  final PartOfSpeech partOfSpeech;
  final List<String> tags;
  final Gender? gender;
  final VocabExample? example;

  const VocabItem({
    required this.id,
    required this.czech,
    required this.vietnamese,
    required this.pronunciation,
    this.audioFile,
    required this.partOfSpeech,
    required this.tags,
    this.gender,
    this.example,
  });

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      id: json['id'] as String,
      czech: json['czech'] as String,
      vietnamese: json['vietnamese'] as String,
      pronunciation: json['pronunciation'] as String,
      audioFile: json['audioFile'] as String?,
      partOfSpeech: _parsePartOfSpeech(json['partOfSpeech'] as String),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      gender: json['gender'] != null ? _parseGender(json['gender'] as String) : null,
      example: json['example'] != null
          ? VocabExample.fromJson(json['example'] as Map<String, dynamic>)
          : null,
    );
  }

  static PartOfSpeech _parsePartOfSpeech(String s) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PartOfSpeech.phrase,
    );
  }

  static Gender? _parseGender(String s) {
    return Gender.values.firstWhere(
      (e) => e.name == s,
      orElse: () => Gender.neuter,
    );
  }
}
