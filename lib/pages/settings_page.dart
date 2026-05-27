import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/word_storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final wordCountController = TextEditingController();

  int wordCount = 10;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      wordCount = prefs.getInt('daily_word_count') ?? 10;
      wordCountController.text = wordCount.toString();
    });
  }

  Future<void> saveSettings() async {
    final value = int.tryParse(wordCountController.text);

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir sayı girin'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('daily_word_count', value);

    setState(() {
      wordCount = value;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayarlar kaydedildi'),
      ),
    );
  }

  Future<void> resetProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İlerlemeyi Sıfırla'),
        content: const Text(
          'Tüm kelimelerin seviye, doğru/yanlış ve öğrenildi bilgileri sıfırlansın mı?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await WordStorageService.resetAllProgress();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm öğrenme ilerlemesi sıfırlandı'),
      ),
    );
  }

  @override
  void dispose() {
    wordCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.settings,
            size: 80,
            color: Colors.indigo,
          ),

          const SizedBox(height: 20),

          const Text(
            'Günlük Yeni Kelime Sayısı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: wordCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kelime Sayısı',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Ayarları Kaydet'),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Mevcut Ayar'),
              subtitle: Text(
                'Günlük yeni kelime sayısı: $wordCount',
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 10),

          const Text(
            'Sistem İşlemleri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: resetProgress,
              icon: const Icon(Icons.restart_alt, color: Colors.red),
              label: const Text('Tüm İlerlemeyi Sıfırla'),
            ),
          ),
        ],
      ),
    );
  }
}