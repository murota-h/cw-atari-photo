import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'input_screen.dart';
import 'title_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _shoot(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InputScreen(imageFile: File(photo.path)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TitleScreen()),
            (route) => false,
          ),
          child: const Icon(Icons.home, color: Colors.white38, size: 22),
        ),
        const SizedBox(width: 12),
        Container(
          width: 4, height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CWタグリネーマー',
                style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('FAST INPUT MODE',
                style: TextStyle(color: Color(0xFF00D4FF),
                    fontSize: 10, letterSpacing: 3)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
              )
            : isLandscape
                ? _buildLandscape(context)
                : _buildPortrait(context),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildHeader(context),
          const Spacer(),
          GestureDetector(
            onTap: () => _shoot(ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00D4FF), width: 2),
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF00D4FF).withAlpha(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Color(0xFF00D4FF)),
                  SizedBox(height: 12),
                  Text('タップして撮影',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('撮影後にすばやく入力できます',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _shoot(ImageSource.gallery),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, color: Colors.white38, size: 20),
                  SizedBox(width: 8),
                  Text('ギャラリーから選択',
                      style: TextStyle(color: Colors.white38, fontSize: 15)),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // 左：カメラ
                Expanded(
                  child: GestureDetector(
                    onTap: () => _shoot(ImageSource.camera),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00D4FF), width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF00D4FF).withAlpha(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Color(0xFF00D4FF)),
                          SizedBox(height: 10),
                          Text('タップして撮影',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 右：ギャラリー
                Expanded(
                  child: GestureDetector(
                    onTap: () => _shoot(ImageSource.gallery),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Colors.white54, size: 48),
                          SizedBox(height: 10),
                          Text('ギャラリーから選択',
                              style: TextStyle(color: Colors.white54,
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}