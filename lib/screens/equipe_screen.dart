import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class EquipeScreen extends StatelessWidget {
  const EquipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('👷 Équipe', sub: 'Salariés fixes et saisonniers'),
          const _RecurringSection(),
          const _SessionsSection(),
        ],
      ),
    );
  }
}

// ─── Salariés fixes (récurrents hebdo) ────────────────────────────────────────

class _RecurringSection extends StatelessWidget {
  const _RecurringSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final recurring = provider.recurringFiltrees;
    final dueCount = recurring.where((r) => r.isDueThisWeek).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(child: CardTitle('👥 SALARIÉS FIXES — HEBDOMADAIRE')),
              if (dueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dueCount à payer',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.red),
                  ),
                ),
            ],
          ),
          AddButton(
            label: 'Ajouter un salarié fixe',
            onTap: () => _showRecurringForm(context),
          ),
          if (recurring.isEmpty)
            const EmptyState(emoji: '👥', text: 'Aucun salarié fixe configuré')
          else
            ...recurring.map((re) => _RecurringItem(re: re)),
        ],
      ),
    );
  }
}

class _RecurringItem extends StatelessWidget {
  const _RecurringItem({required this.re});
  final RecurringExpense re;

  @override
  Widget build(BuildContext context) {
    final isDue = re.isDueThisWeek;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: !re.actif
            ? AppColors.bg3
            : isDue
                ? AppColors.redBg
                : AppColors.greenBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: !re.actif
              ? AppColors.border
              : isDue
                  ? AppColors.red.withValues(alpha: 0.3)
                  : AppColors.green2.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: !re.actif
                  ? AppColors.bg4
                  : isDue
                      ? AppColors.red.withValues(alpha: 0.12)
                      : AppColors.green2.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                !re.actif ? '⏸️' : isDue ? '🔴' : '✅',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  re.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: re.actif ? AppColors.text : AppColors.text3,
                  ),
                ),
                Text(
                  '${fmtMAD(re.montant)} / semaine',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: !re.actif ? AppColors.text3 : isDue ? AppColors.red : AppColors.green2,
                  ),
                ),
                if (re.lastPaidAt != null)
                  Text(
                    'Payé le ${fmtDate(re.lastPaidAt!)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.text3),
                  ),
                const SizedBox(height: 4),
                FermeBadge(re.fermeId),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (isDue && re.actif)
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => context.read<AppProvider>().payRecurring(re),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Payer', style: TextStyle(fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () => context.read<AppProvider>().toggleRecurringExpense(re),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        re.actif ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        size: 20,
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _confirmDelete(
                      context,
                      () => context.read<AppProvider>().deleteRecurringExpense(re.id),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline, size: 20, color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Saisonniers ──────────────────────────────────────────────────────────────

class _SessionsSection extends StatelessWidget {
  const _SessionsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sessions = provider.sessionsFiltrees;
    final totalPaye = sessions.fold(0.0, (s, t) => s + t.total);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardTitle('🌾 SAISONNIERS'),
          if (sessions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Total main-d\'œuvre : ${fmtMAD(totalPaye)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red),
              ),
            ),
          AddButton(
            label: 'Enregistrer une session',
            onTap: () => _showSessionForm(context),
          ),
          if (sessions.isEmpty)
            const EmptyState(emoji: '🌾', text: 'Aucune session enregistrée')
          else
            ...sessions.map((s) => _SessionItem(s: s)),
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  const _SessionItem({required this.s});
  final TravailleurSession s;

  @override
  Widget build(BuildContext context) {
    final joursStr = s.nbJours % 1 == 0 ? '${s.nbJours.toInt()}' : s.nbJours.toStringAsFixed(1);
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
            color: AppColors.orangeBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: Text('👷', style: TextStyle(fontSize: 26))),
        ),
        title: Text(s.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$joursStr j × ${fmtMAD(s.salaireJournalier)}/j · ${fmtDate(s.date)}',
              style: const TextStyle(fontSize: 12, color: AppColors.text3),
            ),
            if (s.remarque.isNotEmpty)
              Text(s.remarque, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
            const SizedBox(height: 4),
            FermeBadge(s.fermeId),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              '-${fmtMAD(s.total)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red),
            ),
            InkWell(
              onTap: () => _confirmDelete(
                context,
                () => context.read<AppProvider>().deleteTravailleurSession(s.id),
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

// ─── Recurring form ───────────────────────────────────────────────────────────

void _showRecurringForm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RecurringFormSheet(),
  );
}

class _RecurringFormSheet extends StatefulWidget {
  const _RecurringFormSheet();

  @override
  State<_RecurringFormSheet> createState() => _RecurringFormState();
}

class _RecurringFormState extends State<_RecurringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  String _fermeId = 'rhamna';

  @override
  void initState() {
    super.initState();
    final f = context.read<AppProvider>().fermeFilter;
    if (f != 'all') _fermeId = f;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _montantCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final re = RecurringExpense(
      label: _labelCtrl.text.trim(),
      montant: double.parse(_montantCtrl.text.replaceAll(',', '.')),
      fermeId: _fermeId,
    );
    await context.read<AppProvider>().addRecurringExpense(re);
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
            const Text('👥 Ajouter un salarié fixe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2)),
            const SizedBox(height: 6),
            const Text(
              'Le bouton "Payer" apparaîtra chaque semaine',
              style: TextStyle(fontSize: 12, color: AppColors.text3, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Nom du salarié *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montantCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Salaire hebdomadaire MAD *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            _fermePicker(),
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
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: sel ? Colors.white : AppColors.text2)),
          ),
        ),
      ),
    );
  }
}

// ─── Session form ─────────────────────────────────────────────────────────────

void _showSessionForm(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SessionFormSheet(),
  );
}

class _SessionFormSheet extends StatefulWidget {
  const _SessionFormSheet();

  @override
  State<_SessionFormSheet> createState() => _SessionFormState();
}

class _SessionFormState extends State<_SessionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _joursCtrl = TextEditingController();
  final _salaireCtrl = TextEditingController();
  final _remarqueCtrl = TextEditingController();
  String _fermeId = 'rhamna';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final f = context.read<AppProvider>().fermeFilter;
    if (f != 'all') _fermeId = f;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _joursCtrl.dispose();
    _salaireCtrl.dispose();
    _remarqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = TravailleurSession(
      fermeId: _fermeId,
      nom: _nomCtrl.text.trim(),
      nbJours: double.parse(_joursCtrl.text.replaceAll(',', '.')),
      salaireJournalier: double.parse(_salaireCtrl.text.replaceAll(',', '.')),
      date: _date,
      remarque: _remarqueCtrl.text.trim(),
    );
    await context.read<AppProvider>().addTravailleurSession(session);
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
            const Text('🌾 Enregistrer une session travail',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2)),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom du travailleur *'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _joursCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Nombre de jours *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _salaireCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Salaire / jour MAD *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _fermePicker(),
            const SizedBox(height: 12),
            InkWell(
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
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: Text('📅 ${fmtDate(_date)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
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
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: sel ? Colors.white : AppColors.text2)),
          ),
        ),
      ),
    );
  }
}
