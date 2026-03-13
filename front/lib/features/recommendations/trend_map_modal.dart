import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:front/models/game_model_detailed.dart';
import 'package:front/services/game_service.dart';

// Class pour définir Continent (nom, couleur, points)

class _Continent {
  final String name;
  final Color color;
  final List<Offset> points;

  const _Continent({
    required this.name,
    required this.color,
    required this.points,
  });
}

// Liste de points pour chaque continent, normalisés entre 0 et 1
const List<_Continent> _kContinents = [
  _Continent(
    name: 'Amérique du Nord',
    color: Color(0xFF3A86FF),
    points: [
      Offset(0.06, 0.08),
      Offset(0.26, 0.06),
      Offset(0.30, 0.14),
      Offset(0.28, 0.28),
      Offset(0.22, 0.34),
      Offset(0.20, 0.42),
      Offset(0.16, 0.46),
      Offset(0.10, 0.42),
      Offset(0.04, 0.30),
      Offset(0.04, 0.18),
    ],
  ),
  _Continent(
    name: 'Amérique du Sud',
    color: Color(0xFF06D6A0),
    points: [
      Offset(0.18, 0.47),
      Offset(0.26, 0.47),
      Offset(0.30, 0.53),
      Offset(0.30, 0.64),
      Offset(0.26, 0.74),
      Offset(0.22, 0.80),
      Offset(0.18, 0.76),
      Offset(0.14, 0.66),
      Offset(0.14, 0.56),
      Offset(0.16, 0.50),
    ],
  ),
  _Continent(
    name: 'Europe',
    color: Color(0xFFFFBE0B),
    points: [
      Offset(0.42, 0.06),
      Offset(0.54, 0.06),
      Offset(0.58, 0.12),
      Offset(0.56, 0.22),
      Offset(0.50, 0.26),
      Offset(0.44, 0.24),
      Offset(0.40, 0.18),
      Offset(0.40, 0.12),
    ],
  ),
  _Continent(
    name: 'Afrique',
    color: Color(0xFFFF6B35),
    points: [
      Offset(0.42, 0.28),
      Offset(0.56, 0.26),
      Offset(0.60, 0.34),
      Offset(0.60, 0.52),
      Offset(0.56, 0.62),
      Offset(0.52, 0.70),
      Offset(0.46, 0.68),
      Offset(0.40, 0.56),
      Offset(0.38, 0.44),
      Offset(0.40, 0.34),
    ],
  ),
  _Continent(
    name: 'Asie',
    color: Color(0xFFE040FB),
    points: [
      Offset(0.56, 0.06),
      Offset(0.90, 0.06),
      Offset(0.96, 0.14),
      Offset(0.94, 0.24),
      Offset(0.86, 0.34),
      Offset(0.80, 0.36),
      Offset(0.72, 0.34),
      Offset(0.64, 0.36),
      Offset(0.60, 0.32),
      Offset(0.58, 0.22),
      Offset(0.56, 0.14),
    ],
  ),
  _Continent(
    name: 'Océanie',
    color: Color(0xFF00B4D8),
    points: [
      Offset(0.76, 0.52),
      Offset(0.90, 0.50),
      Offset(0.96, 0.58),
      Offset(0.92, 0.70),
      Offset(0.82, 0.72),
      Offset(0.76, 0.66),
      Offset(0.74, 0.58),
    ],
  ),
];

// CustomPainter pour dessiner la carte

class _WorldMapPainter extends CustomPainter {
  final String? selectedContinent;

  _WorldMapPainter({this.selectedContinent});

  @override
  void paint(Canvas canvas, Size size) {
    // Ocean background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D2137),
    );

    for (final continent in _kContinents) {
      final path = _continentPath(continent.points, size);
      final bool isSelected = continent.name == selectedContinent;
      final paint = Paint()
        ..color = isSelected
            ? continent.color
            : continent.color.withOpacity(0.45)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = isSelected ? Colors.white : continent.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2 : 1;

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);

      // Affichage du nom du continent sur le dessin
      final labelPaint = TextPainter(
        text: TextSpan(
          text: _shortName(continent.name),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: size.width * 0.028,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final centroid = _centroid(continent.points, size);
      labelPaint.paint(
        canvas,
        centroid - Offset(labelPaint.width / 2, labelPaint.height / 2),
      );
    }
  }

  Path _continentPath(List<Offset> points, Size size) {
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  Offset _centroid(List<Offset> points, Size size) {
    double cx = 0, cy = 0;
    for (final p in points) {
      cx += p.dx;
      cy += p.dy;
    }
    return Offset(
      (cx / points.length) * size.width,
      (cy / points.length) * size.height,
    );
  }

  String _shortName(String name) {
    if (name == 'Amérique du Nord') return 'Amér.\nNord';
    if (name == 'Amérique du Sud') return 'Amér.\nSud';
    return name;
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter old) =>
      old.selectedContinent != selectedContinent;
}

// Test pour détecter sur quel continent on clique
String? _hitTestContinent(Offset localPos, Size size) {
  for (final continent in _kContinents.reversed) {
    final path = Path();
    final points = continent.points;
    for (int i = 0; i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    if (path.contains(localPos)) return continent.name;
  }
  return null;
}

// Modal Widget pour afficher les jeux populaires par continent
class TrendMapModal extends StatefulWidget {
  const TrendMapModal({super.key});

  @override
  State<TrendMapModal> createState() => _TrendMapModalState();
}

class _TrendMapModalState extends State<TrendMapModal> {

  String? _selectedContinent;
  bool _isLoading = false;
  List<GameModelDetailed> _randomGames = [];

  Future<void> _fetchRandomGames(String continent) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _selectedContinent = continent;
      _randomGames = [];
    });

    try {
      final randomLetter = String.fromCharCode(Random().nextInt(26) + 97);
      final games = await Provider.of<GameService>(context, listen: false).searchGames(randomLetter, limit: 20);
      if (games.isNotEmpty) {
        games.shuffle();
        if (mounted) {
          setState(() {
            _randomGames = games.take(5).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur fetching jeux: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Build du modal avec la carte et les jeux
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF171a21),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.public, color: Color(0xFF66c0f4), size: 26),
                    SizedBox(width: 12),
                    Text(
                      'Trend dans le monde',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Cliquez sur un continent pour découvrir des jeux populaires.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Mapmonde - 50% de la hauteur du modal
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2a3f54), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapDown: (details) {
                        final hit =
                            _hitTestContinent(details.localPosition, size);
                        if (hit != null) _fetchRandomGames(hit);
                      },
                      child: CustomPaint(
                        size: size,
                        painter: _WorldMapPainter(
                          selectedContinent: _selectedContinent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),

            // Zone des résultats - 50% de la hauteur du modal
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF66c0f4)),
                      ),
                    )
                  else if (_selectedContinent == null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app,
                                color: Colors.grey[700], size: 40),
                            const SizedBox(height: 10),
                            Text(
                              'Cliquez sur un continent sur la carte',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_randomGames.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Aucun jeu trouvé pour $_selectedContinent.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: Color(0xFF66c0f4), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Tendance en $_selectedContinent',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _randomGames.length,
                        itemBuilder: (context, index) =>
                            _buildGameRow(_randomGames[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRow(GameModelDetailed game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1b2838),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            game.imageUrl,
            width: 80,
            height: 45,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 45,
              color: Colors.grey[800],
              child: const Icon(Icons.image_not_supported,
                  size: 18, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          game.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          game.studio ?? 'Studio inconnu',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
