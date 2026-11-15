import 'package:flutter/material.dart';

import '../models/stitch_generation.dart';
import '../services/stitch_service.dart';

/// Layar contoh yang menampilkan hasil generate UI dari Google Stitch.
///
/// Pada prakteknya, kode Flutter yang dihasilkan Stitch dapat ditempatkan
/// langsung di dalam method `build` (misalnya sebagai widget custom).
class StitchGeneratedScreen extends StatefulWidget {
  final StitchGeneration generation;

  const StitchGeneratedScreen({super.key, required this.generation});

  @override
  State<StitchGeneratedScreen> createState() => _StitchGeneratedScreenState();
}

class _StitchGeneratedScreenState extends State<StitchGeneratedScreen> {
  bool _isGenerating = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final service = StitchService.fromEnv();
      final generation = await service.generateFlutterCode(
        prompt: widget.generation.prompt,
      );
      if (mounted) {
        setState(() {
          _isGenerating = false;
          // Tampilkan hasil terbaru (di sini hanya kode, UI render tetap contoh)
        });
        // ignore: avoid_print
        print('Stitch code:\n${generation.flutterCode}');
      }
      service.dispose();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Generate Stitch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Prompt:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.generation.prompt),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Menggenerate...' : 'Generate Ulang'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kode Flutter (contoh):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.generation.flutterCode.isNotEmpty
                        ? widget.generation.flutterCode
                        : 'Belum ada kode. Tekan tombol generate.',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
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
}
