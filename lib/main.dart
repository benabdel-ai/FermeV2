import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/aid_sales_screen.dart';
import 'screens/cultures_screen.dart';
import 'screens/equipe_screen.dart';
import 'screens/screens.dart';
import 'theme.dart';
import 'widgets/form_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TroupeauApp());
}

class TroupeauApp extends StatelessWidget {
  const TroupeauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'Ma Ferme Pro',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    CulturesScreen(),
    EquipeScreen(),
    CheptelScreen(),
    FinancesScreen(),
    AidSalesScreen(),
  ];

  static const List<String> _labels = <String>[
    'Accueil',
    'Cultures',
    'Équipe',
    'Cheptel',
    'Finances',
    'Aïd',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.space_dashboard_rounded,
    Icons.grass_rounded,
    Icons.people_rounded,
    Icons.pets_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.sell_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.green2, AppColors.green4],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text('🐑', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ma Ferme Pro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chargement des donnees...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    backgroundColor: AppColors.greenBg,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 82,
        titleSpacing: 16,
        title: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.green2, AppColors.green4],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('🐑', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ma Ferme Pro',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green2,
                  ),
                ),
                Text(
                  'Elevage & suivi financier',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManagementHubScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.bg4,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _dayName(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green3,
                    ),
                  ),
                  Text(
                    _dateStr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _screens[_index]),
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _index,
          destinations: List<NavigationDestination>.generate(
            _labels.length,
            (index) => NavigationDestination(
              icon: Icon(_icons[index]),
              label: _labels[index],
            ),
          ),
          onDestinationSelected: (value) => setState(() => _index = value),
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    switch (_index) {
      case 3: // Cheptel
        return FloatingActionButton.extended(
          onPressed: () => showMvtForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Mouvement'),
        );
      case 4: // Finances
        return FloatingActionButton.extended(
          onPressed: () => showDepForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Dépense'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _dayName() {
    const days = <String>['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    final now = DateTime.now();
    return days[(now.weekday - 1).clamp(0, 6)];
  }

  String _dateStr() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    return '$dd/$mm/${now.year}';
  }
}

