import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/ahp_service.dart';
import 'result_screen.dart';

class PairwiseComparisonScreen extends StatefulWidget {
  final AppConfig config;
  final List<String> criteriaNames;
  final List<String> alternativeNames;

  const PairwiseComparisonScreen({
    super.key,
    required this.config,
    required this.criteriaNames,
    required this.alternativeNames,
  });

  @override
  State<PairwiseComparisonScreen> createState() => _PairwiseComparisonScreenState();
}

class _PairwiseComparisonScreenState extends State<PairwiseComparisonScreen> {
  int _currentStep = 0;
  bool _isCalculating = false;

  // Matriks perbandingan kriteria
  late List<List<double>> _criteriaMatrix;

  // Matriks perbandingan alternatif untuk setiap kriteria
  late List<List<List<double>>> _alternativesMatrices;

  @override
  void initState() {
    super.initState();
    _initializeMatrices();
  }

  void _initializeMatrices() {
    final criteriaCount = widget.criteriaNames.length;
    final alternativeCount = widget.alternativeNames.length;

    // Inisialisasi matriks kriteria dengan nilai 1 (diagonal)
    _criteriaMatrix = List.generate(
      criteriaCount,
      (i) => List.generate(
        criteriaCount,
        (j) => i == j ? 1.0 : 1.0,
      ),
    );

    // Inisialisasi matriks alternatif untuk setiap kriteria
    _alternativesMatrices = List.generate(
      criteriaCount,
      (_) => List.generate(
        alternativeCount,
        (i) => List.generate(
          alternativeCount,
          (j) => i == j ? 1.0 : 1.0,
        ),
      ),
    );
  }

  void _updateCriteriaComparison(int i, int j, double value) {
    setState(() {
      _criteriaMatrix[i][j] = value;
      _criteriaMatrix[j][i] = 1.0 / value;
    });
  }

  void _updateAlternativeComparison(int criteriaIndex, int i, int j, double value) {
    setState(() {
      _alternativesMatrices[criteriaIndex][i][j] = value;
      _alternativesMatrices[criteriaIndex][j][i] = 1.0 / value;
    });
  }

  Future<void> _calculate() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      final ahpService = AHPService(widget.config.baseUrl);

      final result = await ahpService.calculate(
        criteriaNames: widget.criteriaNames,
        alternativeNames: widget.alternativeNames,
        criteriaMatrix: _criteriaMatrix,
        alternativesMatrices: _alternativesMatrices,
      );

      if (mounted) {
        if (result.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                config: widget.config,
                result: result,
                criteriaNames: widget.criteriaNames,
                alternativeNames: widget.alternativeNames,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? result.error ?? 'Terjadi kesalahan'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = 1 + widget.criteriaNames.length; // 1 untuk kriteria + N untuk alternatif

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbandingan Berpasangan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Langkah ${_currentStep + 1} dari $totalSteps',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildCurrentStep(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 0) {
      return _buildCriteriaComparison();
    } else {
      final criteriaIndex = _currentStep - 1;
      return _buildAlternativeComparison(criteriaIndex);
    }
  }

  Widget _buildCriteriaComparison() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perbandingan Kriteria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bandingkan setiap pasangan kriteria. Geser slider untuk menentukan mana yang lebih penting.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildComparisonPairs(
            widget.criteriaNames,
            (i, j, value) => _updateCriteriaComparison(i, j, value),
            _criteriaMatrix,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeComparison(int criteriaIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perbandingan Mesin',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berdasarkan kriteria: ${widget.criteriaNames[criteriaIndex]}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bandingkan setiap pasangan mesin berdasarkan kriteria ini.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildComparisonPairs(
            widget.alternativeNames,
            (i, j, value) => _updateAlternativeComparison(criteriaIndex, i, j, value),
            _alternativesMatrices[criteriaIndex],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildComparisonPairs(
    List<String> items,
    Function(int, int, double) onUpdate,
    List<List<double>> matrix,
  ) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        widgets.add(
          _buildComparisonSlider(
            items[i],
            items[j],
            matrix[i][j],
            (value) => onUpdate(i, j, value),
          ),
        );
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildComparisonSlider(
    String item1,
    String item2,
    double currentValue,
    Function(double) onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item1,
                    style: TextStyle(
                      fontWeight: currentValue > 1 ? FontWeight.bold : FontWeight.normal,
                      color: currentValue > 1 ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ),
                const Text(' vs '),
                Expanded(
                  child: Text(
                    item2,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: currentValue < 1 ? FontWeight.bold : FontWeight.normal,
                      color: currentValue < 1 ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _valueToSlider(currentValue),
              min: 0,
              max: 16,
              divisions: 16,
              label: _getLabel(currentValue),
              onChanged: (value) {
                onChanged(_sliderToValue(value));
              },
            ),
            Text(
              _getDescription(currentValue, item1, item2),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _valueToSlider(double value) {
    // Mapping: 1/9 -> 0, 1/7 -> 1, ..., 1 -> 8, ..., 9 -> 16
    if (value >= 1) {
      return 8 + (value - 1);
    } else {
      return 8 - (1 / value - 1);
    }
  }

  double _sliderToValue(double slider) {
    // Reverse mapping
    if (slider >= 8) {
      return 1 + (slider - 8);
    } else {
      return 1 / (1 + (8 - slider));
    }
  }

  String _getLabel(double value) {
    if (value == 1) return '1 (Sama)';
    if (value > 1) {
      return value.toStringAsFixed(0);
    } else {
      return '1/${(1 / value).toStringAsFixed(0)}';
    }
  }

  String _getDescription(double value, String item1, String item2) {
    if (value == 1) {
      return 'Sama penting';
    } else if (value > 1) {
      String importance = '';
      if (value <= 2) importance = 'Sedikit lebih penting';
      else if (value <= 4) importance = 'Lebih penting';
      else if (value <= 6) importance = 'Jauh lebih penting';
      else if (value <= 8) importance = 'Sangat jauh lebih penting';
      else importance = 'Mutlak lebih penting';
      return '$item1 $importance dari $item2';
    } else {
      double inverse = 1 / value;
      String importance = '';
      if (inverse <= 2) importance = 'Sedikit lebih penting';
      else if (inverse <= 4) importance = 'Lebih penting';
      else if (inverse <= 6) importance = 'Jauh lebih penting';
      else if (inverse <= 8) importance = 'Sangat jauh lebih penting';
      else importance = 'Mutlak lebih penting';
      return '$item2 $importance dari $item1';
    }
  }

  Widget _buildNavigationButtons() {
    final totalSteps = 1 + widget.criteriaNames.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isCalculating
                    ? null
                    : () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Sebelumnya'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isCalculating
                  ? null
                  : () {
                      if (_currentStep < totalSteps - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _calculate();
                      }
                    },
              icon: _isCalculating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_currentStep < totalSteps - 1 ? Icons.arrow_forward : Icons.calculate),
              label: Text(
                _isCalculating
                    ? 'Menghitung...'
                    : _currentStep < totalSteps - 1
                        ? 'Selanjutnya'
                        : 'Hitung Hasil',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
