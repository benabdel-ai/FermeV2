import 'package:flutter/foundation.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  // ─── État global ───────────────────────────────────────────────────────────

  bool loading = true;
  String fermeFilter = 'all'; // 'all' | 'rhamna' | 'srahna'

  // ─── Données brutes ────────────────────────────────────────────────────────

  List<Mouvement> mouvements = <Mouvement>[];
  List<Depense> depenses = <Depense>[];
  List<Revenu> revenus = <Revenu>[];
  List<AidMouton> aidMoutons = <AidMouton>[];
  List<Recolte> recoltes = <Recolte>[];
  List<Trituration> triturations = <Trituration>[];
  List<TravailleurSession> travailleurSessions = <TravailleurSession>[];
  List<RecurringExpense> recurringExpenses = <RecurringExpense>[];

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async => load();

  Future<void> load() async {
    loading = true;
    notifyListeners();

    mouvements = await _db.getMouvements();
    depenses = await _db.getDepenses();
    revenus = await _db.getRevenus();
    aidMoutons = await _db.getAidMoutons();
    recoltes = await _db.getRecoltes();
    triturations = await _db.getTriturations();
    travailleurSessions = await _db.getTravailleurSessions();
    recurringExpenses = await _db.getRecurringExpenses();

    loading = false;
    notifyListeners();
  }

  // ─── Filtre ferme ──────────────────────────────────────────────────────────

  void setFermeFilter(String f) {
    fermeFilter = f;
    notifyListeners();
  }

  List<Depense> get depensesFiltrees => fermeFilter == 'all'
      ? depenses
      : depenses.where((d) => d.fermeId == fermeFilter).toList();

  List<Revenu> get revenusFiltres => fermeFilter == 'all'
      ? revenus
      : revenus.where((r) => r.fermeId == fermeFilter).toList();

  List<Recolte> get recoltesFiltrees => fermeFilter == 'all'
      ? recoltes
      : recoltes.where((r) => r.fermeId == fermeFilter).toList();

  List<Trituration> get triturationsFiltrees => fermeFilter == 'all'
      ? triturations
      : triturations.where((t) => t.fermeId == fermeFilter).toList();

  List<TravailleurSession> get sessionsFiltrees => fermeFilter == 'all'
      ? travailleurSessions
      : travailleurSessions.where((s) => s.fermeId == fermeFilter).toList();

  List<RecurringExpense> get recurringFiltrees => fermeFilter == 'all'
      ? recurringExpenses
      : recurringExpenses.where((r) => r.fermeId == fermeFilter).toList();

  // ─── Cheptel (toujours Rhamna) ─────────────────────────────────────────────

  Stock get stock {
    var current = const Stock();
    for (final m in mouvements) {
      current = current.apply(m.type, m.qte);
    }
    return current;
  }

  // ─── Finances filtrées ─────────────────────────────────────────────────────

  double get totalDepenses =>
      depensesFiltrees.fold(0, (sum, item) => sum + item.montant);

  double get totalRevenus =>
      revenusFiltres.fold(0, (sum, item) => sum + item.montant);

  double get bilan => totalRevenus - totalDepenses;

  double depensesMois(DateTime month) => depensesFiltrees
      .where((d) => d.date.year == month.year && d.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  double revenusMois(DateTime month) => revenusFiltres
      .where((r) => r.date.year == month.year && r.date.month == month.month)
      .fold(0, (sum, item) => sum + item.montant);

  double ventesAidMois(DateTime month) => aidMoutons
      .where((m) =>
          m.sold &&
          m.soldAt != null &&
          m.soldAt!.year == month.year &&
          m.soldAt!.month == month.month)
      .fold(0, (sum, m) => sum + m.prixVente);

  double revenusGlobauxMois(DateTime month) =>
      revenusMois(month) + ventesAidMois(month);

  List<Map<String, dynamic>> get last6MonthsData {
    final now = DateTime.now();
    return List<Map<String, dynamic>>.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      var stockAtMonth = const Stock();
      for (final mouvement in mouvements) {
        if (!mouvement.date.isAfter(endOfMonth)) {
          stockAtMonth = stockAtMonth.apply(mouvement.type, mouvement.qte);
        }
      }
      return <String, dynamic>{
        'month': month,
        'total': stockAtMonth.total,
        'depenses': depensesMois(month),
        'revenus': revenusMois(month),
      };
    });
  }

  Map<String, double> depensesByCategorie() {
    final result = <String, double>{};
    for (final item in depensesFiltrees) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    return Map.fromEntries(
        (result.entries.toList()..sort((a, b) => b.value.compareTo(a.value))));
  }

  Map<String, double> revenusByCategorie() {
    final result = <String, double>{};
    for (final item in revenusFiltres) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    return Map.fromEntries(
        (result.entries.toList()..sort((a, b) => b.value.compareTo(a.value))));
  }

  // ─── CRUD Mouvements ───────────────────────────────────────────────────────

  Future<void> addMouvement(Mouvement mouvement) async {
    await _db.insertMouvement(mouvement);
    mouvements = await _db.getMouvements();
    notifyListeners();
  }

  Future<void> deleteMouvement(String id) async {
    await _db.deleteMouvement(id);
    mouvements.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Dépenses ─────────────────────────────────────────────────────────

  Future<void> addDepense(Depense depense) async {
    await _db.insertDepense(depense);
    depenses = await _db.getDepenses();
    notifyListeners();
  }

  Future<void> deleteDepense(String id) async {
    await _db.deleteDepense(id);
    depenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Revenus ──────────────────────────────────────────────────────────

  Future<void> addRevenu(Revenu revenu) async {
    await _db.insertRevenu(revenu);
    revenus = await _db.getRevenus();
    notifyListeners();
  }

  Future<void> deleteRevenu(String id) async {
    await _db.deleteRevenu(id);
    revenus.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Aid Moutons ──────────────────────────────────────────────────────

  int get aidTotal => aidMoutons.length;
  int get aidDisponibles => aidMoutons.where((m) => m.isAvailable).length;
  int get aidReserves => aidMoutons.where((m) => m.reserved && !m.sold).length;
  int get aidVendus => aidMoutons.where((m) => m.sold).length;
  double get aidBeneficeTotal => aidMoutons
      .where((m) => m.sold && m.prixVente > 0)
      .fold(0, (sum, item) => sum + item.benefice);

  Future<bool> addAidMouton(AidMouton mouton) async {
    final exists =
        aidMoutons.any((m) => m.numero.trim() == mouton.numero.trim());
    if (exists) return false;
    await _db.insertAidMouton(mouton);
    aidMoutons = await _db.getAidMoutons();
    notifyListeners();
    return true;
  }

  Future<void> updateAidMouton(AidMouton mouton) async {
    await _db.updateAidMouton(mouton);
    aidMoutons = await _db.getAidMoutons();
    notifyListeners();
  }

  Future<void> deleteAidMouton(String id) async {
    await _db.deleteAidMouton(id);
    aidMoutons.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Récoltes ─────────────────────────────────────────────────────────

  Future<void> addRecolte(Recolte recolte) async {
    await _db.insertRecolte(recolte);
    recoltes = await _db.getRecoltes();
    notifyListeners();
  }

  Future<void> deleteRecolte(String id) async {
    await _db.deleteRecolte(id);
    recoltes.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Triturations ─────────────────────────────────────────────────────

  Future<void> addTrituration(Trituration t) async {
    await _db.insertTrituration(t);

    if (t.coutTrituration > 0) {
      await _db.insertDepense(Depense(
        montant: t.coutTrituration,
        date: t.date,
        categorie: 'Trituration',
        remarque:
            'Moulin ${t.saison} · ${t.kgOlives.toStringAsFixed(0)} kg olives',
        fermeId: t.fermeId,
      ));
      depenses = await _db.getDepenses();
    }

    if (t.revenusVente > 0) {
      await _db.insertRevenu(Revenu(
        montant: t.revenusVente,
        date: t.date,
        categorie: "Vente huile d'olive",
        remarque:
            '${t.litresVente.toStringAsFixed(1)} L × ${t.prixVenteLitre.toStringAsFixed(0)} MAD/L',
        fermeId: t.fermeId,
      ));
      revenus = await _db.getRevenus();
    }

    triturations = await _db.getTriturations();
    notifyListeners();
  }

  Future<void> deleteTrituration(String id) async {
    await _db.deleteTrituration(id);
    triturations.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Travailleurs ─────────────────────────────────────────────────────

  Future<void> addTravailleurSession(TravailleurSession session) async {
    await _db.insertTravailleurSession(session);

    await _db.insertDepense(Depense(
      montant: session.total,
      date: session.date,
      categorie: "Main-d'œuvre",
      remarque:
          '${session.nom} · ${session.nbJours.toStringAsFixed(1)} j × ${session.salaireJournalier.toStringAsFixed(0)} MAD',
      fermeId: session.fermeId,
    ));
    depenses = await _db.getDepenses();

    travailleurSessions = await _db.getTravailleurSessions();
    notifyListeners();
  }

  Future<void> deleteTravailleurSession(String id) async {
    await _db.deleteTravailleurSession(id);
    travailleurSessions.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ─── CRUD Récurrents ───────────────────────────────────────────────────────

  Future<void> addRecurringExpense(RecurringExpense re) async {
    await _db.insertRecurringExpense(re);
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  Future<void> toggleRecurringExpense(RecurringExpense re) async {
    final updated = re.copyWith(actif: !re.actif);
    await _db.updateRecurringExpense(updated);
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  Future<void> deleteRecurringExpense(String id) async {
    await _db.deleteRecurringExpense(id);
    recurringExpenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> payRecurring(RecurringExpense re) async {
    final updated = re.copyWith(lastPaidAt: DateTime.now());
    await _db.updateRecurringExpense(updated);

    await _db.insertDepense(Depense(
      montant: re.montant,
      date: DateTime.now(),
      categorie: "Main-d'œuvre",
      remarque: re.label,
      fermeId: re.fermeId,
    ));

    depenses = await _db.getDepenses();
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  // ─── Clear All ─────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _db.clearAll();
    mouvements = <Mouvement>[];
    depenses = <Depense>[];
    revenus = <Revenu>[];
    aidMoutons = <AidMouton>[];
    recoltes = <Recolte>[];
    triturations = <Trituration>[];
    travailleurSessions = <TravailleurSession>[];
    recurringExpenses = <RecurringExpense>[];
    notifyListeners();
  }
}
