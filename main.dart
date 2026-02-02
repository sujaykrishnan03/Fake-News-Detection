import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* ================= BACKEND URL ================= */

String getBackendUrl() {
  if (Platform.isAndroid) {
    return "http://10.0.2.2:5000/predict";
  } else {
    return "http://127.0.0.1:5000/predict";
  }
}

void main() {
  runApp(const FakeNewsApp());
}

/* ================= APP ROOT ================= */

class FakeNewsApp extends StatefulWidget {
  const FakeNewsApp({super.key});

  @override
  State<FakeNewsApp> createState() => _FakeNewsAppState();
}

class _FakeNewsAppState extends State<FakeNewsApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fake News Detector",
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: MainScreen(
        isDarkMode: isDarkMode,
        toggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

/* ================= MAIN SCREEN ================= */

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = const [
    HomePage(),
    DetectNewsPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF2575FC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: const Text(
              "Fake News Detector",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: widget.toggleTheme,
              ),
            ],
          ),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check), label: "Detect"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}

/* ================= HOME PAGE ================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Card(
          elevation: 12,
          margin: const EdgeInsets.all(24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, size: 80, color: Colors.deepPurple),
                SizedBox(height: 20),
                Text(
                  "Fake News Detector",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  "Detect fake and real news using\nAI and Machine Learning.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= DETECT NEWS PAGE ================= */

class DetectNewsPage extends StatefulWidget {
  const DetectNewsPage({super.key});

  @override
  State<DetectNewsPage> createState() => _DetectNewsPageState();
}

class _DetectNewsPageState extends State<DetectNewsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  bool loading = false;
  String result = "";

  late AnimationController animController;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    scaleAnim =
        CurvedAnimation(parent: animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Future<void> checkNews() async {
    if (controller.text.isEmpty) return;

    setState(() {
      loading = true;
      result = "";
    });

    final response = await http.post(
      Uri.parse(getBackendUrl()),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": controller.text}),
    );

    final data = jsonDecode(response.body);

    setState(() {
      result = data["prediction"];
      loading = false;
    });

    animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: controller,
                maxLines: 6,
                style:
                const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Paste news headline here...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.analytics),
                label: const Text("Analyze News"),
                onPressed: loading ? null : checkNews,
              ),
            ),
            if (loading) ...[
              const SizedBox(height: 30),
              const Center(
                child:
                CircularProgressIndicator(color: Colors.white),
              ),
            ],
            if (result.isNotEmpty)
              ScaleTransition(
                scale: scaleAnim,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        result == "REAL NEWS"
                            ? Icons.verified
                            : Icons.warning_rounded,
                        size: 60,
                        color: result == "REAL NEWS"
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: result == "REAL NEWS"
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ================= ABOUT PAGE ================= */

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 140, 24, 24),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Center(
                  child: Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    "Fake News Detector",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "\tAI-based News Verification System",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 28),

                Text(
                  "About the Project",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "\tThis application uses intelligent text analysis\n"
                      "\tto classify news content as Real or Fake,\n"
                      "\thelp users identify misinformation quickly\n"
                      "\tand reliably.",
                  style: TextStyle(fontSize: 15),
                ),

                SizedBox(height: 28),
                Divider(),
                SizedBox(height: 18),

                Text(
                  "Team Members",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text("\t\t\t\t\t\t• Sam Deivanayagam J"),
                Text("\t\t\t\t\t\t• Sujay Krishnan S"),
                Text("\t\t\t\t\t\t• Samraj N"),
                Text("\t\t\t\t\t\t• Prakash J"),

                SizedBox(height: 28),
                Divider(),
                SizedBox(height: 18),

                Text(
                  "Mentor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "\tX Amala Princeton M.E.,\n"
                      "\t\t\t\t\t\t\t\t\t\t\t\t\t\A/P CSE",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
