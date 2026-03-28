import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  final File imageFile;
  const InputScreen({super.key, required this.imageFile});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String _chNoNumber = '';
  String _chNoAlpha  = '';
  String _chNoDigit  = '';
  String _pin    = '';
  static const _suffix = 'スロー';
  List<String> _history = [];

  String get _chNoFull {
    if (_chNoNumber.isEmpty) return '';
    if (_chNoAlpha.isEmpty) return 'W$_chNoNumber';
    if (_chNoDigit.isEmpty) return 'W$_chNoNumber-$_chNoAlpha';
    return 'W$_chNoNumber-$_chNoAlpha-${_chNoDigit}R';
  }

  String get _pinNum => _pin.replaceAll(RegExp(r'[^0-9]'), '');

  String get _previewFileName {
    if (_chNoFull.isEmpty && _pin.isEmpty) return '—';
    final chPart = _chNoFull.isEmpty ? '?' : _chNoFull;
    final pinPart = _pin.isEmpty ? '?' : _pinNum;
    return '$chPart No$pinPart$_suffix';
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chno_history') ?? '[]';
    setState(() => _history = List<String>.from(jsonDecode(raw)));
  }

  Future<void> _saveHistory(String chNo) async {
    final prefs = await SharedPreferences.getInstance();
    _history.remove(chNo);
    _history.insert(0, chNo);
    if (_history.length > 8) _history = _history.sublist(0, 8);
    await prefs.setString('chno_history', jsonEncode(_history));
  }

  void _setFromHistory(String chNo) {
    final match = RegExp(r'^W([0-9]+)-([A-Za-z]+)-([0-9]+)R$').firstMatch(chNo);
    if (match != null) {
      setState(() {
        _chNoNumber = match.group(1)!;
        _chNoAlpha  = match.group(2)!.toUpperCase();
        _chNoDigit  = match.group(3)!;
      });
    }
  }

  Future<void> _save() async {
    if (_chNoFull.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ch.No を入力してください'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN を選択してください'), backgroundColor: Colors.orange),
      );
      return;
    }
    final fileName = '$_chNoFull No$_pinNum$_suffix';
    final newPath = p.join(widget.imageFile.parent.path, '$fileName.jpg');
    try {
      await _saveHistory(_chNoFull);
      final newFile = await widget.imageFile.copy(newPath);
      await widget.imageFile.delete();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            originalFile: widget.imageFile,
            savedFile: newFile,
            fileName: fileName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存エラー: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        title: const Text('入力', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: isLandscape ? _buildLandscape() : _buildPortrait(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF0D1B2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('保存',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
        ),
      ),
    );
  }

  // ── 縦向きレイアウト ──────────────────────────
  Widget _buildPortrait() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // 写真（ピンチで拡大）
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.black,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 8.0,
              child: Image.file(widget.imageFile, fit: BoxFit.contain,
                  width: double.infinity),
            ),
          ),
          const SizedBox(height: 12),
          _buildInputArea(compact: false),
        ],
      ),
    );
  }

  // ── 横向きレイアウト ──────────────────────────
  Widget _buildLandscape() {
    return Row(
      children: [
        // 左：写真（ピンチ拡大）
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Container(
            color: Colors.black,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 8.0,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        // 右：縦向きと同じ入力エリア（スクロール）
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: _buildInputArea(compact: true),
          ),
        ),
      ],
    );
  }

  // ── 入力エリア本体 ────────────────────────────
  Widget _buildInputArea({required bool compact}) {
    final sp = compact ? 6.0 : 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ch.No'),
        const SizedBox(height: 4),

        // ディスプレイ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00D4FF).withAlpha(150)),
          ),
          child: Row(children: [
            _fixedLabel('W'),
            _partDisplay(_chNoNumber, '50414'),
            _fixedLabel('-'),
            _partDisplay(_chNoAlpha, 'D'),
            _fixedLabel('-'),
            _partDisplay(_chNoDigit, '1'),
            _fixedLabel('R'),
          ]),
        ),
        SizedBox(height: sp),

        // 数字テンキー
        _sectionSubLabel('番号'),
        const SizedBox(height: 3),
        _numericKeypad(compact: compact),
        SizedBox(height: sp),

        // アルファベット
        _sectionSubLabel('アルファベット'),
        const SizedBox(height: 3),
        _alphaKeypad(compact: compact),
        SizedBox(height: sp),

        // 末尾数字
        _sectionSubLabel('末尾数字（-○R）'),
        const SizedBox(height: 3),
        _digitRow(compact: compact),

        // 履歴
        if (_history.isNotEmpty) ...[
          SizedBox(height: sp),
          _sectionSubLabel('履歴'),
          const SizedBox(height: 3),
          Wrap(
            spacing: 6, runSpacing: 5,
            children: _history.map((h) => GestureDetector(
              onTap: () => _setFromHistory(h),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(h, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            )).toList(),
          ),
        ],

        SizedBox(height: compact ? 8 : 12),
        const Divider(color: Colors.white12),
        SizedBox(height: compact ? 6 : 8),

        // PIN
        _sectionLabel('PIN'),
        const SizedBox(height: 4),
        _pinGrid(compact: compact),
        SizedBox(height: compact ? 8 : 10),

        // プレビュー
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ファイル名', style: TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 3),
              Text(_previewFileName,
                style: const TextStyle(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.bold, fontFamily: 'monospace',
                )),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── ウィジェット部品 ───────────────────────────

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 12, letterSpacing: 1));

  Widget _sectionSubLabel(String t) => Text(t,
    style: const TextStyle(color: Colors.white38, fontSize: 10));

  Widget _fixedLabel(String t) => Text(t,
    style: const TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.bold));

  Widget _partDisplay(String value, String hint) => Expanded(
    child: Center(
      child: Text(
        value.isEmpty ? hint : value,
        style: TextStyle(
          color: value.isEmpty ? Colors.white24 : Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace',
        ),
      ),
    ),
  );

  Widget _numericKeypad({required bool compact}) {
    final keys = ['1','2','3','4','5','6','7','8','9','0','⌫'];
    final h = compact ? 1.5 : 1.4;
    return GridView.count(
      crossAxisCount: 6, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: h,
      children: keys.map((k) => _keyButton(
        label: k,
        onTap: () => setState(() {
          if (k == '⌫') {
            if (_chNoNumber.isNotEmpty)
              _chNoNumber = _chNoNumber.substring(0, _chNoNumber.length - 1);
          } else if (_chNoNumber.length < 6) {
            _chNoNumber += k;
          }
        }),
        isDelete: k == '⌫',
      )).toList(),
    );
  }

  Widget _alphaKeypad({required bool compact}) {
    final alphas = ['A','B','C','D','E','F','G','H','I','J','K','L'];
    return GridView.count(
      crossAxisCount: 6, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5, crossAxisSpacing: 5,
      childAspectRatio: compact ? 1.5 : 1.2,
      children: alphas.map((a) {
        final sel = _chNoAlpha == a;
        return GestureDetector(
          onTap: () => setState(() => _chNoAlpha = a),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF00D4FF) : Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: sel ? const Color(0xFF00D4FF) : Colors.white24),
            ),
            child: Center(child: Text(a, style: TextStyle(
              color: sel ? const Color(0xFF0D1B2A) : Colors.white70,
              fontWeight: FontWeight.bold, fontSize: compact ? 13 : 14,
            ))),
          ),
        );
      }).toList(),
    );
  }

  Widget _digitRow({required bool compact}) {
    return Row(
      children: List.generate(9, (i) {
        final d = '${i + 1}';
        final sel = _chNoDigit == d;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => setState(() => _chNoDigit = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: compact ? 32 : 38,
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF00D4FF) : Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: sel ? const Color(0xFF00D4FF) : Colors.white24),
                ),
                child: Center(child: Text(d, style: TextStyle(
                  color: sel ? const Color(0xFF0D1B2A) : Colors.white70,
                  fontWeight: FontWeight.bold, fontSize: compact ? 12 : 14,
                ))),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _pinGrid({required bool compact}) {
    return GridView.count(
      crossAxisCount: 5, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6, crossAxisSpacing: 6,
      childAspectRatio: compact ? 1.6 : 1.2,
      children: List.generate(10, (i) {
        final val = '${i + 1}P';
        final sel = _pin == val;
        return GestureDetector(
          onTap: () => setState(() => _pin = val),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF00D4FF) : Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? const Color(0xFF00D4FF) : Colors.white24),
            ),
            child: Center(child: Text(val, style: TextStyle(
              color: sel ? const Color(0xFF0D1B2A) : Colors.white70,
              fontWeight: FontWeight.bold, fontSize: compact ? 13 : 14,
            ))),
          ),
        );
      }),
    );
  }

  Widget _keyButton({required String label, required VoidCallback onTap, bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDelete ? Colors.red.withAlpha(50) : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: isDelete ? Colors.red.withAlpha(100) : Colors.white24),
        ),
        child: Center(child: Text(label, style: TextStyle(
          color: isDelete ? Colors.red[300] : Colors.white,
          fontWeight: FontWeight.bold, fontSize: 15,
        ))),
      ),
    );
  }
}

// ── 写真フルスクリーン拡大 ─────────────────────
class _FullImageScreen extends StatelessWidget {
  final File imageFile;
  const _FullImageScreen(this.imageFile);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('写真を確認', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 8.0,
          child: Image.file(imageFile, fit: BoxFit.contain),
        ),
      ),
    );
  }
}