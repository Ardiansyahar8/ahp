import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_config.dart';
import '../models/ahp_result.dart';

class ResultScreen extends StatelessWidget {
  final AppConfig config;
  final AHPResult result;
  final List<String> criteriaNames;
  final List<String> alternativeNames;

  const ResultScreen({
    super.key,
    required this.config,
    required this.result,
    required this.criteriaNames,
    required this.alternativeNames,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis AHP'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConsistencyCard(context),
            const SizedBox(height: 16),
            _buildRankingCard(context),
            const SizedBox(height: 16),
            _buildChartCard(context),
            const SizedBox(height: 16),
            _buildCriteriaWeightsCard(context),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Beranda'),
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

  Widget _buildConsistencyCard(BuildContext context) {
    final cr = result.criteriaCr ?? 0;
    final isConsistent = cr < 0.1;

    return Card(
      color: isConsistent ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConsistent ? Icons.check_circle : Icons.warning,
                  color: isConsistent ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConsistent ? 'Konsisten ✓' : 'Tidak Konsisten ✗',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isConsistent ? Colors.green[900] : Colors.red[900],
                        ),
                      ),
                      Text(
                        'Consistency Ratio: ${cr.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 14,
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
              isConsistent
                  ? 'Perbandingan Anda konsisten secara matematis. Hasil dapat dipercaya.'
                  : 'Perbandingan Anda tidak konsisten. CR harus < 0.1. Silakan ulangi perbandingan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Ranking Prioritas Maintenance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(result.ranking!.length, (index) {
              final machineIndex = result.ranking![index];
              final machineName = alternativeNames[machineIndex];
              final score = result.globalScores![machineIndex];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.amber[100]
                      : index == 1
                          ? Colors.grey[200]
                          : index == 2
                              ? Colors.orange[100]
                              : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0 ? Colors.amber : Colors.grey[300]!,
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.amber
                            : index == 1
                                ? Colors.grey[400]
                                : index == 2
                                    ? Colors.orange
                                    : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machineName,
                            style: TextStyle(
                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Skor: ${(score * 100).toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index == 0)
                      const Icon(
                        Icons.priority_high,
                        color: Colors.amber,
                        size: 32,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Visualisasi Skor Global',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (result.globalScores!.reduce((a, b) => a > b ? a : b) * 1.2),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${alternativeNames[group.x.toInt()]}\n${(rod.toY * 100).toStringAsFixed(2)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < alternativeNames.length) {
                            final name = alternativeNames[value.toInt()];
                            final words = name.split(' ');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                words.length > 2 ? '${words[0]}\n${words[1]}' : name,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 50,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    result.globalScores!.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: result.globalScores![index],
                          color: _getBarColor(index),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    final rankIndex = result.ranking!.indexOf(index);
    if (rankIndex == 0) return Colors.amber;
    if (rankIndex == 1) return Colors.grey;
    if (rankIndex == 2) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildCriteriaWeightsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚖️ Bobot Kriteria',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(criteriaNames.length, (index) {
              final weight = result.criteriaWeights![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          criteriaNames[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${(weight * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: weight,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
