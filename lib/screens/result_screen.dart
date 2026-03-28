import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'title_screen.dart';

class ResultScreen extends StatefulWidget {
  final File originalFile;
  final File savedFile;
  final String fileName;

  const ResultScreen({
    super.key,
    required this.originalFile,
    required this.savedFile,
    required this.fileName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _savedToGallery = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveToGallery());
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final result = await GallerySaver.saveImage(widget.savedFile.path);
      setState(() {
        _savedToGallery = result == true;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result == true ? 'ギャラリーに保存しました！' : 'ギャラリーへの保存に失敗しました',
            ),
            backgroundColor: result == true ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyFileName() {
    Clipboard.setData(ClipboardData(text: widget.fileName));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ファイル名をコピーしました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存完了'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'トップへ',
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TitleScreen()),
            (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 56,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ファイル名を生成しました',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Image preview（全体表示）
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.black,
                  child: Image.file(
                    widget.savedFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // File name display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00D4FF).withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ファイル名',
                      style: TextStyle(fontSize: 12, color: Color(0xFF00D4FF)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.fileName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00D4FF)),
                          tooltip: 'コピー',
                          onPressed: _copyFileName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save to gallery button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isSaving || _savedToGallery) ? null : _saveToGallery,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_savedToGallery ? Icons.check : Icons.photo_library),
                  label: Text(
                    _savedToGallery ? 'ギャラリーに保存済み' : 'ギャラリーに保存',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _savedToGallery ? Colors.grey : Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 次の写真を撮るボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    '次の写真を撮る',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D4FF),
                    side: const BorderSide(color: Color(0xFF00D4FF), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}