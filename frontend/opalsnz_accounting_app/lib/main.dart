import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/income/income_bloc.dart';
import 'bloc/expense_category/expense_category_bloc.dart';
import 'bloc/home_office_expense/home_office_expense_bloc.dart';
import 'bloc/business_purchase/business_purchase_bloc.dart';
import 'bloc/asset/asset_bloc.dart';
import 'bloc/trading_stock/trading_stock_bloc.dart';
import 'bloc/report/report_bloc.dart';
import 'pages/app_shell.dart';
import 'pages/login_page.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/income_service.dart';
import 'services/expense_category_service.dart';
import 'services/home_office_expense_service.dart';
import 'services/business_purchase_service.dart';
import 'services/asset_service.dart';
import 'services/trading_stock_service.dart';
import 'services/report_service.dart';

void main() {
  runApp(const OpalsAccountingApp());
}

class OpalsAccountingApp extends StatelessWidget {
  const OpalsAccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final apiClient = ApiClient(authService);

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<ApiClient>.value(value: apiClient),
        Provider<IncomeService>(create: (_) => IncomeService(apiClient)),
        Provider<ExpenseCategoryService>(
          create: (_) => ExpenseCategoryService(apiClient),
        ),
        Provider<HomeOfficeExpenseService>(
          create: (_) => HomeOfficeExpenseService(apiClient),
        ),
        Provider<BusinessPurchaseService>(
          create: (_) => BusinessPurchaseService(apiClient),
        ),
        Provider<AssetService>(create: (_) => AssetService(apiClient)),
        Provider<TradingStockService>(
          create: (_) => TradingStockService(apiClient),
        ),
        Provider<HistoricalStockPurchaseService>(
          create: (_) => HistoricalStockPurchaseService(apiClient),
        ),
        Provider<ReportService>(create: (_) => ReportService(apiClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) =>
                AuthBloc(ctx.read<AuthService>())..add(AuthStarted()),
          ),
          BlocProvider(create: (ctx) => IncomeBloc(ctx.read<IncomeService>())),
          BlocProvider(
            create: (ctx) =>
                ExpenseCategoryBloc(ctx.read<ExpenseCategoryService>()),
          ),
          BlocProvider(
            create: (ctx) =>
                HomeOfficeExpenseBloc(ctx.read<HomeOfficeExpenseService>()),
          ),
          BlocProvider(
            create: (ctx) =>
                BusinessPurchaseBloc(ctx.read<BusinessPurchaseService>()),
          ),
          BlocProvider(create: (ctx) => AssetBloc(ctx.read<AssetService>())),
          BlocProvider(
            create: (ctx) => TradingStockBloc(
              ctx.read<TradingStockService>(),
              ctx.read<HistoricalStockPurchaseService>(),
            ),
          ),
          BlocProvider(create: (ctx) => ReportBloc(ctx.read<ReportService>())),
        ],
        child: MaterialApp(
          title: 'OpalsNZ Accounting',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
          home: const _RootPage(),
        ),
      ),
    );
  }
}

// Shows the login page until authenticated, then the main app shell.
class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const AppShell();
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
