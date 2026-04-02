import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class AidSalesScreen extends StatefulWidget {
  const AidSalesScreen({super.key});

  @override
  State<AidSalesScreen> createState() => _AidSalesScreenState();
}

class _AidSalesScreenState extends State<AidSalesScreen> {
  int _tab = 0;
  String _stockFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = provider.aidMoutons;
    final soldItems = items.where((m) => m.sold).toList();
    final stockItems = items.where((m) => !m.sold).where((m) {
      switch (_stockFilter) {
        case 'available':
          return m.isAvailable;
        case 'reserved':
          return m.reserved && !m.sold;
        default:
          return true;
      }
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        const SectionTitle('🐑 Vente moutons Aïd', sub: 'Réservation et vente عيد الأضحى'),
        _AidStats(provider: provider),
        const SizedBox(height: 14),
        _TopTabs(current: _tab, onChanged: (v) => setState(() => _tab = v)),
        const SizedBox(height: 14),
        if (_tab == 0) const _AddSheepCard(),
        if (_tab == 1) ...<Widget>[
          _StockFilterBar(
            current: _stockFilter,
            onChanged: (v) => setState(() => _stockFilter = v),
          ),
          const SizedBox(height: 10),
          if (stockItems.isEmpty)
            const AppCard(child: EmptyState(emoji: '🐑', text: 'Aucun mouton dans ce filtre'))
          else
            ...stockItems.map((m) => _AidSheepCard(mouton: m)),
        ],
        if (_tab == 2) ...<Widget>[
          if (soldItems.isEmpty)
            const AppCard(child: EmptyState(emoji: '💰', text: 'Aucune vente enregistrée'))
          else
            ...soldItems.map((m) => _AidSheepCard(mouton: m, soldView: true)),
        ],
      ],
    );
  }
}

class _AidStats extends StatelessWidget {
  const _AidStats({required this.provider});
  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: .95,
          children: <Widget>[
            _SmallStatCard(label: 'Total', value: '${provider.aidTotal}', color: AppColors.green2),
            _SmallStatCard(label: 'Dispo', value: '${provider.aidDisponibles}', color: AppColors.orange2),
            _SmallStatCard(label: 'Réservés', value: '${provider.aidReserves}', color: AppColors.blue2),
            _SmallStatCard(label: 'Vendus', value: '${provider.aidVendus}', color: AppColors.green3),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.orangeBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: Text('💰', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Bénéfice total des ventes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmtMAD(provider.aidBeneficeTotal),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: provider.aidBeneficeTotal >= 0 ? AppColors.green2 : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = <String>['Saisie', 'Stock', 'Vendus'];
    const icons = <String>['✏️', '🐑', '💰'];
    return AppCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List<Widget>.generate(labels.length, (index) {
          final selected = current == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onChanged(index),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(icons[index]),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          labels[index],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.white : AppColors.text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StockFilterBar extends StatelessWidget {
  const _StockFilterBar({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _FilterChip(label: 'Tous', selected: current == 'all', onTap: () => onChanged('all')),
        _FilterChip(label: 'Disponibles', selected: current == 'available', onTap: () => onChanged('available')),
        _FilterChip(label: 'Réservés', selected: current == 'reserved', onTap: () => onChanged('reserved')),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green2 : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddSheepCard extends StatefulWidget {
  const _AddSheepCard();

  @override
  State<_AddSheepCard> createState() => _AddSheepCardState();
}

class _AddSheepCardState extends State<_AddSheepCard> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _achatCtrl = TextEditingController();
  final _coutCtrl = TextEditingController();
  String _race = aidRaces.first;

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _achatCtrl.dispose();
    _coutCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final ok = await provider.addAidMouton(
      AidMouton(
        numero: _numeroCtrl.text.trim(),
        race: _race,
        prixAchat: double.tryParse(_achatCtrl.text.trim().replaceAll(',', '.')) ?? 0,
        coutRevient: double.tryParse(_coutCtrl.text.trim().replaceAll(',', '.')) ?? 0,
      ),
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce numéro existe déjà.')),
      );
      return;
    }
    _numeroCtrl.clear();
    _achatCtrl.clear();
    _coutCtrl.clear();
    setState(() => _race = aidRaces.first);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mouton ajouté au stock Aïd.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CardTitle('✦ NOUVEAU MOUTON AÏD'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _numeroCtrl,
                    decoration: const InputDecoration(labelText: 'N° mouton', hintText: 'ex: 001'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Obligatoire' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _race,
                    decoration: const InputDecoration(labelText: 'Race'),
                    items: aidRaces
                        .map((race) => DropdownMenuItem<String>(value: race, child: Text(race)))
                        .toList(),
                    onChanged: (value) => setState(() => _race = value ?? aidRaces.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _achatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Prix achat (DH)'),
                    validator: (value) {
                      final amount = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                      if (amount == null || amount <= 0) return 'Montant invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _coutCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Dépenses (DH)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter au stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AidSheepCard extends StatelessWidget {
  const _AidSheepCard({required this.mouton, this.soldView = false});
  final AidMouton mouton;
  final bool soldView;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final leadingColor = mouton.sold
        ? AppColors.orange2
        : mouton.reserved
            ? AppColors.blue2
            : AppColors.green3;

    return AppCard(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: leadingColor, width: 4)),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: <Widget>[
                      Text(
                        '🐑 #${mouton.numero}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.green2),
                      ),
                      _RaceBadge(mouton.race),
                      _StatusBadge(mouton: mouton),
                    ],
                  ),
                ),
                if (!soldView)
                  IconButton.filledTonal(
                    onPressed: () => _showReserveSellSheet(context, mouton),
                    icon: Icon(mouton.reserved ? Icons.edit_rounded : Icons.payments_rounded),
                  ),
                IconButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer ce mouton ?'),
                        content: Text('Le mouton #${mouton.numero} sera supprimé.'),
                        actions: <Widget>[
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await provider.deleteAidMouton(mouton.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mouton supprimé.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(child: _PriceCell(label: 'Achat', value: fmtMAD(mouton.prixAchat))),
                Expanded(child: _PriceCell(label: 'Dépenses', value: fmtMAD(mouton.coutRevient))),
              ],
            ),
            const SizedBox(height: 6),
            _PriceCell(label: 'Coût total', value: fmtMAD(mouton.coutTotal), emphasize: true),
            if (mouton.reserved || mouton.sold) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      mouton.acheteur.isEmpty ? 'Acheteur non défini' : '👤 ${mouton.acheteur}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text2),
                    ),
                  ),
                  if (mouton.sold)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: mouton.benefice >= 0 ? AppColors.greenBg : AppColors.redBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${mouton.benefice >= 0 ? '+' : ''}${fmtMAD(mouton.benefice)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: mouton.benefice >= 0 ? AppColors.green2 : AppColors.red,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'Prix à définir',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.blue2),
                    ),
                ],
              ),
              if (mouton.sold) ...<Widget>[
                const SizedBox(height: 8),
                _PriceCell(label: 'Prix vente', value: fmtMAD(mouton.prixVente)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RaceBadge extends StatelessWidget {
  const _RaceBadge(this.race);
  final String race;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg4,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(race, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text2)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.mouton});
  final AidMouton mouton;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    if (mouton.sold) {
      bg = AppColors.orangeBg;
      fg = AppColors.orange2;
      label = 'Vendu';
    } else if (mouton.reserved) {
      bg = AppColors.blueBg;
      fg = AppColors.blue2;
      label = 'Réservé';
    } else {
      bg = AppColors.greenBg;
      fg = AppColors.green2;
      label = 'Disponible';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: fg)),
    );
  }
}

