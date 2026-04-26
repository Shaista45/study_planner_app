import 'package:flutter/material.dart';
import 'package:smart_study_planner/screens/add_task_screen.dart';
import 'package:smart_study_planner/screens/dashboard_screen.dart';
import 'package:smart_study_planner/screens/settings_screen.dart';
import 'package:smart_study_planner/screens/study_progress_screen.dart';
import 'package:smart_study_planner/widgets/soft_bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List<GlobalKey<NavigatorState>>.generate(
        4,
        (_) => GlobalKey<NavigatorState>(),
      );
  final List<ScrollController> _scrollControllers =
      List<ScrollController>.generate(4, (_) => ScrollController());
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabs = <Widget>[
      DashboardScreen(scrollController: _scrollControllers[0]),
      AddTaskScreen(scrollController: _scrollControllers[1]),
      StudyProgressScreen(scrollController: _scrollControllers[2]),
      SettingsScreen(scrollController: _scrollControllers[3]),
    ];
  }

  @override
  void dispose() {
    for (final ScrollController controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final NavigatorState currentNavigator =
            _navigatorKeys[_currentIndex].currentState!;
        if (currentNavigator.canPop()) {
          currentNavigator.pop();
          return;
        }

        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: Stack(
          children: List<Widget>.generate(_tabs.length, (int index) {
            return Offstage(
              offstage: _currentIndex != index,
              child: Navigator(
                key: _navigatorKeys[index],
                onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute<void>(
                    builder: (_) => _tabs[index],
                    settings: const RouteSettings(name: 'root'),
                  );
                },
              ),
            );
          }),
        ),
        bottomNavigationBar: SoftBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            if (index == _currentIndex) {
              _navigatorKeys[index].currentState?.popUntil(
                (Route<dynamic> route) => route.isFirst,
              );
              _scrollTabToTop(index);
              return;
            }

            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  void _scrollTabToTop(int index) {
    final ScrollController controller = _scrollControllers[index];
    if (!controller.hasClients) {
      return;
    }

    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
