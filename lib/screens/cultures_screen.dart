import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CulturesScreen extends StatefulWidget {
  const CulturesScreen({super.key});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
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
        const FermeFilterBar(),
        TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: const <Tab>[
            Tab(text: '🌾 Récoltes'),
            Tab(text: '🫒 Trituration'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const <Widget>[
              _RecolteTab(),
              _TriturationTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Récolte Tab ──────────────────────────────────────────────────────────────

class _RecolteTab extends StatelessWidget {
  const _RecolteTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final recoltes = provider.recoltesFiltrees;

    final byCulture = <String, double>{};
    for (final r in recoltes) {
      byCulture[r.culture] = (byCulture[r.culture] ?? 0) + r.quantite;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('🌾 Récoltes', sub: 'Production par culture et saison'),
          if (byCulture.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: byCulture.entries.map((e) {
                final emoji = cultureEmojis[e.key] ?? '🌱';
                final unite = cultureUnites[e.key] ?? 'kg';
                return _CultureKpi(emoji: emoji, culture: e.key, total: e.value, unite: unite);
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
          AddButton(
            label: 'Enregistrer une récolte',
            onTap: () => _showRecolteForm(context),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 HISTORIQUE RÉCOLTES'),
                if (recoltes.isEmpty)
                  const EmptyState(emoji: '🌾', text: 'Aucune récolte enregistrée')
                else
                  ...recoltes.map((r) => _RecolteItem(r: r)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CultureKpi extends StatelessWidget {
  const _CultureKpi({
    required this.emoji,
    required this.culture,
    required this.total,
    required this.unite,
  });

  final String emoji;
  final String culture;
  final double total;
  final String unite;

  @override
  Widget build(BuildContext context) {
    final display = total % 1 == 0 ? '${total.toInt()} $unite' : '${total.toStringAsFixed(1)} $unite';
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            display,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.green2),
          ),
          Text(culture, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _RecolteItem extends StatelessWidget {
  const _RecolteItem({required this.r});
  final Recolte r;

  @override
  Widget build(BuildContext context) {
    final emoji = cultureEmojis[r.culture] ?? '🌱';
    final qteStr = r.quantite % 1 == 0
        ? '${r.quantite.toInt()} ${r.unite}'
        : '${r.quantite.toStringAsFixed(1)} ${r.unite}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.greenBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
        ),
        title: Text(r.culture, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Saison ${r.saison} · ${fmtDate(r.date)}',
              style: const TextStyle(fontSize: 12, color: AppColors.text3),
            ),
            if (r.remarque.isNotEmpty)
              Text(r.remarque, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
            const SizedBox(height: 4),
            FermeBadge(r.fermeId),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              qteStr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.green2),
            ),
            InkWell(
              onTap: () => _confirmDelete(
                context,
                () => context.read<AppProvider>().deleteRecolte(r.id),
              ),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.delete_outline, size: 19, color: AppColors.red),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ─── Trituration Tab ──────────────────────────────────────────────────────────

class _TriturationTab extends StatelessWidget {
  const _TriturationTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final trits = provider.triturationsFiltrees;

    final totalKg = trits.fold(0.0, (s, t) => s + t.kgOlives);
    final totalL = trits.fold(0.0, (s, t) => s + t.litresHuile);
    final rendement = totalKg > 0 ? totalL / totalKg * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('🫒 Trituration', sub: "Extraction huile d'olive par saison"),
          if (trits.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _TritKpi(emoji: '🫒', value: '${totalKg.toStringAsFixed(0)} kg', label: 'Olives triturées'),
                _TritKpi(emoji: '🫙', value: '${totalL.toStringAsFixed(1)} L', label: 'Huile extraite'),
                _TritKpi(emoji: '📊', value: '${rendement.toStringAsFixed(1)}%', label: 'Rendement moyen'),
              ],
            ),
            const SizedBox(height: 14),
          ],
          AddButton(
            label: 'Enregistrer une trituration',
            onTap: () => _showTriturationForm(context),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 HISTORIQUE TRITURATION'),
                if (trits.isEmpty)
                  const EmptyState(emoji: '🫒', text: 'Aucune trituration enregistrée')
                else
                  ...trits.map((t) => _TriturationItem(t: t)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TritKpi extends StatelessWidget {
  const _TritKpi({required this.emoji, required this.value, required this.label});
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.green2)),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _TriturationItem extends StatelessWidget {
  const _TriturationItem({required this.t});
  final Trituration t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('🫒', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Saison ${t.saison} · ${fmtDate(t.date)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    FermeBadge(t.fermeId),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _confirmDelete(
                  context,
                  () => context.read<AppProvider>().deleteTrituration(t.id),
                ),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 19, color: AppColors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('🫒 Olives', '${t.kgOlives.toStringAsFixed(0)} kg'),
          _infoRow('🫙 Huile extraite', '${t.litresHuile.toStringAsFixed(1)} L (${t.rendementPct.toStringAsFixed(1)}%)'),
          if (t.coutTrituration > 0) _infoRow('💸 Coût moulin', fmtMAD(t.coutTrituration)),
          if (t.litresVente > 0) _infoRow('🤝 Vendu', '${t.litresVente.toStringAsFixed(1)} L · ${fmtMAD(t.revenusVente)}'),
          if (t.litresFamille > 0) _infoRow('🏠 Famille', '${t.litresFamille.toStringAsFixed(1)} L'),
          if (t.litresHeritiers > 0) _infoRow('👨‍👩‍👧 Héritiers', '${t.litresHeritiers.toStringAsFixed(1)} L'),
          if (t.remarque.isNotEmpty) _infoRow('📝', t.remarque),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text3, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
        ],
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}

// ─── Récolte Form ─────────────────────────────────────────────────────────────

void _showRecolteForm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RecolteFormSheet(),
  );
}

class _RecolteFormSheet extends StatefulWidget {
  const _RecolteFormSheet();

  @override
  State<_RecolteFormSheet> createState() => _RecolteFormState();
}

class _RecolteFormState extends State<_RecolteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String _culture = cultureTypes.first;
  String _fermeId = 'rhamna';
  int _saison = DateTime.now().year;
  DateTime _date = DateTime.now();
  final _qteCtrl = TextEditingController();
  final _qteVenteCtrl = TextEditingController();
  final _qteInterneCtrl = TextEditingController();
  final _remarqueCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = context.read<AppProvider>().fermeFilter;
    if (f != 'all') _fermeId = f;
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    _qteVenteCtrl.dispose();
    _qteInterneCtrl.dispose();
    _remarqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final r = Recolte(
      fermeId: _fermeId,
      culture: _culture,
      saison: _saison,
      quantite: double.parse(_qteCtrl.text.replaceAll(',', '.')),
      unite: cultureUnites[_culture] ?? 'kg',
      quantiteVente: _qteVenteCtrl.text.isEmpty ? 0 : double.tryParse(_qteVenteCtrl.text.replaceAll(',', '.')) ?? 0,
      quantiteInterne: _qteInterneCtrl.text.isEmpty ? 0 : double.tryParse(_qteInterneCtrl.text.replaceAll(',', '.')) ?? 0,
      date: _date,
      remarque: _remarqueCtrl.text.trim(),
    );
    await context.read<AppProvider>().addRecolte(r);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _handle(),
            const SizedBox(height: 18),
            const Text('🌾 Enregistrer une récolte',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2)),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _culture,
              decoration: const InputDecoration(labelText: 'Culture'),
              items: cultureTypes
                  .map((c) => DropdownMenuItem(value: c, child: Text('${cultureEmojis[c] ?? ''} $c')))
                  .toList(),
              onChanged: (v) => setState(() => _culture = v!),
            ),
            const SizedBox(height: 12),
            _fermePicker(),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _qteCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Quantité (${cultureUnites[_culture] ?? 'kg'}) *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePicker(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _qteVenteCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Qté vendue (opt.)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _qteInterneCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Qté interne (opt.)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _remarqueCtrl,
                    decoration: const InputDecoration(labelText: 'Remarque (opt.)'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<int>(
                    value: _saison,
                    decoration: const InputDecoration(labelText: 'Saison'),
                    items: List<int>.generate(6, (i) => DateTime.now().year - 2 + i)
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _saison = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
      );

  Widget _fermePicker() => Row(
        children: <Widget>[
          _fermeBtn('🐑 Rhamna', 'rhamna'),
          const SizedBox(width: 10),
          _fermeBtn('🫒 Srahna', 'srahna'),
        ],
      );

  Widget _fermeBtn(String label, String value) {
    final sel = _fermeId == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _fermeId = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? AppColors.green2 : AppColors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? AppColors.green2 : AppColors.border),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: sel ? Colors.white : AppColors.text2)),
          ),
        ),
      ),
    );
  }

  Widget _datePicker() => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Text(fmtDate(_date), style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
}

// ─── Trituration Form ─────────────────────────────────────────────────────────

void _showTriturationForm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TriturationFormSheet(),
  );
}

class _TriturationFormSheet extends StatefulWidget {
  const _TriturationFormSheet();

  @override
  State<_TriturationFormSheet> createState() => _TriturationFormState();
}

class _TriturationFormState extends State<_TriturationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String _fermeId = 'rhamna';
  int _saison = DateTime.now().year;
  DateTime _date = DateTime.now();
  final _kgCtrl = TextEditingController();
  final _litresCtrl = TextEditingController();
  final _coutCtrl = TextEditingController();
  final _litresVenteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _litresFamilleCtrl = TextEditingController();
  final _litresHeritiersCtrl = TextEditingController();
  final _remarqueCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = context.read<AppProvider>().fermeFilter;
    if (f != 'all') _fermeId = f;
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    _litresCtrl.dispose();
    _coutCtrl.dispose();
    _litresVenteCtrl.dispose();
    _prixCtrl.dispose();
    _litresFamilleCtrl.dispose();
    _litresHeritiersCtrl.dispose();
    _remarqueCtrl.dispose();
    super.dispose();
  }

  double _opt(TextEditingController c) =>
      c.text.isEmpty ? 0 : (double.tryParse(c.text.replaceAll(',', '.')) ?? 0);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = Trituration(
      fermeId: _fermeId,
      saison: _saison,
      kgOlives: double.parse(_kgCtrl.text.replaceAll(',', '.')),
      litresHuile: double.parse(_litresCtrl.text.replaceAll(',', '.')),
      coutTrituration: _opt(_coutCtrl),
      litresVente: _opt(_litresVenteCtrl),
      prixVenteLitre: _opt(_prixCtrl),
      litresFamille: _opt(_litresFamilleCtrl),
      litresHeritiers: _opt(_litresHeritiersCtrl),
      date: _date,
      remarque: _remarqueCtrl.text.trim(),
    );
    await context.read<AppProvider>().addTrituration(t);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _handle(),
              const SizedBox(height: 18),
              const Text('🫒 Enregistrer une trituration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2)),
              const SizedBox(height: 18),
              _fermePicker(),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _saison,
                      decoration: const InputDecoration(labelText: 'Saison'),
                      items: List<int>.generate(6, (i) => DateTime.now().year - 2 + i)
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (v) => setState(() => _saison = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _datePicker()),
                ],
              ),
              const SizedBox(height: 12),
              _label('OLIVES & HUILE'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _kgCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Kg olives *'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _litresCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Litres huile *'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coutCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Coût trituration MAD (opt.)'),
              ),
              const SizedBox(height: 12),
              _label('DISTRIBUTION HUILE'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _litresVenteCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Litres vendus'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prixCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Prix / litre MAD'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _litresFamilleCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Litres famille'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _litresHeritiersCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Litres héritiers'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarqueCtrl,
                decoration: const InputDecoration(labelText: 'Remarque (opt.)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.text3, letterSpacing: .5),
      );

  Widget _fermePicker() => Row(
        children: <Widget>[
          _fermeBtn('🐑 Rhamna', 'rhamna'),
          const SizedBox(width: 10),
          _fermeBtn('🫒 Srahna', 'srahna'),
        ],
      );

  Widget _fermeBtn(String label, String value) {
    final sel = _fermeId == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _fermeId = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? AppColors.green2 : AppColors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? AppColors.green2 : AppColors.border),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: sel ? Colors.white : AppColors.text2)),
          ),
        ),
      ),
    );
  }

  Widget _datePicker() => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Text(fmtDate(_date), style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
}