class _PriceCell extends StatelessWidget {
  const _PriceCell({required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                color: emphasize ? AppColors.text : AppColors.text3,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 15 : 13,
              fontWeight: FontWeight.w900,
              color: emphasize ? AppColors.green2 : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showReserveSellSheet(BuildContext context, AidMouton mouton) async {
  final formKey = GlobalKey<FormState>();
  final acheteurCtrl = TextEditingController(text: mouton.acheteur);
  final coutCtrl = TextEditingController(text: mouton.coutRevient == 0 ? '' : mouton.coutRevient.toStringAsFixed(0));
  final venteCtrl = TextEditingController(text: mouton.prixVente == 0 ? '' : mouton.prixVente.toStringAsFixed(0));

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mouton.reserved ? 'Finaliser / modifier #${mouton.numero}' : 'Réserver / vendre #${mouton.numero}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green2),
                ),
                const SizedBox(height: 12),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text('Coût total (achat + dépenses)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text2)),
                      ),
                      Text(fmtMAD(mouton.coutTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.green2)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: acheteurCtrl,
                  decoration: const InputDecoration(labelText: 'Acheteur'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: coutCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Dépenses (DH)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: venteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Prix de vente (optionnel)'),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final provider = ctx.read<AppProvider>();
                          final prixVente = double.tryParse(venteCtrl.text.trim().replaceAll(',', '.')) ?? 0;
                          final coutRevient = double.tryParse(coutCtrl.text.trim().replaceAll(',', '.')) ?? 0;
                          final acheteur = acheteurCtrl.text.trim();
                          final sold = prixVente > 0;
                          final updated = mouton.copyWith(
                            acheteur: acheteur,
                            coutRevient: coutRevient,
                            prixVente: prixVente,
                            reserved: !sold,
                            sold: sold,
                            reservedAt: !sold ? (mouton.reservedAt ?? DateTime.now()) : mouton.reservedAt,
                            soldAt: sold ? DateTime.now() : null,
                          );
                          await provider.updateAidMouton(updated);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(sold ? 'Vente enregistrée.' : 'Réservation enregistrée.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Confirmer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
