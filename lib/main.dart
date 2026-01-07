import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/enums.dart';
import 'data/models.dart';
import 'logic/wallet_cubit.dart';
import 'logic/ui_cubit.dart';
import 'logic/profile_cubit.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';
import 'views/immos_page.dart';
import 'views/wallet_page.dart';
import 'views/summary_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WalletCubit().._initializeDemoData()),
        BlocProvider(create: (_) => UiCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
      ],
      child: MaterialApp(
        title: 'Zolane',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
        ],
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ImmosPage(),
    WalletPage(),
    SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.cardRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: AppTheme.cardColor,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_work),
                label: 'Immos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'Portefeuille',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Bilan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension WalletCubitDemo on WalletCubit {
  void _initializeDemoData() {
    // Entry: source=immo + property=bergere + amount=800 + note="Loyer novembre"
    addEntry(WalletEntry(
      source: EntrySource.immo,
      property: ImmoProperty.bergere,
      amount: 800,
      note: 'Loyer novembre',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ));

    // Expense: type=chargesImmo + property=bergere + immoReason=electricite + amount=120
    addExpense(WalletExpense(
      type: ExpenseType.chargesImmo,
      property: ImmoProperty.bergere,
      immoReason: ImmoChargeReason.electricite,
      amount: 120,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ));

    // Expense: type=personnelle + personalReason=transport + amount=40
    addExpense(WalletExpense(
      type: ExpenseType.personnelle,
      personalReason: PersonalReason.transport,
      amount: 40,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ));
  }
}
