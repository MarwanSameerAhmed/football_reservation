import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_nav_bar.dart';
import '../../../matches/presentation/pages/home_page.dart';
import '../../../matches/presentation/pages/matches_page.dart';
import '../../../players/presentation/pages/players_list_page.dart';

/// Global Persistent Navigation Shell ensuring the signature capsule bottom bar
/// stays permanently visible across all main tabs without disappearing.
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    MatchesPage(),
    PlayersListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: KickoffBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          NavItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
          NavItemData(icon: Icons.sports_soccer_rounded, label: 'المباريات'),
          NavItemData(icon: Icons.groups_rounded, label: 'المجموعة'),
        ],
      ),
    );
  }
}
