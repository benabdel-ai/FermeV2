import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'troupeau_ovins.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE mouvements (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            qte INTEGER NOT NULL,
            date TEXT NOT NULL,
            remarque TEXT DEFAULT '',
            fermeId TEXT NOT NULL DEFAULT 'rhamna'
          )
        ''');

        await database.execute('''
          CREATE TABLE depenses (
            id TEXT PRIMARY KEY,
            montant REAL NOT NULL,
            date TEXT NOT NULL,
            categorie TEXT NOT NULL,
            remarque TEXT DEFAULT '',
            fermeId TEXT NOT NULL DEFAULT 'rhamna'
          )
        ''');

        await database.execute('''
          CREATE TABLE revenus (
            id TEXT PRIMARY KEY,
            montant REAL NOT NULL,
            date TEXT NOT NULL,
            categorie TEXT NOT NULL,
            remarque TEXT DEFAULT '',
            fermeId TEXT NOT NULL DEFAULT 'rhamna'
          )
        ''');

        await _createAidTable(database);
        await _createFermeTables(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAidTable(database);
        }
        if (oldVersion < 3) {
          await database.execute(
              "ALTER TABLE mouvements ADD COLUMN fermeId TEXT NOT NULL DEFAULT 'rhamna'");
          await database.execute(
              "ALTER TABLE depenses ADD COLUMN fermeId TEXT NOT NULL DEFAULT 'rhamna'");
          await database.execute(
              "ALTER TABLE revenus ADD COLUMN fermeId TEXT NOT NULL DEFAULT 'rhamna'");
          await _createFermeTables(database);
        }
      },
    );
  }

  Future<void> _createAidTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS aid_moutons (
        id TEXT PRIMARY KEY,
        numero TEXT NOT NULL UNIQUE,
        race TEXT NOT NULL,
        prixAchat REAL NOT NULL,
        coutRevient REAL NOT NULL DEFAULT 0,
        sold INTEGER NOT NULL DEFAULT 0,
        reserved INTEGER NOT NULL DEFAULT 0,
        prixVente REAL NOT NULL DEFAULT 0,
        acheteur TEXT DEFAULT '',
        createdAt TEXT NOT NULL,
        reservedAt TEXT,
        soldAt TEXT
      )
    ''');
  }

  Future<void> _createFermeTables(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS recoltes (
        id TEXT PRIMARY KEY,
        fermeId TEXT NOT NULL,
        culture TEXT NOT NULL,
        saison INTEGER NOT NULL,
        quantite REAL NOT NULL,
        unite TEXT NOT NULL DEFAULT 'kg',
        quantiteVente REAL NOT NULL DEFAULT 0,
        quantiteInterne REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        remarque TEXT DEFAULT ''
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS triturations (
        id TEXT PRIMARY KEY,
        fermeId TEXT NOT NULL,
        saison INTEGER NOT NULL,
        kgOlives REAL NOT NULL,
        litresHuile REAL NOT NULL,
        coutTrituration REAL NOT NULL DEFAULT 0,
        litresVente REAL NOT NULL DEFAULT 0,
        litresFamille REAL NOT NULL DEFAULT 0,
        litresHeritiers REAL NOT NULL DEFAULT 0,
        prixVenteLitre REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        remarque TEXT DEFAULT ''
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS travailleur_sessions (
        id TEXT PRIMARY KEY,
        fermeId TEXT NOT NULL,
        nom TEXT NOT NULL,
        nbJours REAL NOT NULL,
        salaireJournalier REAL NOT NULL,
        date TEXT NOT NULL,
        remarque TEXT DEFAULT ''
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS recurring_expenses (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        montant REAL NOT NULL,
        fermeId TEXT NOT NULL,
        actif INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastPaidAt TEXT
      )
    ''');
  }

  // ─── Mouvements ────────────────────────────────────────────────────────────

  Future<List<Mouvement>> getMouvements() async {
    final database = await db;
    final rows = await database.query('mouvements', orderBy: 'date ASC');
    return rows.map(Mouvement.fromMap).toList();
  }

  Future<void> insertMouvement(Mouvement mouvement) async {
    final database = await db;
    await database.insert('mouvements', mouvement.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMouvement(String id) async {
    final database = await db;
    await database.delete('mouvements', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Dépenses ──────────────────────────────────────────────────────────────

  Future<List<Depense>> getDepenses() async {
    final database = await db;
    final rows = await database.query('depenses', orderBy: 'date DESC');
    return rows.map(Depense.fromMap).toList();
  }

  Future<void> insertDepense(Depense depense) async {
    final database = await db;
    await database.insert('depenses', depense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteDepense(String id) async {
    final database = await db;
    await database.delete('depenses', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Revenus ───────────────────────────────────────────────────────────────

  Future<List<Revenu>> getRevenus() async {
    final database = await db;
    final rows = await database.query('revenus', orderBy: 'date DESC');
    return rows.map(Revenu.fromMap).toList();
  }

  Future<void> insertRevenu(Revenu revenu) async {
    final database = await db;
    await database.insert('revenus', revenu.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRevenu(String id) async {
    final database = await db;
    await database.delete('revenus', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Aid Moutons ───────────────────────────────────────────────────────────

  Future<List<AidMouton>> getAidMoutons() async {
    final database = await db;
    final rows =
        await database.query('aid_moutons', orderBy: 'createdAt DESC');
    return rows.map(AidMouton.fromMap).toList();
  }

  Future<void> insertAidMouton(AidMouton mouton) async {
    final database = await db;
    await database.insert('aid_moutons', mouton.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> updateAidMouton(AidMouton mouton) async {
    final database = await db;
    await database.update('aid_moutons', mouton.toMap(),
        where: 'id = ?', whereArgs: [mouton.id]);
  }

  Future<void> deleteAidMouton(String id) async {
    final database = await db;
    await database.delete('aid_moutons', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Récoltes ──────────────────────────────────────────────────────────────

  Future<List<Recolte>> getRecoltes() async {
    final database = await db;
    final rows = await database.query('recoltes', orderBy: 'date DESC');
    return rows.map(Recolte.fromMap).toList();
  }

  Future<void> insertRecolte(Recolte recolte) async {
    final database = await db;
    await database.insert('recoltes', recolte.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRecolte(String id) async {
    final database = await db;
    await database.delete('recoltes', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Triturations ──────────────────────────────────────────────────────────

  Future<List<Trituration>> getTriturations() async {
    final database = await db;
    final rows = await database.query('triturations', orderBy: 'date DESC');
    return rows.map(Trituration.fromMap).toList();
  }

  Future<void> insertTrituration(Trituration t) async {
    final database = await db;
    await database.insert('triturations', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTrituration(String id) async {
    final database = await db;
    await database.delete('triturations', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Travailleur Sessions ──────────────────────────────────────────────────

  Future<List<TravailleurSession>> getTravailleurSessions() async {
    final database = await db;
    final rows =
        await database.query('travailleur_sessions', orderBy: 'date DESC');
    return rows.map(TravailleurSession.fromMap).toList();
  }

  Future<void> insertTravailleurSession(TravailleurSession session) async {
    final database = await db;
    await database.insert('travailleur_sessions', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTravailleurSession(String id) async {
    final database = await db;
    await database
        .delete('travailleur_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Recurring Expenses ────────────────────────────────────────────────────

  Future<List<RecurringExpense>> getRecurringExpenses() async {
    final database = await db;
    final rows =
        await database.query('recurring_expenses', orderBy: 'createdAt ASC');
    return rows.map(RecurringExpense.fromMap).toList();
  }

  Future<void> insertRecurringExpense(RecurringExpense re) async {
    final database = await db;
    await database.insert('recurring_expenses', re.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecurringExpense(RecurringExpense re) async {
    final database = await db;
    await database.update('recurring_expenses', re.toMap(),
        where: 'id = ?', whereArgs: [re.id]);
  }

  Future<void> deleteRecurringExpense(String id) async {
    final database = await db;
    await database
        .delete('recurring_expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Clear All ─────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('mouvements');
    await database.delete('depenses');
    await database.delete('revenus');
    await database.delete('aid_moutons');
    await database.delete('recoltes');
    await database.delete('triturations');
    await database.delete('travailleur_sessions');
    await database.delete('recurring_expenses');
  }
}
