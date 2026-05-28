import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_word_page.dart';
import 'word_list_page.dart';
import 'quiz_page.dart';
import 'settings_page.dart';
import 'report_page.dart';
import 'wordle_page.dart';
import 'word_chain_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.indigo,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Card(
              color: Color(0xFFE8EAF6),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.indigo,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '6 Sefer Tekrar Prensibi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Kelime ezberleme ve tekrar sistemi',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            menuButton(
              icon: Icons.add,
              title: 'Kelime Ekle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWordPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.list,
              title: 'Kelime Listesi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WordListPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.quiz,
              title: 'Sınav Modülü',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.settings,
              title: 'Ayarlar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.bar_chart,
              title: 'Analiz Raporu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.grid_on,
              title: 'Wordle Bulmaca',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WordlePage()),
                );
              },
            ),

            menuButton(
              icon: Icons.auto_stories,
              title: 'Word Chain / Hikaye',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WordChainPage()),
                );
              },
            ),

            menuButton(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              color: Colors.red,
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }
}