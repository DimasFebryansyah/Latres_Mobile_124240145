import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/favorites_page.dart';
import '../screens/profile_page.dart';
import '../screens/shows_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _selectedIndex = 0.obs;
  late final List<Widget> _pages = const [
    ShowsPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(index: _selectedIndex.value, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex.value,
          onDestinationSelected: (index) => _selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.movie_outlined),
              selectedIcon: Icon(Icons.movie),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
