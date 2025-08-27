class Character {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final List<String> greetings;
  final List<String> personality;
  final List<String> speechPatterns;
  final Map<String, List<String>> responses;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.greetings,
    required this.personality,
    required this.speechPatterns,
    required this.responses,
  });
}
