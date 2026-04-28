import 'dart:convert';

// ─── CAMPAIGN ────────────────────────────────────────────────────────────────
class Campaign {
  final String id;
  String name;
  String type; // Sponsored Products, Sponsored Brands, Sponsored Display
  String asin;
  String product;
  DateTime startDate;
  String status; // Active, Paused, Draft, Ended
  double dailyBudget;
  double sellingPrice;
  double netMargin;
  double bidAuto;
  double bidBroad;
  double bidExact;
  double topOfSearchAdj;
  String notes;

  Campaign({
    required this.id,
    required this.name,
    this.type = 'Sponsored Products',
    this.asin = '',
    this.product = '',
    required this.startDate,
    this.status = 'Active',
    this.dailyBudget = 0,
    this.sellingPrice = 0,
    this.netMargin = 0,
    this.bidAuto = 0,
    this.bidBroad = 0,
    this.bidExact = 0,
    this.topOfSearchAdj = 0,
    this.notes = '',
  });

  double get breakEvenAcos => netMargin;
  double get targetAcos => netMargin * 0.7;

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'type': type, 'asin': asin, 'product': product,
        'startDate': startDate.toIso8601String(), 'status': status,
        'dailyBudget': dailyBudget, 'sellingPrice': sellingPrice,
        'netMargin': netMargin, 'bidAuto': bidAuto, 'bidBroad': bidBroad,
        'bidExact': bidExact, 'topOfSearchAdj': topOfSearchAdj, 'notes': notes,
      };

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
        id: j['id'], name: j['name'], type: j['type'] ?? 'Sponsored Products',
        asin: j['asin'] ?? '', product: j['product'] ?? '',
        startDate: DateTime.parse(j['startDate']), status: j['status'] ?? 'Active',
        dailyBudget: (j['dailyBudget'] ?? 0).toDouble(),
        sellingPrice: (j['sellingPrice'] ?? 0).toDouble(),
        netMargin: (j['netMargin'] ?? 0).toDouble(),
        bidAuto: (j['bidAuto'] ?? 0).toDouble(),
        bidBroad: (j['bidBroad'] ?? 0).toDouble(),
        bidExact: (j['bidExact'] ?? 0).toDouble(),
        topOfSearchAdj: (j['topOfSearchAdj'] ?? 0).toDouble(),
        notes: j['notes'] ?? '',
      );
}

// ─── DAILY LOG ───────────────────────────────────────────────────────────────
class DailyLog {
  final String id;
  String campaignId;
  DateTime date;
  int impressions;
  int clicks;
  int orders;
  double spend;
  double adSales;
  double totalSales;
  double budget;
  String topKeyword;
  double topKwAcos;
  String notes;

  DailyLog({
    required this.id,
    required this.campaignId,
    required this.date,
    this.impressions = 0,
    this.clicks = 0,
    this.orders = 0,
    this.spend = 0,
    this.adSales = 0,
    this.totalSales = 0,
    this.budget = 0,
    this.topKeyword = '',
    this.topKwAcos = 0,
    this.notes = '',
  });

  double get ctr => impressions > 0 ? clicks / impressions : 0;
  double get avgCpc => clicks > 0 ? spend / clicks : 0;
  double get acos => adSales > 0 ? spend / adSales : 0;
  double get tacos => totalSales > 0 ? spend / totalSales : 0;
  double get roas => spend > 0 ? adSales / spend : 0;
  double get cvr => clicks > 0 ? orders / clicks : 0;
  double get budgetUsed => budget > 0 ? spend / budget : 0;
  int get healthScore {
    double score = 100;
    if (acos > 0.3) score -= (acos - 0.3) * 200;
    if (cvr < 0.08 && clicks > 0) score -= (0.08 - cvr) * 300;
    return score.clamp(0, 100).round();
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'campaignId': campaignId, 'date': date.toIso8601String(),
        'impressions': impressions, 'clicks': clicks, 'orders': orders,
        'spend': spend, 'adSales': adSales, 'totalSales': totalSales,
        'budget': budget, 'topKeyword': topKeyword, 'topKwAcos': topKwAcos,
        'notes': notes,
      };

  factory DailyLog.fromJson(Map<String, dynamic> j) => DailyLog(
        id: j['id'], campaignId: j['campaignId'],
        date: DateTime.parse(j['date']),
        impressions: j['impressions'] ?? 0, clicks: j['clicks'] ?? 0,
        orders: j['orders'] ?? 0,
        spend: (j['spend'] ?? 0).toDouble(), adSales: (j['adSales'] ?? 0).toDouble(),
        totalSales: (j['totalSales'] ?? 0).toDouble(),
        budget: (j['budget'] ?? 0).toDouble(),
        topKeyword: j['topKeyword'] ?? '', topKwAcos: (j['topKwAcos'] ?? 0).toDouble(),
        notes: j['notes'] ?? '',
      );
}

// ─── KEYWORD ─────────────────────────────────────────────────────────────────
class Keyword {
  final String id;
  String campaignId;
  String term;
  String matchType; // Exact, Broad, Phrase, Auto
  String status;
  int impressions;
  int clicks;
  int orders;
  double spend;
  double sales;
  double bid;
  DateTime lastUpdated;

  Keyword({
    required this.id,
    required this.campaignId,
    required this.term,
    this.matchType = 'Exact',
    this.status = 'Active',
    this.impressions = 0,
    this.clicks = 0,
    this.orders = 0,
    this.spend = 0,
    this.sales = 0,
    this.bid = 0,
    required this.lastUpdated,
  });

  double get ctr => impressions > 0 ? clicks / impressions : 0;
  double get acos => sales > 0 ? spend / sales : 0;
  double get cvr => clicks > 0 ? orders / clicks : 0;

  String get action {
    if (sales == 0 && spend > 0) return '❌ NEGATIVE';
    if (acos < 0.25 && orders > 0) return '✅ HARVEST';
    if (acos < 0.4 && orders > 0) return '👀 WATCH';
    if (acos > 0.6) return '❌ NEGATIVE';
    if (acos >= 0.4) return '⚠️ REDUCE BID';
    return '—';
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'campaignId': campaignId, 'term': term, 'matchType': matchType,
        'status': status, 'impressions': impressions, 'clicks': clicks,
        'orders': orders, 'spend': spend, 'sales': sales, 'bid': bid,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Keyword.fromJson(Map<String, dynamic> j) => Keyword(
        id: j['id'], campaignId: j['campaignId'], term: j['term'],
        matchType: j['matchType'] ?? 'Exact', status: j['status'] ?? 'Active',
        impressions: j['impressions'] ?? 0, clicks: j['clicks'] ?? 0,
        orders: j['orders'] ?? 0,
        spend: (j['spend'] ?? 0).toDouble(), sales: (j['sales'] ?? 0).toDouble(),
        bid: (j['bid'] ?? 0).toDouble(),
        lastUpdated: DateTime.parse(j['lastUpdated']),
      );
}
