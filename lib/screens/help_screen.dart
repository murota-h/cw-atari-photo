import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _total = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        title: const Text('使い方', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _Page1(),
                  _Page2(),
                  _Page3(),
                  _Page4(),
                  _Page5(),
                  _Page6(),
                ],
              ),
            ),

            // ドットインジケーター
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_total, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF00D4FF)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // 次へ／閉じるボタン
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == _total - 1
                        ? Colors.white24
                        : const Color(0xFF00D4FF),
                    foregroundColor: _currentPage == _total - 1
                        ? Colors.white
                        : const Color(0xFF0D1B2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentPage == _total - 1 ? '閉じる' : '次へ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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

// ─── 共通ウィジェット ───────────────────────────────

class _PageBase extends StatelessWidget {
  final IconData icon;
  final String step;
  final String title;
  final List<Widget> children;

  const _PageBase({
    required this.icon,
    required this.step,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコン＋ステップ＋タイトル
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00D4FF), width: 1.5),
                  color: const Color(0xFF00D4FF).withAlpha(20),
                ),
                child: Icon(icon, color: const Color(0xFF00D4FF), size: 26),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step,
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 11,
                        letterSpacing: 3,
                      )),
                  const SizedBox(height: 2),
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFF00D4FF).withAlpha(60)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

Widget _bullet(String text, {bool isNote = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isNote ? '※' : '・',
          style: TextStyle(
            color: isNote ? Colors.orange[300] : const Color(0xFF00D4FF),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isNote ? Colors.orange[200] : Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _codeBox(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF00D4FF).withAlpha(80)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontFamily: 'monospace',
        letterSpacing: 1,
      ),
    ),
  );
}

// ─── 各ページ ──────────────────────────────────────

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.info_outline,
      step: 'ABOUT',
      title: 'このアプリについて',
      children: [
        _bullet('CW当たり写真に正しいファイル名を付けて、ギャラリーに保存するためのツールです。'),
        _bullet('撮影からファイル名生成・保存まで、すべてスマートフォンで完結します。'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00D4FF).withAlpha(60)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('作業の流れ',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 12,
                    letterSpacing: 2,
                  )),
              SizedBox(height: 8),
              Text(
                '撮影  →  Ch.No入力  →  PIN選択  →  保存',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.camera_alt,
      step: 'STEP 1',
      title: '写真を撮る',
      children: [
        _bullet('「タップして撮影」→ その場でカメラが起動します。'),
        _bullet('「ギャラリーから選択」→ 撮影済みの写真を選べます。'),
      ],
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.tag,
      step: 'STEP 2',
      title: 'Ch.No を入力する',
      children: [
        const Text('Ch.No は 3パーツで構成されます：',
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 8),
        _codeBox('W [番号] - [アルファベット] - [末尾数字] R\n例： W50414-D-1R'),
        _bullet('番号：テンキーで入力（最大6桁）'),
        _bullet('アルファベット：A〜L から選択'),
        _bullet('末尾数字：1〜9 から選択'),
        _bullet('以前使った Ch.No は履歴から一発選択できます。'),
        _bullet('写真はピンチイン／ピンチアウトで拡大・縮小できます。'),
        const SizedBox(height: 4),
        _bullet('W以外の場合はPCにて変更をお願いします。', isNote: true),
      ],
    );
  }
}

class _Page4 extends StatelessWidget {
  const _Page4();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.push_pin,
      step: 'STEP 3',
      title: 'PIN を選択する',
      children: [
        _bullet('1P 〜 10P から該当するものをタップしてください。'),
      ],
    );
  }
}

class _Page5 extends StatelessWidget {
  const _Page5();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.save,
      step: 'STEP 4',
      title: '保存する',
      children: [
        _bullet('画面下の「保存」ボタンを押すとファイル名が自動生成されます。'),
        _bullet('写真はギャラリーに自動保存されます。'),
        const SizedBox(height: 8),
        const Text('生成されるファイル名の例：',
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 6),
        _codeBox('W50414-D-1R No3スロー'),
      ],
    );
  }
}

class _Page6 extends StatelessWidget {
  const _Page6();

  @override
  Widget build(BuildContext context) {
    return _PageBase(
      icon: Icons.check_circle_outline,
      step: 'STEP 5',
      title: '保存完了',
      children: [
        _bullet('生成されたファイル名を画面で確認できます。'),
        _bullet('ファイル名はコピーボタンでコピーできます。'),
        _bullet('「次の写真を撮る」で続けて作業できます。'),
        _bullet('「ギャラリーで確認」→ 端末のギャラリーで写真を確認できます。'),
      ],
    );
  }
}
