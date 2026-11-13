import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'art_store.dart';
import 'coloring.dart' show kPalette;

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  const _Stroke(this.points, this.color, this.width);
}

class _StrokePainter extends CustomPainter {
  final List<_Stroke> strokes;
  const _StrokePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, s.points, paint);
      } else {
        final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
        for (final pt in s.points.skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) => old.strokes != strokes;
}

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  Color _color = const Color(0xFF3949AB);
  double _width = 8;
  bool _eraser = false;

  Future<void> _save() async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject() as dynamic;
    final img = await boundary.toImage(pixelRatio: 2.0) as ui.Image;
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    await ArtStore.save(bytes!.buffer.asUint8List());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to My Gallery 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17102E),
      appBar: AppBar(
        title: const Text('Free Drawing'),
        backgroundColor: const Color(0xFF241547),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _strokes.isEmpty
                ? null
                : () => setState(() => _strokes.removeLast()),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: _strokes.isEmpty
                ? null
                : () => setState(() => _strokes.clear()),
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save to gallery',
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onPanStart: (d) => setState(() => _strokes.add(_Stroke(
                            [d.localPosition],
                            _eraser ? Colors.white : _color,
                            _eraser ? _width * 3 : _width,
                          ))),
                      onPanUpdate: (d) => setState(
                          () => _strokes.last.points.add(d.localPosition)),
                      child: CustomPaint(
                        painter: _StrokePainter(_strokes),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF241547),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final w in [4.0, 8.0, 14.0, 22.0])
                      GestureDetector(
                        onTap: () =>
                            setState(() => {_width = w, _eraser = false}),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _width == w && !_eraser
                                ? Colors.amber
                                : Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: w,
                              height: w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => setState(() => _eraser = true),
                      child: Container(
                        width: 44,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _eraser ? Colors.amber : Colors.white12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_fix_high,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kPalette.length,
                    itemBuilder: (context, i) {
                      final c = kPalette[i];
                      final selected = c == _color && !_eraser;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => {_color = c, _eraser = false}),
                        child: Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selected ? Colors.amber : Colors.white24,
                              width: selected ? 3.5 : 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<File>> _future = ArtStore.list();

  void _reload() => setState(() => _future = ArtStore.list());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17102E),
      appBar: AppBar(
        title: const Text('My Gallery'),
        backgroundColor: const Color(0xFF241547),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<File>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          final files = snap.data ?? [];
          if (files.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No artwork yet.\nColour a picture or draw something, then tap Save!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: files.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      _ArtView(file: files[i], onChanged: _reload),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(files[i], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArtView extends StatelessWidget {
  final File file;
  final VoidCallback onChanged;
  const _ArtView({required this.file, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () async {
              await ArtStore.delete(file);
              onChanged();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(child: Image.file(file, fit: BoxFit.contain)),
    );
  }
}
