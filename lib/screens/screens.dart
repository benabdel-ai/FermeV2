import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/form_sheet.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;
    final now = DateTime.now();
    final depenses = provider.depensesMois(now);
    final revenus = provider.revenusGlobauxMois(now);
    final bilan = revenus - depenses;
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(now);

    final recentMouvements = provider.mouvements.reversed.take(5).toList();
    final recentDepenses = provider.depensesFiltrees.take(3).toList();
    final recentRevenus = provider.revenusFiltres.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          SectionTitle('📊 Tableau de bord pro', sub: monthName),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF256F49), Color(0xFF3BAA74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Text(
                    '🐑',
                    style: TextStyle(fontSize: 80, color: Colors.white24),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${stock.total}',
                      style: const TextStyle(
                        fontSize: 62,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cheptel total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stock.femelles} brebis · ${stock.males} béliers · ${stock.agneauxF + stock.agneauxM} agneaux',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.28,
            padding: const EdgeInsets.only(bottom: 14),
            children: <Widget>[
              KpiCard(emoji: '🐑', value: '${stock.femelles}', label: 'Femelles'),
              KpiCard(emoji: '🐏', value: '${stock.males}', label: 'Mâles'),
              KpiCard(emoji: '🍼', value: '${stock.agneauxF}', label: 'Agneaux ♀'),
              KpiCard(emoji: '🐣', value: '${stock.agneauxM}', label: 'Agneaux ♂'),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(depenses), label: 'Dépenses mois', color: AppColors.red),
              FinSumCard(value: fmtMAD(revenus), label: 'Revenus mois', color: AppColors.green2),
              FinSumCard(
                value: fmtMAD(bilan.abs()),
                label: bilan >= 0 ? 'Bilan +' : 'Bilan -',
                color: bilan >= 0 ? AppColors.green2 : AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'RACCOURCIS RAPIDES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: .96,
            padding: const EdgeInsets.only(bottom: 14),
            children: <Widget>[
              QuickBtn(
                emoji: '🍼',
                label: 'Naissance',
                onTap: () => showMvtForm(context, initialType: 'naissance_agf'),
              ),
              QuickBtn(
                emoji: '💸',
                label: 'Dépense',
                onTap: () => showDepForm(context),
              ),
              QuickBtn(
                emoji: '💰',
                label: 'Revenu',
                onTap: () => showRevForm(context),
              ),
              QuickBtn(
                emoji: '🛒',
                label: 'Achat',
                onTap: () => showMvtForm(context, initialType: 'achat_femelle'),
              ),
              QuickBtn(
                emoji: '🤝',
                label: 'Vente',
                onTap: () => showMvtForm(context, initialType: 'vente_femelle'),
              ),
              QuickBtn(
                emoji: '💀',
                label: 'Décès',
                onTap: () => showMvtForm(context, initialType: 'deces_femelle'),
              ),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📈 ÉVOLUTION DU TROUPEAU — 6 MOIS'),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= provider.last6MonthsData.length) {
                                return const SizedBox.shrink();
                              }
                              final month = provider.last6MonthsData[index]['month'] as DateTime;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('MMM', 'fr_FR').format(month),
                                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: <LineChartBarData>[
                        LineChartBarData(
                          spots: List<FlSpot>.generate(
                            provider.last6MonthsData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              (provider.last6MonthsData[index]['total'] as int).toDouble(),
                            ),
                          ),
                          isCurved: true,
                          barWidth: 4,
                          color: AppColors.green2,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('🕘 RÉCENT'),
                if (recentMouvements.isEmpty && recentDepenses.isEmpty && recentRevenus.isEmpty)
                  const EmptyState(emoji: '📭', text: 'Aucune donnée récente')
                else ...<Widget>[
                  ...recentMouvements.map(
                    (m) => RecentItem(
                      emoji: m.emoji,
                      title: m.label,
                      subtitle: fmtDate(m.date),
                      value: '×${m.qte}',
                      valueColor: mvtFgColor(m.color),
                      bgColor: mvtBgColor(m.color),
                    ),
                  ),
                  ...recentDepenses.map(
                    (d) => RecentItem(
                      emoji: '💸',
                      title: d.categorie,
                      subtitle: fmtDate(d.date),
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                    ),
                  ),
                  ...recentRevenus.map(
                    (r) => RecentItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: fmtDate(r.date),
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheptelScreen extends StatelessWidget {
  const CheptelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('🐑 Cheptel', sub: 'Suivi des entrées, sorties et état actuel'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('ÉTAT ACTUEL'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.22,
                  children: <Widget>[
                    KpiCard(emoji: '🐑', value: '${stock.femelles}', label: 'Femelles'),
                    KpiCard(emoji: '🐏', value: '${stock.males}', label: 'Mâles'),
                    KpiCard(emoji: '🍼', value: '${stock.agneauxF}', label: 'Agneaux ♀'),
                    KpiCard(emoji: '🐣', value: '${stock.agneauxM}', label: 'Agneaux ♂'),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('➕ AJOUTER UN MOUVEMENT'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: <Widget>[
                    MvtBtn(
                      emoji: '🍼',
                      label: 'Naissance ♀',
                      onTap: () => showMvtForm(context, initialType: 'naissance_agf'),
                    ),
                    MvtBtn(
                      emoji: '🐣',
                      label: 'Naissance ♂',
                      onTap: () => showMvtForm(context, initialType: 'naissance_agm'),
                    ),
                    MvtBtn(
                      emoji: '🛒',
                      label: 'Achat',
                      onTap: () => showMvtForm(context, initialType: 'achat_femelle'),
                    ),
                    MvtBtn(
                      emoji: '🤝',
                      label: 'Vente',
                      onTap: () => showMvtForm(context, initialType: 'vente_femelle'),
                    ),
                    MvtBtn(
                      emoji: '💀',
                      label: 'Décès',
                      onTap: () => showMvtForm(context, initialType: 'deces_femelle'),
                    ),
                    MvtBtn(
                      emoji: '⚙️',
                      label: 'Stock initial',
                      onTap: () => showMvtForm(context, initialType: 'init_femelles'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 DERNIERS MOUVEMENTS'),
                if (provider.mouvements.isEmpty)
                  const EmptyState(emoji: '🐑', text: 'Aucun mouvement enregistré')
                else
                  ...provider.mouvements.reversed.take(20).map(
                        (m) => HistoryItem(
                          emoji: m.emoji,
                          title: m.label,
                          subtitle:
                              '${fmtDate(m.date)}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                          value: '×${m.qte}',
                          valueColor: mvtFgColor(m.color),
                          bgColor: mvtBgColor(m.color),
                          onDelete: () => _confirmDelete(
                            context,
                            () => context.read<AppProvider>().deleteMouvement(m.id),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DepensesScreen extends StatelessWidget {
  const DepensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.depensesByCategorie();
    final total = provider.totalDepenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('💸 Dépenses', sub: 'Vue synthèse et journal des sorties'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(
                value: fmtMAD(provider.depensesMois(now)),
                label: 'Ce mois',
                color: AppColors.red,
              ),
              FinSumCard(
                value: fmtMAD(total),
                label: 'Total',
                color: AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(
            label: 'Ajouter une dépense',
            onTap: () => showDepForm(context),
            color: AppColors.red2,
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📊 PAR CATÉGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucune dépense')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(
                      cat: entry.key,
                      amount: entry.value,
                      total: total,
                      color: AppColors.red,
                    ),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 TOUTES LES DÉPENSES'),
                if (provider.depensesFiltrees.isEmpty)
                  const EmptyState(emoji: '💸', text: 'Aucune dépense enregistrée')
                else
                  ...provider.depensesFiltrees.map(
                    (d) => HistoryItem(
                      emoji: '💸',
                      title: d.categorie,
                      subtitle:
                          '${fmtDate(d.date)}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                      onDelete: () => _confirmDelete(
                        context,
                        () => context.read<AppProvider>().deleteDepense(d.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RevenusScreen extends StatelessWidget {
  const RevenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.revenusByCategorie();
    final total = provider.totalRevenus;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('💰 Revenus', sub: 'Vue synthèse et journal des encaissements'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(
                value: fmtMAD(provider.revenusMois(now)),
                label: 'Ce mois',
                color: AppColors.green2,
              ),
              FinSumCard(
                value: fmtMAD(total),
                label: 'Total',
                color: AppColors.green2,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(
            label: 'Ajouter un revenu',
            onTap: () => showRevForm(context),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📊 PAR CATÉGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucun revenu')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(
                      cat: entry.key,
                      amount: entry.value,
                      total: total,
                      color: AppColors.green2,
                    ),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 TOUS LES REVENUS'),
                if (provider.revenusFiltres.isEmpty)
                  const EmptyState(emoji: '💰', text: 'Aucun revenu enregistré')
                else
                  ...provider.revenusFiltres.map(
                    (r) => HistoryItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle:
                          '${fmtDate(r.date)}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                      onDelete: () => _confirmDelete(
                        context,
                        () => context.read<AppProvider>().deleteRevenu(r.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final items = <({DateTime date, String type, dynamic item})>[
      if (_filter == 'all' || _filter == 'mvt')
        ...provider.mouvements.map((m) => (date: m.date, type: 'mvt', item: m)),
      if (_filter == 'all' || _filter == 'dep')
        ...provider.depensesFiltrees.map((d) => (date: d.date, type: 'dep', item: d)),
      if (_filter == 'all' || _filter == 'rev')
        ...provider.revenusFiltres.map((r) => (date: r.date, type: 'rev', item: r)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('📜 Historique', sub: 'Toutes les opérations récentes'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _chip('Tout', 'all'),
                    _chip('🐑 Troupeau', 'mvt'),
                    _chip('💸 Dépenses', 'dep'),
                    _chip('💰 Revenus', 'rev'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(emoji: '📭', text: 'Aucune donnée')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];

                    if (entry.type == 'mvt') {
                      final m = entry.item as Mouvement;
                      return HistoryItem(
                        emoji: m.emoji,
                        title: m.label,
                        subtitle:
                            '${fmtDate(m.date)}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                        value: '×${m.qte}',
                        valueColor: mvtFgColor(m.color),
                        bgColor: mvtBgColor(m.color),
                      );
                    }

                    if (entry.type == 'dep') {
                      final d = entry.item as Depense;
                      return HistoryItem(
                        emoji: '💸',
                        title: d.categorie,
                        subtitle:
                            '${fmtDate(d.date)}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                        value: '-${fmtMAD(d.montant)}',
                        valueColor: AppColors.red,
                        bgColor: AppColors.redBg,
                      );
                    }

                    final r = entry.item as Revenu;
                    return HistoryItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle:
                          '${fmtDate(r.date)}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;

    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.green2 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text(
            'Supprimer',
            style: TextStyle(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
}


// ─── Finances hub (Dépenses + Revenus + Historique) ───────────────────────────

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const <Tab>[
            Tab(text: '💸 Dépenses'),
            Tab(text: '💰 Revenus'),
            Tab(text: '📜 Historique'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const <Widget>[
              DepensesScreen(),
              RevenusScreen(),
              HistoriqueScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ManagementHubScreen extends StatelessWidget {
  const ManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilotage & paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          const SectionTitle('⚙️ Centre de gestion', sub: 'Version pro prête pour évoluer vers une vraie app métier'),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CardTitle('✅ DISPONIBLE MAINTENANT'),
                _HubTile(emoji: '🐑', title: 'Cheptel', subtitle: 'Mouvements, stock actuel, historique rapide'),
                _HubTile(emoji: '💸', title: 'Dépenses', subtitle: 'Saisie mobile, totaux, répartition par catégorie'),
                _HubTile(emoji: '💰', title: 'Revenus', subtitle: 'Saisie mobile, totaux, répartition par catégorie'),
                _HubTile(emoji: '📜', title: 'Historique', subtitle: 'Vision chronologique de toutes les opérations'),
              ],
            ),
          ),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CardTitle('🚀 PRÊT POUR LA PROCHAINE ÉTAPE'),
                _HubTile(emoji: '🏡', title: 'Multi-fermes', subtitle: 'Ajouter Ferme 1 / Ferme 2 et filtrage global'),
                _HubTile(emoji: '🌾', title: 'Agriculture', subtitle: 'Cultures, activités, récoltes, entretien'),
                _HubTile(emoji: '🏷️', title: 'Référentiels', subtitle: 'Catégories modifiables, désignations fréquentes'),
                _HubTile(emoji: '🔁', title: 'Récurrences', subtitle: 'Dépenses et revenus automatiques'),
                _HubTile(emoji: '🧾', title: 'Exports', subtitle: 'CSV, PDF, sauvegarde et restauration'),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('🧼 OUTILS'),
                AddButton(
                  label: 'Vider toutes les données de démonstration',
                  onTap: () => _confirmDelete(
                    context,
                    () => context.read<AppProvider>().clearAll(),
                  ),
                  color: AppColors.red2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _HubTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
