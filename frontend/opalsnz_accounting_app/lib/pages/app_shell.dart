import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import 'dashboard_page.dart';
import 'income_list_page.dart';
import 'home_office_expenses_page.dart';
import 'business_purchases_page.dart';
import 'assets_page.dart';
import 'trading_stock_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';

// Shared shell with side navigation - each destination is one BLoC-backed page.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard', page: DashboardPage()),
    (icon: Icons.attach_money, label: 'Income', page: IncomeListPage()),
    (
      icon: Icons.home_work_outlined,
      label: 'Home Office Expenses',
      page: HomeOfficeExpensesPage(),
    ),
    (
      icon: Icons.shopping_bag_outlined,
      label: 'Business Purchases',
      page: BusinessPurchasesPage(),
    ),
    (
      icon: Icons.build_outlined,
      label: 'Assets & Depreciation',
      page: AssetsPage(),
    ),
    (
      icon: Icons.inventory_2_outlined,
      label: 'Trading Stock',
      page: TradingStockPage(),
    ),
    (icon: Icons.summarize_outlined, label: 'Reports', page: ReportsPage()),
    (icon: Icons.settings_outlined, label: 'Settings', page: SettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: IconButton(
                tooltip: 'Log out',
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthBloc>().add(AuthLoggedOut()),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _destinations[_selectedIndex].page),
        ],
      ),
    );
  }
}
