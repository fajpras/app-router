import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/stitch_generation.dart';

/// Klien untuk berkomunikasi dengan server MCP Google Stitch.
///
/// Stitch menghasilkan kode Flutter dari prompt teks atau gambar desain.
/// Konfigurasi MCP berada di `.opencode/config.json` dan API key dibaca
/// dari variabel lingkungan `STITCH_API_KEY` (lihat `.env.example`).
class StitchService {
  static const String _baseUrl = 'https://stitch.googleapis.com/mcp';

  final http.Client _client;
  final String? _apiKey;

  StitchService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('STITCH_API_KEY');

  /// Memuat API key dari file `.env` jika tersedia.
  factory StitchService.fromEnv({http.Client? client}) {
    final env = DotEnv()..load(['.env']);
    final apiKey = env['STITCH_API_KEY'];
    return StitchService(client: client, apiKey: apiKey);
  }

  /// Menghasilkan kode Flutter dari prompt teks melalui Stitch MCP.
  Future<StitchGeneration> generateFlutterCode({
    required String prompt,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StitchException(
        'API key Stitch tidak ditemukan. Isi STITCH_API_KEY di .env',
      );
    }

    final uri = Uri.parse('$_baseUrl/tools/generate_flutter_code');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'prompt': prompt,
      'output_format': 'flutter',
    });

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 400) {
        throw StitchException(
          'Stitch gagal merespons (${response.statusCode}): ${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return StitchGeneration.fromJson(json);
    } on StitchException {
      rethrow;
    } catch (e) {
      throw StitchException('Terjadi kesalahan saat memanggil Stitch: $e');
    }
  }

  /// Menutup klien HTTP.
  void dispose() {
    _client.close();
  }
}

/// Eksepsi khusus untuk kegagalan interaksi dengan Stitch.
class StitchException implements Exception {
  final String message;
  const StitchException(this.message);

  @override
  String toString() => 'StitchException: $message';
}
