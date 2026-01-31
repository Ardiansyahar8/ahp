import 'package:flutter/material.dart';
import '../models/app_config.dart';
import 'pairwise_comparison_screen.dart';

class CriteriaSetupScreen extends StatelessWidget {
  final AppConfig config;

  const CriteriaSetupScreen({super.key, required this.config});

  // Data untuk Pabrik Tepung Tapioka
  static const List<Map<String, String>> criteria = [
    {
      'name': 'Derajat Putih',
      'description': 'Kualitas output tepung tapioka yang dihasilkan',
      'icon': '⚪',
    },
    {
      'name': 'Pemakaian Air',
      'description': 'Efisiensi penggunaan air dalam proses produksi',
      'icon': '💧',
    },
    {
      'name': 'Limbah Padat',
      'description': 'Pengelolaan limbah hasil produksi',
      'icon': '♻️',
    },
    {
      'name': 'Biaya Perbaikan',
      'description': 'Cost effectiveness maintenance mesin',
      'icon': '💰',
    },
  ];

  static const List<Map<String, String>> alternatives = [
    {
      'name': 'Mesin Pencuci Singkong',
      'description': 'Washing machine untuk membersihkan singkong',
      'icon': '🚿',
    },
    {
      'name': 'Mesin Parut/Rasper',
      'description': 'Grating machine untuk memarut singkong',
      'icon': '⚙️',
    },
    {
      'name': 'Mesin Ekstraksi Pati',
      'description': 'Starch extraction untuk ekstraksi pati',
      'icon': '🔬',
    },
    {
      'name': 'Mesin Centrifuge',
      'description': 'Dewatering machine untuk mengurangi kadar air',
      'icon': '🌀',
    },
    {
      'name': 'Mesin Flash Dryer',
      'description': 'Drying machine untuk pengeringan tepung',
      'icon': '🔥',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Kriteria & Alternatif'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.factory,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.projectName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Developer: ${config.developer}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sistem Decision Support untuk menentukan prioritas maintenance mesin menggunakan metode AHP (Analytical Hierarchy Process).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kriteria Penilaian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...criteria.map((c) => _buildCriteriaCard(context, c)),
            const SizedBox(height: 24),
            const Text(
              'Alternatif Mesin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...alternatives.map((a) => _buildAlternativeCard(context, a)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PairwiseComparisonScreen(
                        config: config,
                        criteriaNames: criteria.map((c) => c['name']!).toList(),
                        alternativeNames: alternatives.map((a) => a['name']!).toList(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Mulai Perbandingan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaCard(BuildContext context, Map<String, String> criteria) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          criteria['icon']!,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          criteria['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(criteria['description']!),
      ),
    );
  }

  Widget _buildAlternativeCard(BuildContext context, Map<String, String> alternative) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          alternative['icon']!,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          alternative['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(alternative['description']!),
      ),
    );
  }
}
