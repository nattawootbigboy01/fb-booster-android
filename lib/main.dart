import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FbBoosterApp());

const navy = Color(0xFF101525), panel = Color(0xFF1B2740), blue = Color(0xFF4778FF), muted = Color(0xFFAAB7D0);

class FbBoosterApp extends StatelessWidget {
  const FbBoosterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FB BOOSTER', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: navy,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark), useMaterial3: true),
    home: const AppHome(),
  );
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});
  @override State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  int tab = 0;
  bool loading = true;
  final List<String> drafts = [];
  final List<String> audiences = [];
  final List<String> queue = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      drafts.addAll(p.getStringList('drafts') ?? []);
      audiences.addAll(p.getStringList('audiences') ?? []);
      queue.addAll(p.getStringList('queue') ?? []);
      loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('drafts', drafts);
    await p.setStringList('audiences', audiences);
    await p.setStringList('queue', queue);
  }

  Future<String?> _ask(String title, String hint) async {
    final c = TextEditingController();
    return showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: TextField(controller: c, autofocus: true, maxLines: 3,
        decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('บันทึก'))],
    ));
  }

  Future<void> _add(List<String> target, String title, String hint) async {
    final value = await _ask(title, hint);
    if (value == null || value.isEmpty) return;
    setState(() => target.insert(0, value));
    await _save();
  }

  Future<void> _remove(List<String> target, int i) async {
    setState(() => target.removeAt(i));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(), _listPage('คอนเทนต์', 'ไอเดียและข้อความโพสต์ที่บันทึกไว้', drafts,
        () => _add(drafts, 'สร้างคอนเทนต์', 'พิมพ์ไอเดียหรือข้อความโพสต์'), Icons.edit_note),
      _listPage('กลุ่มเป้าหมาย', 'บันทึกชื่อกลุ่มและชุมชนที่เกี่ยวข้อง', audiences,
        () => _add(audiences, 'เพิ่มกลุ่มเป้าหมาย', 'ชื่อกลุ่มหรือ URL'), Icons.groups),
      _listPage('คิวโพสต์', 'รายการที่เตรียมไว้รอตรวจสอบและโพสต์เอง', queue,
        () => _add(queue, 'เพิ่มรายการในคิว', 'ข้อความหรือหัวข้อโพสต์'), Icons.schedule),
      _settings(),
    ];
    return Scaffold(
      body: SafeArea(child: loading ? const Center(child: CircularProgressIndicator()) : pages[tab]),
      floatingActionButton: tab > 0 && tab < 4 ? FloatingActionButton(
        onPressed: () => _add([drafts, audiences, queue][tab - 1],
          ['สร้างคอนเทนต์', 'เพิ่มกลุ่มเป้าหมาย', 'เพิ่มรายการในคิว'][tab - 1],
          ['พิมพ์ไอเดียหรือข้อความโพสต์', 'ชื่อกลุ่มหรือ URL', 'ข้อความหรือหัวข้อโพสต์'][tab - 1]),
        child: const Icon(Icons.add)) : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF151E31), selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'หน้าหลัก'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'คอนเทนต์'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'กลุ่มเป้าหมาย'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'คิวโพสต์'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'ตั้งค่า'),
        ]),
    );
  }

  Widget _header(String subtitle) => Row(children: [
    Container(width: 46, height: 46, decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(colors: [Color(0xFF397BFF), Color(0xFF8657F5)])),
      child: const Icon(Icons.trending_up, color: Colors.white)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FB BOOSTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
    ])),
  ]);

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(20), children: [
    _header('GROW YOUR AUDIENCE'), const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(colors: [Color(0xFF244A9D), Color(0xFF533D9D)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('FB BOOSTER ส่วนตัว', style: TextStyle(color: Color(0xFFD9E4FF))),
        const Text('เริ่มต้นสร้างฐานผู้ชม', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        const Text('สถิติ Facebook จะแสดงเมื่อเชื่อมต่อ Meta API ได้รับอนุญาตแล้ว',
          style: TextStyle(color: Color(0xFFD9E4FF))),
      ])),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _stat('คอนเทนต์', drafts.length)),
      const SizedBox(width: 10), Expanded(child: _stat('กลุ่มที่บันทึก', audiences.length)),
      const SizedBox(width: 10), Expanded(child: _stat('คิวโพสต์', queue.length)),
    ]),
    const SizedBox(height: 22),
    const Text('เครื่องมือของคุณ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const _Info(icon: Icons.auto_awesome, title: 'วางแผนคอนเทนต์',
      detail: 'บันทึกไอเดียและข้อความโพสต์ไว้ในเครื่อง'),
    const _Info(icon: Icons.groups, title: 'จัดการกลุ่มเป้าหมาย',
      detail: 'บันทึกกลุ่มที่เกี่ยวข้องและตรวจสอบกฎก่อนโพสต์'),
    const _Info(icon: Icons.shield, title: 'ความปลอดภัย',
      detail: 'ไม่เก็บรหัสผ่าน Facebook และไม่มีบอตเพิ่มผู้ติดตาม'),
  ]);

  Widget _stat(String label, int value) => Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 11)),
    ]));

  Widget _listPage(String title, String subtitle, List<String> data, VoidCallback add, IconData icon) =>
    ListView(padding: const EdgeInsets.all(20), children: [
      _header('FB BOOSTER PERSONAL'), const SizedBox(height: 26),
      Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      Text(subtitle, style: const TextStyle(color: muted)), const SizedBox(height: 18),
      if (data.isEmpty) const _Info(icon: Icons.inbox, title: 'ยังไม่มีรายการ',
        detail: 'กดปุ่ม + เพื่อเพิ่มรายการแรกของคุณ'),
      ...List.generate(data.length, (i) => Card(color: panel, child: ListTile(
        leading: Icon(icon, color: const Color(0xFF91AEFF)),
        title: Text(data[i]), trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _remove(data, i)),
      ))),
      if (title == 'คิวโพสต์') const _Info(icon: Icons.info_outline, title: 'การเผยแพร่',
        detail: 'รายการในคิวเป็นเพียงตัวช่วยเตือน ยังไม่มีการส่งโพสต์ไป Facebook อัตโนมัติ'),
    ]);

  Widget _settings() => ListView(padding: const EdgeInsets.all(20), children: [
    _header('FB BOOSTER PERSONAL'), const SizedBox(height: 26),
    const Text('ตั้งค่า', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
    const _Info(icon: Icons.person, title: 'โหมดส่วนตัว', detail: 'ไม่มีสมัครสมาชิกและไม่มีล็อกอินเข้าแอป'),
    const _Info(icon: Icons.facebook, title: 'เชื่อมต่อ Facebook', detail: 'ยังไม่เชื่อมต่อ ต้องตั้งค่า Meta App ID, OAuth และสิทธิ์ API ก่อน'),
    const _Info(icon: Icons.storage, title: 'ข้อมูลในเครื่อง', detail: 'บันทึกคอนเทนต์ กลุ่มเป้าหมาย และคิวโพสต์ด้วยพื้นที่จัดเก็บในเครื่อง'),
    const _Info(icon: Icons.lock, title: 'ความปลอดภัย', detail: 'ไม่ขอหรือจัดเก็บรหัสผ่าน Facebook'),
    const _Info(icon: Icons.info, title: 'เวอร์ชัน', detail: 'FB BOOSTER 0.2.0 - Personal prototype'),
  ]);
}

class _Info extends StatelessWidget {
  final IconData icon; final String title, detail;
  const _Info({required this.icon, required this.title, required this.detail});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF91AEFF)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4), Text(detail, style: const TextStyle(color: muted, fontSize: 12)),
      ])),
    ]));
}
