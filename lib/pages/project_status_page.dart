import 'package:flutter/material.dart';

class ProjectStatusPage extends StatelessWidget {
  const ProjectStatusPage({super.key});

  Widget statusCard({
    required String title,
    required bool completed,
    required String description,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.cancel,
          color: completed ? Colors.green : Colors.red,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          completed ? 'Evet' : 'Hayır',
          style: TextStyle(
            color: completed ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje Durumu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Color(0xFFE8EAF6),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 70,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Öğrenci Beyanı',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '6 Sefer Tekrar Prensibi İçeren Kelime Ezberleme Oyunu',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          sectionTitle('Ana Storyler'),

          statusCard(
            title: 'Kullanıcı Kayıt / Giriş / Şifremi Unuttum',
            completed: true,
            description:
            'SharedPreferences ile gömülü kullanıcı kaydı, giriş kontrolü ve şifre gösterme sistemi yapıldı.',
          ),

          statusCard(
            title: 'Kelime Ekleme Modülü',
            completed: true,
            description:
            'İngilizce kelime, Türkçe karşılığı, örnek cümleler ve resim linki eklenebiliyor.',
          ),

          statusCard(
            title: 'Sınav Modülü',
            completed: true,
            description:
            '4 şıklı quiz, doğru/yanlış kontrolü ve 6 sefer tekrar algoritması eklendi.',
          ),

          statusCard(
            title: 'Kelime Sıklığı Değiştirme',
            completed: true,
            description:
            'Ayarlar ekranından günlük yeni kelime sayısı değiştirilebiliyor.',
          ),

          statusCard(
            title: 'Analiz Raporu',
            completed: true,
            description:
            'Toplam kelime, öğrenilen kelime, başarı oranı ve PDF/yazdırma raporu oluşturulabiliyor.',
          ),

          sectionTitle('Ek Storyler'),

          statusCard(
            title: 'Wordle Bulmaca',
            completed: true,
            description:
            'Kayıtlı kelimelerden Wordle benzeri tahmin oyunu oluşturuldu.',
          ),

          statusCard(
            title: 'Word Chain / Hikaye',
            completed: true,
            description:
            'Kayıtlı kelimelerden kelime zinciri ve gömülü hikaye oluşturma sistemi yapıldı.',
          ),

          sectionTitle('Ek Özellikler'),

          statusCard(
            title: 'Kelime Listeleme',
            completed: true,
            description:
            'Kelime arama, detay görme, doğru/yanlış sayısı ve seviye bilgisi gösteriliyor.',
          ),

          statusCard(
            title: 'Kelime Düzenleme / Silme',
            completed: true,
            description:
            'Eklenen kelimeler sonradan düzenlenebiliyor veya silinebiliyor.',
          ),

          statusCard(
            title: 'Örnek Veri Yükleme',
            completed: true,
            description:
            'Demo ve video anlatımı için örnek kelimeler otomatik yüklenebiliyor.',
          ),

          statusCard(
            title: 'İlerleme Sıfırlama',
            completed: true,
            description:
            'Ayarlar ekranından tüm kelime öğrenme ilerlemesi sıfırlanabiliyor.',
          ),
        ],
      ),
    );
  }
}