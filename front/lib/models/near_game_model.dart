/// Represents a similar (neighboring) game as determined by recommendation algorithms.
///
/// Contains minimal metadata required for displaying a suggestion.
class NearGameModel {
  /// The Steam application identifier.
  final int appid;

  /// The display title of the game.
  final String name;

  /// The calculated similarity score relative to the reference game.
  final double score;

  const NearGameModel({
    required this.appid,
    required this.name,
    required this.score,
  });

  /// Creates a [NearGameModel] instance from a JSON map.
  factory NearGameModel.fromJson(Map<String, dynamic> json) {
    return NearGameModel(
      appid: int.parse(json['appid'].toString()),
      name: json['name'] as String,
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Serializes the model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'appid': appid,
      'name': name,
      'score': score,
    };
  }
}
