import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

Future<void> showMvtForm(BuildContext context, {String? initialType}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MvtForm(initialType: initialType),
  );
}

class _MvtForm extends StatefulWidget {
  const _MvtForm({this.initialType});

  final String? initialType;

  @override
  State<_MvtForm> createState() => _MvtFormState();
}

class _MvtFormState extends State<_MvtForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _type;
  int _qte = 1;
  DateTime _date = DateTime.now();
  String _rem = '';

  final List<(String, String)> _types = const <(String, String)>[
    ('naissance_agf', '🍼 Naissance Agneau ♀'),
    ('naissance_agm', '🐣 Naissance Agneau ♂'),
    ('achat_femelle', '🛒 Achat Femelle'),
    ('achat_male', '🛒 Achat Mâle'),
    ('vente_femelle', '🤝 Vente Femelle'),
    ('vente_male', '🤝 Vente Mâle'),
    ('deces_femelle', '💀 Décès Femelle'),
    ('deces_male', '💀 Décès Mâle'),
    ('passage_agf', '🔄 Passage Agneau ♀ → Femelle'),
    ('passage_agm', '🔄 Passage Agneau ♂ → Mâle'),
    ('init_femelles', '⚙️ Stock initial Femelles'),
    ('init_males', '⚙️ Stock initial Mâles'),
    ('init_agf', '⚙️ Stock initial Agneaux ♀'),
    ('init_agm', '⚙️ Stock initial Agneaux ♂'),
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'naissance_agf';
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '🐑 Mouvement troupeau',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _label('Type de mouvement'),
            _dropdown<String>(
              _types
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.$1,
                      child: Text(entry.$2),
                    ),
                  )
                  .toList(),
              _type,
              (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Quantité'),
                      TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: '× '),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed < 1) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                        onSaved: (value) => _qte = int.tryParse(value ?? '') ?? 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (date) => setState(() => _date = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Observation optionnelle'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer le mouvement',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await context.read<AppProvider>().addMouvement(
          Mouvement(
            type: _type,
            qte: _qte,
            date: _date,
            remarque: _rem,
          ),
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mouvement enregistré'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

Future<void> showDepForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DepForm(),
  );
}

class _DepForm extends StatefulWidget {
  const _DepForm();

  @override
  State<_DepForm> createState() => _DepFormState();
}

class _DepFormState extends State<_DepForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _montant = 0;
  DateTime _date = DateTime.now();
  String _categorie = depCategories.first;
  String _rem = '';
  String _fermeId = 'rhamna';

  @override
  void initState() {
    super.initState();
    final filter = context.read<AppProvider>().fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '💸 Ajouter une dépense',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(
              value: _fermeId,
              onChanged: (v) => setState(() => _fermeId = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Montant (MAD)'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onSaved: (value) => _montant =
                            double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (date) => setState(() => _date = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Catégorie'),
            _dropdown<String>(
              depCategories
                  .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                  .toList(),
              _categorie,
              (value) => setState(() => _categorie = value ?? _categorie),
            ),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Détail optionnel'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer la dépense',
              color: AppColors.red2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await context.read<AppProvider>().addDepense(
          Depense(
            montant: _montant,
            date: _date,
            categorie: _categorie,
            remarque: _rem,
            fermeId: _fermeId,
          ),
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dépense enregistrée'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

Future<void> showRevForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RevForm(),
  );
}

class _RevForm extends StatefulWidget {
  const _RevForm();

  @override
  State<_RevForm> createState() => _RevFormState();
}

class _RevFormState extends State<_RevForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _montant = 0;
  DateTime _date = DateTime.now();
  String _categorie = revCategories.first;
  String _rem = '';
  String _fermeId = 'rhamna';

  @override
  void initState() {
    super.initState();
    final filter = context.read<AppProvider>().fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '💰 Ajouter un revenu',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(
              value: _fermeId,
              onChanged: (v) => setState(() => _fermeId = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Montant (MAD)'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onSaved: (value) => _montant =
                            double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (date) => setState(() => _date = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Catégorie'),
            _dropdown<String>(
              revCategories
                  .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                  .toList(),
              _categorie,
              (value) => setState(() => _categorie = value ?? _categorie),
            ),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Détail optionnel'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer le revenu',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await context.read<AppProvider>().addRevenu(
          Revenu(
            montant: _montant,
            date: _date,
            categorie: _categorie,
            remarque: _rem,
            fermeId: _fermeId,
          ),
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revenu enregistré'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green2,
                  ),
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(label),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: .5,
        fontWeight: FontWeight.w800,
        color: AppColors.text3,
      ),
    ),
  );
}

Widget _dropdown<T>(
  List<DropdownMenuItem<T>> items,
  T value,
  ValueChanged<T?> onChanged,
) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    items: items,
    onChanged: onChanged,
    dropdownColor: AppColors.bg2,
    decoration: const InputDecoration(),
  );
}

Widget _submitBtn({
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(60),
      ),
      child: Text(label),
    ),
  );
}

Widget _cancelBtn(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Annuler',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.text3,
        ),
      ),
    ),
  );
}

class _FermeSelector extends StatelessWidget {
  const _FermeSelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _btn('rhamna', '🐑 Rhamna'),
        const SizedBox(width: 10),
        _btn('srahna', '🫒 Srahna'),
      ],
    );
  }

  Widget _btn(String v, String label) {
    final selected = value == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.green2 : AppColors.bg3,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.green2 : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.text2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
