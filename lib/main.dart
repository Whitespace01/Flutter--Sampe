import 'package:material_ui/material_ui.dart';

import 'coloring.dart';
import 'drawing.dart';

void main() {
  runApp(const ColoriaApp());
}

class ColoriaApp extends StatelessWidget {
  const ColoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coloria — Coloring Book & Drawing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

const List<ColoringItem> kPages = [
  ColoringItem('assets/pages/kids_cat.png', 'Cute Cat', 'Kids'),
  ColoringItem('assets/pages/kids_butterfly.png', 'Butterfly', 'Kids'),
  ColoringItem('assets/pages/kids_fish.png', 'Happy Fish', 'Kids'),
  ColoringItem('assets/pages/kids_owl.png', 'Wise Owl', 'Kids'),
  ColoringItem('assets/pages/nature_flower.png', 'Flower Vase', 'Nature'),
  ColoringItem('assets/pages/mandala_1.png', 'Mandala Bloom', 'Mandala'),
  ColoringItem('assets/pages/mandala_2.png', 'Mandala Star', 'Mandala'),
  ColoringItem('assets/pages/pattern_geo.png', 'Geo Pattern', 'Mandala'),
  ColoringItem('assets/pages/bd_rickshaw.png', 'Dhaka Rickshaw', 'Bangladesh'),
  ColoringItem('assets/pages/bd_boat.png', 'River Boat', 'Bangladesh'),
  ColoringItem('assets/pages/bd_shapla.png', 'Shapla Lily', 'Bangladesh'),
];

const List<String> kCategories = [
  'All',
  'Kids',
  'Nature',
  'Mandala',
  'Bangladesh',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _cat = 'All';

  @override
  Widget build(BuildContext context) {
    final pages =
        _cat == 'All' ? kPages : kPages.where((p) => p.category == _cat).toList();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D1140), Color(0xFF4A145A), Color(0xFF7B1E5B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 2),
                child: Text('🎨 Coloria',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text('Coloring Book & Drawing — by Know Dear',
                    style: TextStyle(color: Colors.white70, fontSize: 14.5)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        emoji: '✏️',
                        label: 'Free Drawing',
                        color: const Color(0xFFFFB300),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DrawingPage()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        emoji: '🖼️',
                        label: 'My Gallery',
                        color: const Color(0xFF00ACC1),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GalleryPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: kCategories.length,
                  itemBuilder: (context, i) {
                    final c = kCategories[i];
                    final selected = c == _cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) => setState(() => _cat = c),
                        selectedColor: Colors.amber,
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white12,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: pages.length,
                  itemBuilder: (context, i) {
                    final page = pages[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ColoringPage(item: page)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(page.asset,
                                    fit: BoxFit.contain),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                page.title,
                                style: const TextStyle(
                                  color: Color(0xFF33224D),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
