import 'package:uuid/uuid.dart';

const _uuid = Uuid();

const Map<String, String> fermeNames = {
  'rhamna': 'Ferme Rhamna',
  'srahna': 'Ferme Srahna',
};

const List<String> cultureTypes = [
  'Olives',
  "Huile d'olive",
  'Citrons',
  'Figues',
  'Fruits divers',
  'Luzerne',
  'Autre',
];

const Map<String, String> cultureEmojis = {
  'Olives': '🫒',
  "Huile d'olive": '🫙',
  'Citrons': '🍋',
  'Figues': '🍑',
  'Fruits divers': '🍎',
  'Luzerne': '🌿',
  'Autre': '🌱',
};

const Map<String, String> cultureUnites = {
  'Olives': 'kg',
  "Huile d'olive": 'litres',
  'Citrons': 'kg',
  'Figues': 'kg',
  'Fruits divers': 'kg',
  'Luzerne': 'kg',
  'Autre': 'kg',
};

// ─── Récolte ─────────────────────────────────────────────────────────────────

class Recolte {
  final String id;
  final String fermeId;
  final String culture;
  final int saison;
  final double quantite;
  final String unite;
  final double quantiteVente;
  final double quantiteInterne;
  final DateTime date;
  final String remarque;

  Recolte({
    String? id,
    required this.fermeId,
    required this.culture,
    required this.saison,
    required this.quantite,
    this.unite = 'kg',
    this.quantiteVente = 0,
    this.quantiteInterne = 0,
    required this.date,
    this.remarque = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'culture': culture,
        'saison': saison,
        'quantite': quantite,
        'unite': unite,
        'quantiteVente': quantiteVente,
        'quantiteInterne': quantiteInterne,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
      };

  factory Recolte.fromMap(Map<String, dynamic> map) => Recolte(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        culture: map['culture'] as String,
        saison: map['saison'] as int,
        quantite: (map['quantite'] as num).toDouble(),
        unite: (map['unite'] ?? 'kg') as String,
        quantiteVente: (map['quantiteVente'] as num? ?? 0).toDouble(),
        quantiteInterne: (map['quantiteInterne'] as num? ?? 0).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
      );
}

// ─── Trituration ─────────────────────────────────────────────────────────────

class Trituration {
  final String id;
  final String fermeId;
  final int saison;
  final double kgOlives;
  final double litresHuile;
  final double coutTrituration;
  final double litresVente;
  final double litresFamille;
  final double litresHeritiers;
  final double prixVenteLitre;
  final DateTime date;
  final String remarque;

  Trituration({
    String? id,
    required this.fermeId,
    required this.saison,
    required this.kgOlives,
    required this.litresHuile,
    this.coutTrituration = 0,
    this.litresVente = 0,
    this.litresFamille = 0,
    this.litresHeritiers = 0,
    this.prixVenteLitre = 0,
    required this.date,
    this.remarque = '',
  }) : id = id ?? _uuid.v4();

  double get rendementPct => kgOlives > 0 ? (litresHuile / kgOlives * 100) : 0;
  double get revenusVente => litresVente * prixVenteLitre;
  double get litresTotal => litresVente + litresFamille + litresHeritiers;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'saison': saison,
        'kgOlives': kgOlives,
        'litresHuile': litresHuile,
        'coutTrituration': coutTrituration,
        'litresVente': litresVente,
        'litresFamille': litresFamille,
        'litresHeritiers': litresHeritiers,
        'prixVenteLitre': prixVenteLitre,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
      };

  factory Trituration.fromMap(Map<String, dynamic> map) => Trituration(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        saison: map['saison'] as int,
        kgOlives: (map['kgOlives'] as num).toDouble(),
        litresHuile: (map['litresHuile'] as num).toDouble(),
        coutTrituration: (map['coutTrituration'] as num? ?? 0).toDouble(),
        litresVente: (map['litresVente'] as num? ?? 0).toDouble(),
        litresFamille: (map['litresFamille'] as num? ?? 0).toDouble(),
        litresHeritiers: (map['litresHeritiers'] as num? ?? 0).toDouble(),
        prixVenteLitre: (map['prixVenteLitre'] as num? ?? 0).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
      );
}

// ─── TravailleurSession ───────────────────────────────────────────────────────

class TravailleurSession {
  final String id;
  final String fermeId;
  final String nom;
  final double nbJours;
  final double salaireJournalier;
  final DateTime date;
  final String remarque;

  TravailleurSession({
    String? id,
    required this.fermeId,
    required this.nom,
    required this.nbJours,
    required this.salaireJournalier,
    required this.date,
    this.remarque = '',
  }) : id = id ?? _uuid.v4();

  double get total => nbJours * salaireJournalier;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'nom': nom,
        'nbJours': nbJours,
        'salaireJournalier': salaireJournalier,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
      };

  factory TravailleurSession.fromMap(Map<String, dynamic> map) =>
      TravailleurSession(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        nom: map['nom'] as String,
        nbJours: (map['nbJours'] as num).toDouble(),
        salaireJournalier: (map['salaireJournalier'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
      );
}

// ─── RecurringExpense ─────────────────────────────────────────────────────────

class RecurringExpense {
  final String id;
  final String label;
  final double montant;
  final String fermeId;
  final bool actif;
  final DateTime createdAt;
  final DateTime? lastPaidAt;

  RecurringExpense({
    String? id,
    required this.label,
    required this.montant,
    required this.fermeId,
    this.actif = true,
    DateTime? createdAt,
    this.lastPaidAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isDueThisWeek {
    if (!actif) return false;
    if (lastPaidAt == null) return true;
    return DateTime.now().difference(lastPaidAt!).inDays >= 7;
  }

  RecurringExpense copyWith({
    String? label,
    double? montant,
    String? fermeId,
    bool? actif,
    DateTime? lastPaidAt,
  }) =>
      RecurringExpense(
        id: id,
        label: label ?? this.label,
        montant: montant ?? this.montant,
        fermeId: fermeId ?? this.fermeId,
        actif: actif ?? this.actif,
        createdAt: createdAt,
        lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'montant': montant,
        'fermeId': fermeId,
        'actif': actif ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'lastPaidAt': lastPaidAt?.toIso8601String(),
      };

  factory RecurringExpense.fromMap(Map<String, dynamic> map) => RecurringExpense(
        id: map['id'] as String,
        label: map['label'] as String,
        montant: (map['montant'] as num).toDouble(),
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        actif: (map['actif'] as int? ?? 1) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastPaidAt: map['lastPaidAt'] != null &&
                (map['lastPaidAt'] as String).isNotEmpty
            ? DateTime.parse(map['lastPaidAt'] as String)
            : null,
      );
}
