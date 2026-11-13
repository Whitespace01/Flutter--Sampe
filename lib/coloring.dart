import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

import 'art_store.dart';

class ColoringItem {
  final String asset;
  final String title;
  final String category;
  const ColoringItem(this.asset, this.title, this.category);
}

/// The shared colour palette used by the colouring and drawing screens.
const List<Color> kPalette = [
  Color(0xFFE53935), Color(0xFFD81B60), Color(0xFF8E24AA), Color(0xFF5E35B1),
  Color(0xFF3949AB), Color(0xFF1E88E5), Color(0xFF00ACC1), Color(0xFF00897B),
  Color(0xFF43A047), Color(0xFF7CB342), Color(0xFFC0CA33), Color(0xFFFDD835),
  Color(0xFFFFB300), Color(0xFFFB8C00), Color(0xFFF4511E), Color(0xFF6D4C41),
  Color(0xFF795548), Color(0xFFA1887F), Color(0xFF000000), Color(0xFF616161),
  Color(0xFFBDBDBD), Color(0xFFFFFFFF), Color(0xFFFFCCBC), Color(0xFFFFCDD2),
  Color(0xFFBBDEFB), Color(0xFFC8E6C9), Color(0xFFFFF9C4), Color(0xFFD1C4E9),
];

class ColoringPage extends StatefulWidget {
  final ColoringItem item;
  const ColoringPage({super.key, required this.item});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  Uint8List? _pixels;
  ui.Image? _image;
  int _w = 0;
  int _h = 0;
  Color _color = const Color(0xFFE53935);
  final List<Uint8List> _undoStack = [];
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await rootBundle.load(widget.item.asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 1024,
      targetHeight: 1024,
    );
    final frame = await codec.getNextFrame();
    final raw =
        await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    _w = frame.image.width;
    _h = frame.image.height;
    _pixels = Uint8List.fromList(raw!.buffer.asUint8List());
    _image = frame.image;
    if (mounted) setState(() => _busy = false);
  }

  bool _isLine(int i) {
    final p = _pixels!;
    // luminance below threshold counts as an outline pixel (a barrier)
    return (p[i] + p[i + 1] + p[i + 2]) < 330;
  }

  Future<void> _fillAt(Offset local, Size size) async {
    if (_pixels == null || _busy) return;
    final x = (local.dx / size.width * _w).floor();
    final y = (local.dy / size.height * _h).floor();
    if (x < 0 || y < 0 || x >= _w || y >= _h) return;
    final start = (y * _w + x) * 4;
    if (_isLine(start)) return;
    final p = _pixels!;
    final r = (_color.value >> 16) & 0xFF;
    final g = (_color.value >> 8) & 0xFF;
    final b = _color.value & 0xFF;
    if (p[start] == r && p[start + 1] == g && p[start + 2] == b) return;

    _undoStack.add(Uint8List.fromList(p));
    if (_undoStack.length > 25) _undoStack.removeAt(0);

    // Scanline flood fill: fills every non-line pixel connected to the tap.
    final stack = <int>[y * _w + x];
    final seen = Uint8List(_w * _h);
    while (stack.isNotEmpty) {
      final pos = stack.removeLast();
      if (seen[pos] == 1) continue;
      seen[pos] = 1;
      final i = pos * 4;
      if (_isLine(i)) continue;
      p[i] = r;
      p[i + 1] = g;
      p[i + 2] = b;
      p[i + 3] = 255;
      final px = pos % _w;
      final py = pos ~/ _w;
      if (px > 0) stack.add(pos - 1);
      if (px < _w - 1) stack.add(pos + 1);
      if (py > 0) stack.add(pos - _w);
      if (py < _h - 1) stack.add(pos + _w);
    }

    final img = await _decode(p);
    if (mounted) setState(() => _image = img);
  }

  Future<ui.Image> _decode(Uint8List px) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, _w, _h, ui.PixelFormat.rgba8888,
        (img) => completer.complete(img));
    return completer.future;
  }

  Future<void> _undo() async {
    if (_undoStack.isEmpty || _pixels == null) return;
    final prev = _undoStack.removeLast();
    _pixels = prev;
    final img = await _decode(prev);
    if (mounted) setState(() => _image = img);
  }

  Future<void> _save() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()
        as dynamic; // RenderRepaintBoundary
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
        title: Text(widget.item.title),
        backgroundColor: const Color(0xFF241547),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _undoStack.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save to gallery',
            onPressed: _image == null ? null : _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _busy || _image == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: Container(
                            color: Colors.white,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final size = Size(constraints.maxWidth,
                                    constraints.maxHeight);
                                return GestureDetector(
                                  onTapUp: (d) =>
                                      _fillAt(d.localPosition, size),
                                  child: RawImage(
                                    image: _image,
                                    fit: BoxFit.fill,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Container(
            color: const Color(0xFF241547),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kPalette.length,
                itemBuilder: (context, i) {
                  final c = kPalette[i];
                  final selected = c == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.amber : Colors.white24,
                          width: selected ? 3.5 : 1.5,
                        ),
                      ),
                      child: c == Colors.white
                          ? const Icon(Icons.format_color_reset,
                              size: 18, color: Colors.grey)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: const Color(0xFF241547),
            padding: const EdgeInsets.only(bottom: 12),
            child: const Text(
              'Tap any part of the picture to fill it with colour',
              style: TextStyle(color: Colors.white54, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
