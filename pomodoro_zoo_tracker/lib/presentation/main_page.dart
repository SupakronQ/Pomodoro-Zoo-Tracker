import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_zoo_tracker/core/widgets/zoo_header.dart';
// Import Widget Bottom Nav ของคุณ
import '../core/widgets/zoo_bottom_nav.dart';
// Import หน้าต่างๆ
import '../../features/timer/presentation/pages/timer_page.dart';
import '../../features/category/presentation/pages/category_management_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/coin/presentation/providers/coin_provider.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  final String? categoryTitleToEdit;

  const MainPage({
    super.key,
    this.initialIndex = 0,
    this.categoryTitleToEdit,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _pages = [
      const TimerPage(),
      CategoryManagementPage(categoryTitleToEdit: widget.categoryTitleToEdit),
      const StatsPage(),
      const Center(child: Text("ZOO PAGE")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1),
        child: Consumer<CoinProvider>(
          builder: (context, coinProvider, child) {
            return ZooHeader(
              title: "Zoo Tracker",
              coins: coinProvider.balance,
              onCoinTap: () => print("Coin clicked!"),
            );
          },
        ),
      ),
      // 2. ใช้ IndexedStack เพื่อรักษา State ของแต่ละหน้า (เช่น Timer จะไม่หยุดเดิน)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // 3. เรียกใช้ ZooBottomNav ที่คุณเขียนไว้
      bottomNavigationBar: ZooBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          // ฟังก์ชันที่ส่งเข้าไปเพื่อเปลี่ยนหน้า
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
