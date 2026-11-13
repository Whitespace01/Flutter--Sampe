import 'package:material_ui/material_ui.dart';

class Q {
  final String subject, q, why;
  final List<String> options;
  final int answer;
  const Q(this.subject, this.q, this.options, this.answer, this.why);
}

const List<Q> kQuestions = [
  Q('গণিত', '√144 = কত?', ['12', '14', '16', '24'], 0, '12 × 12 = 144'),
  Q('গণিত', '2ˣ = 32 হলে x = কত?', ['3', '4', '5', '6'], 2, '2⁵ = 32'),
  Q('গণিত', 'ত্রিভুজের তিন কোণের সমষ্টি কত?', ['90°', '120°', '180°', '360°'], 2, 'ত্রিভুজের কোণত্রয়ের সমষ্টি সবসময় 180°'),
  Q('গণিত', 'বৃত্তের ক্ষেত্রফলের সূত্র কোনটি?', ['2πr', 'πr²', 'πd', 'r²'], 1, 'বৃত্তের ক্ষেত্রফল = πr²'),
  Q('গণিত', '200 এর 15% = কত?', ['15', '20', '25', '30'], 3, '200 × 15/100 = 30'),
  Q('তথ্য ও যোগাযোগ প্রযুক্তি', 'CPU এর পূর্ণরূপ কোনটি?', ['Central Processing Unit', 'Computer Personal Unit', 'Central Program Unit', 'Control Processing Unit'], 0, 'CPU = Central Processing Unit'),
  Q('তথ্য ও যোগাযোগ প্রযুক্তি', 'দশমিক 10 এর বাইনারি কত?', ['1001', '1010', '1100', '1110'], 1, '10 = 8 + 2 = 1010₂'),
  Q('তথ্য ও যোগাযোগ প্রযুক্তি', 'WWW এর পূর্ণরূপ কোনটি?', ['World Wide Web', 'Web World Wide', 'World Web Window', 'Wide World Web'], 0, 'WWW = World Wide Web'),
  Q('তথ্য ও যোগাযোগ প্রযুক্তি', 'কোনটি ইনপুট ডিভাইস?', ['Monitor', 'Printer', 'Keyboard', 'Speaker'], 2, 'Keyboard দিয়ে কম্পিউটারে তথ্য দেওয়া হয়'),
  Q('তথ্য ও যোগাযোগ প্রযুক্তি', '1 KB = কত byte?', ['100 byte', '1000 byte', '1024 byte', '2048 byte'], 2, '1 KB = 1024 byte'),
];

void main() => runApp(const ExamApp());

class ExamApp extends StatelessWidget {
  const ExamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSC Exam Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F5FB),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final subjects = <String, IconData>{
      'গণিত': Icons.calculate,
      'তথ্য ও যোগাযোগ প্রযুক্তি': Icons.computer,
    };
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2A72), Color(0xFF6C3483)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              const Icon(Icons.school, size: 56, color: Colors.amber),
              const SizedBox(height: 10),
              const Text('SSC Exam Prep',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text('Sample — Flutter version',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 30),
              ...subjects.entries.map((e) {
                final count =
                    kQuestions.where((q) => q.subject == e.key).length;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF6C3483),
                        child: Icon(e.value, color: Colors.white),
                      ),
                      title: Text(e.key,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      subtitle: Text('$count টি প্রশ্ন • Practice'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => QuizScreen(subject: e.key))),
                    ),
                  ),
                );
              }),
              const Spacer(),
              const Text('Made by Know Dear',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String subject;
  const QuizScreen({super.key, required this.subject});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Q> qs =
      kQuestions.where((q) => q.subject == widget.subject).toList();
  int idx = 0;
  int score = 0;
  int? picked;

  void pick(int i) {
    if (picked != null) return;
    setState(() {
      picked = i;
      if (i == qs[idx].answer) score++;
    });
  }

  void next() {
    if (idx + 1 >= qs.length) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ResultScreen(score: score, total: qs.length)));
    } else {
      setState(() {
        idx++;
        picked = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = qs[idx];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: const Color(0xFF2A2A72),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (idx + 1) / qs.length,
              minHeight: 8,
              backgroundColor: Colors.indigo.shade100,
              color: const Color(0xFF6C3483),
            ),
            const SizedBox(height: 8),
            Text('প্রশ্ন ${idx + 1} / ${qs.length}   •   Score: $score',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(q.q,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(q.options.length, (i) {
              Color? bg;
              if (picked != null) {
                if (i == q.answer) bg = Colors.green.shade100;
                if (i == picked && i != q.answer) bg = Colors.red.shade100;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg ?? Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: () => pick(i),
                  child: Text(
                      '${String.fromCharCode(65 + i)}.  ${q.options[i]}',
                      style: const TextStyle(fontSize: 17)),
                ),
              );
            }),
            if (picked != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  (picked == q.answer
                          ? '✅ সঠিক! '
                          : '❌ ভুল। সঠিক উত্তর: ${q.options[q.answer]}. ') +
                      q.why,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: next,
                child: Text(idx + 1 >= qs.length ? 'Result দেখো' : 'পরের প্রশ্ন →',
                    style: const TextStyle(fontSize: 17)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score, total;
  const ResultScreen({super.key, required this.score, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = (score / total * 100).round();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2A72), Color(0xFF6C3483)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pct >= 60 ? Icons.emoji_events : Icons.refresh,
                    size: 72, color: Colors.amber),
                const SizedBox(height: 14),
                Text('তোমার Score: $score / $total',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('$pct%',
                    style: const TextStyle(fontSize: 20, color: Colors.white70)),
                const SizedBox(height: 26),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 34),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Home এ ফিরে যাও',
                      style: TextStyle(fontSize: 17)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
