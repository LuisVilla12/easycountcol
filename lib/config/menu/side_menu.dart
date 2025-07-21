import 'package:easycoutcol/config/menu/menu_items.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasNotch = MediaQuery.of(context).viewPadding.top > 25;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );
    // Saber el usuario con riverpod
    final username = ref.watch(usernameProvider);
    final name = ref.watch(nameProvider);
    final lastName = ref
        .watch(lastnameProvider); // final idUser = ref.watch(idUserProvider);

    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      indicatorColor: colors.primary,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;
        });
        final menuItem = appMenuItems[value];
        Future.delayed(const Duration(milliseconds: 150), () {
          context.push(menuItem.link);
        });
        widget.scaffoldKey.currentState?.closeDrawer();
      },
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 10 : 40, 10, 10),
          child: Text('Bienvenido  $name $lastName ', style: titleStyle),
        ),
        const SizedBox(height: 20),
        ...appMenuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return NavigationDrawerDestination(
            icon: Icon(
              item.icon,
              color: navDrawerIndex == index ? Colors.white : colors.primary,
            ),
            label: Text(
              item.title,
              style: TextStyle(
                color: navDrawerIndex == index ? Colors.white : colors.primary,
              ),
            ),
          );
        }),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Divider(),
        ),
      ],
    );
  }
}
