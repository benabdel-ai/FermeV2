import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Mouvement {
  final String id;
  final String type;
  final int qte;
  final DateTime date;
  final String remarque;
  final String fermeId;

  Mouvement({
    String? id,
    required this.type,
    required this.qte,
    required this.date,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'qte': qte,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Mouvement.fromMap(Map<String, dynamic> map) => Mouvement(
        id: map['id'] as String,
        type: map['type'] as String,
        qte: map['qte'] as int,
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );

  String get label => mvtLabels[type] ?? type;
  String get emoji => mvtEmojis[type] ?? '📋';
  MvtColor get color => mvtColors[type] ?? MvtColor.green;
}

enum MvtColor { green, red, blue, gold }

const mvtLabels = {
  'init_femelles': 'Stock initial · Femelles',
  'init_males': 'Stock initial · Mâles',
  'init_agf': 'Stock initial · Agneaux ♀',
  'init_agm': 'Stock initial · Agneaux ♂',
  'naissance_agf': 'Naissance · Agneau ♀',
  'naissance_agm': 'Naissance · Agneau ♂',
  'achat_femelle': 'Achat · Femelle',
  'achat_male': 'Achat · Mâle',
  'vente_femelle': 'Vente · Femelle',
  'vente_male': 'Vente · Mâle',
  'deces_femelle': 'Décès · Femelle',
  'deces_male': 'Décès · Mâle',
  'passage_agf': 'Passage Agneau ♀ → Femelle',
  'passage_agm': 'Passage Agneau ♂ → Mâle',
};

const mvtEmojis = {
  'init_femelles': '🐑',
  'init_males': '🐏',
  'init_agf': '🍼',
  'init_agm': '🐣',
  'naissance_agf': '🍼',
  'naissance_agm': '🐣',
  'achat_femelle': '🛒',
  'achat_male': '🛒',
  'vente_femelle': '🤝',
  'vente_male': '🤝',
  'deces_femelle': '💀',
  'deces_male': '💀',
  'passage_agf': '🔄',
  'passage_agm': '🔄',
};

const mvtColors = {
  'init_femelles': MvtColor.green,
  'init_males': MvtColor.green,
  'init_agf': MvtColor.green,
  'init_agm': MvtColor.green,
  'naissance_agf': MvtColor.green,
  'naissance_agm': MvtColor.green,
  'achat_femelle': MvtColor.blue,
  'achat_male': MvtColor.blue,
  'vente_femelle': MvtColor.gold,
  'vente_male': MvtColor.gold,
  'deces_femelle': MvtColor.red,
  'deces_male': MvtColor.red,
  'passage_agf': MvtColor.blue,
  'passage_agm': MvtColor.blue,
};

class Depense {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String fermeId;

  Depense({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Depense.fromMap(Map<String, dynamic> map) => Depense(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );
}

class Revenu {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String fermeId;

  Revenu({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Revenu.fromMap(Map<String, dynamic> map) => Revenu(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );
}

class Stock {
  final int femelles;
  final int males;
  final int agneauxF;
  final int agneauxM;

  const Stock({
    this.femelles = 0,
    this.males = 0,
    this.agneauxF = 0,
    this.agneauxM = 0,
  });

  int get total => femelles + males + agneauxF + agneauxM;

  Stock apply(String type, int qte) {
    var f = femelles;
    var m = males;
    var af = agneauxF;
    var am = agneauxM;

    switch (type) {
      case 'init_femelles':
        f += qte;
        break;
      case 'init_males':
        m += qte;
        break;
      case 'init_agf':
        af += qte;
        break;
      case 'init_agm':
        am += qte;
        break;
      case 'naissance_agf':
        af += qte;
        break;
      case 'naissance_agm':
        am += qte;
        break;
      case 'achat_femelle':
        f += qte;
        break;
      case 'achat_male':
        m += qte;
        break;
      case 'vente_femelle':
      case 'deces_femelle':
        f = (f - qte).clamp(0, 999999);
        break;
      case 'vente_male':
      case 'deces_male':
        m = (m - qte).clamp(0, 999999);
        break;
      case 'passage_agf':
        af = (af - qte).clamp(0, 999999);
        f += qte;
        break;
      case 'passage_agm':
        am = (am - qte).clamp(0, 999999);
        m += qte;
        break;
    }

    return Stock(femelles: f, males: m, agneauxF: af, agneauxM: am);
  }
}

const depCategories = <String>[
  'Alimentation',
  'Vétérinaire',
  'Transport',
  'Achat bétail',
  "Main-d'œuvre",
  'Équipement',
  'Eau / Électricité',
  'Trituration',
  'Engrais / Produits',
  'Autre',
];

const revCategories = <String>[
  'Vente brebis',
  'Vente bélier',
  'Vente agneau mâle',
  'Vente agneau femelle',
  "Vente huile d'olive",
  'Vente olives',
  'Vente luzerne',
  'Vente fruits',
  'Lait',
  'Fumier',
  'Autre',
];

class AidMouton {
  final String id;
  final String numero;
  final String race;
  final double prixAchat;
  final double coutRevient;
  final bool sold;
  final bool reserved;
  final double prixVente;
  final String acheteur;
  final DateTime createdAt;
  final DateTime? reservedAt;
  final DateTime? soldAt;

  AidMouton({
    String? id,
    required this.numero,
    required this.race,
    required this.prixAchat,
    this.coutRevient = 0,
    this.sold = false,
    this.reserved = false,
    this.prixVente = 0,
    this.acheteur = '',
    DateTime? createdAt,
    this.reservedAt,
    this.soldAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  double get coutTotal => prixAchat + coutRevient;
  double get benefice => prixVente - coutTotal;
  bool get isAvailable => !sold && !reserved;

  AidMouton copyWith({
    String? id,
    String? numero,
    String? race,
    double? prixAchat,
    double? coutRevient,
    bool? sold,
    bool? reserved,
    double? prixVente,
    String? acheteur,
    DateTime? createdAt,
    DateTime? reservedAt,
    DateTime? soldAt,
  }) {
    return AidMouton(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      race: race ?? this.race,
      prixAchat: prixAchat ?? this.prixAchat,
      coutRevient: coutRevient ?? this.coutRevient,
      sold: sold ?? this.sold,
      reserved: reserved ?? this.reserved,
      prixVente: prixVente ?? this.prixVente,
      acheteur: acheteur ?? this.acheteur,
      createdAt: createdAt ?? this.createdAt,
      reservedAt: reservedAt ?? this.reservedAt,
      soldAt: soldAt ?? this.soldAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'numero': numero,
        'race': race,
        'prixAchat': prixAchat,
        'coutRevient': coutRevient,
        'sold': sold ? 1 : 0,
        'reserved': reserved ? 1 : 0,
        'prixVente': prixVente,
        'acheteur': acheteur,
        'createdAt': createdAt.toIso8601String(),
        'reservedAt': reservedAt?.toIso8601String(),
        'soldAt': soldAt?.toIso8601String(),
      };

  factory AidMouton.fromMap(Map<String, dynamic> map) => AidMouton(
        id: map['id'] as String,
        numero: map['numero'] as String,
        race: map['race'] as String,
        prixAchat: (map['prixAchat'] as num).toDouble(),
        coutRevient: (map['coutRevient'] as num? ?? 0).toDouble(),
        sold: (map['sold'] as int? ?? 0) == 1,
        reserved: (map['reserved'] as int? ?? 0) == 1,
        prixVente: (map['prixVente'] as num? ?? 0).toDouble(),
        acheteur: (map['acheteur'] ?? '') as String,
        createdAt: DateTime.parse(
            (map['createdAt'] ?? DateTime.now().toIso8601String()) as String),
        reservedAt:
            map['reservedAt'] != null && (map['reservedAt'] as String).isNotEmpty
                ? DateTime.parse(map['reservedAt'] as String)
                : null,
        soldAt: map['soldAt'] != null && (map['soldAt'] as String).isNotEmpty
            ? DateTime.parse(map['soldAt'] as String)
            : null,
      );
}

const aidRaces = <String>[
  'Sardi',
  'Bergui',
  'Timahdite',
  "D'man",
  'Boujaâd',
  'Autre',
];
