import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class AppStore extends ChangeNotifier {
  List<Campaign> campaigns = [];
  List<DailyLog> dailyLogs = [];
  List<Keyword> keywords = [];

  AppStore() {
    _load();
  }

  // ── PERSISTENCE ──────────────────────────────────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final c = prefs.getString('campaigns');
    final d = prefs.getString('dailyLogs');
    final k = prefs.getString('keywords');
    if (c != null) {
      campaigns = (jsonDecode(c) as List).map((e) => Campaign.fromJson(e)).toList();
    }
    if (d != null) {
      dailyLogs = (jsonDecode(d) as List).map((e) => DailyLog.fromJson(e)).toList();
    }
    if (k != null) {
      keywords = (jsonDecode(k) as List).map((e) => Keyword.fromJson(e)).toList();
    }
    if (campaigns.isEmpty) _seedDemoData();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('campaigns', jsonEncode(campaigns.map((e) => e.toJson()).toList()));
    await prefs.setString('dailyLogs', jsonEncode(dailyLogs.map((e) => e.toJson()).toList()));
    await prefs.setString('keywords', jsonEncode(keywords.map((e) => e.toJson()).toList()));
  }

  // ── DEMO DATA ─────────────────────────────────────────────────────────────
  void _seedDemoData() {
    final c1 = Campaign(
      id: _uuid.v4(), name: 'Divya Sutra — Auto Discovery',
      type: 'Sponsored Products', asin: 'B0EXAMPLE1', product: 'Tulsi Mala 108 Beads',
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      status: 'Active', dailyBudget: 300, sellingPrice: 499,
      netMargin: 0.35, bidAuto: 8, bidBroad: 10, bidExact: 15, topOfSearchAdj: 20,
    );
    final c2 = Campaign(
      id: _uuid.v4(), name: 'Divya Sutra — Manual Exact',
      type: 'Sponsored Products', asin: 'B0EXAMPLE1', product: 'Tulsi Mala 108 Beads',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      status: 'Active', dailyBudget: 400, sellingPrice: 499,
      netMargin: 0.35, bidAuto: 0, bidBroad: 0, bidExact: 18, topOfSearchAdj: 25,
    );
    campaigns = [c1, c2];

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      dailyLogs.add(DailyLog(
        id: _uuid.v4(), campaignId: c1.id, date: d,
        impressions: 3200 + (i * 120), clicks: 64 + (i * 3),
        orders: 4 + (i % 3), spend: 280 + (i * 8).toDouble(),
        adSales: 1100 + (i * 40).toDouble(), totalSales: 1600 + (i * 55).toDouble(),
        budget: 300, topKeyword: 'tulsi mala 108 beads', topKwAcos: 0.22,
        notes: i == 0 ? 'Good CTR today. Monitor ACOS.' : '',
      ));
      dailyLogs.add(DailyLog(
        id: _uuid.v4(), campaignId: c2.id, date: d,
        impressions: 1800 + (i * 80), clicks: 45 + (i * 2),
        orders: 6 + (i % 2), spend: 350 + (i * 12).toDouble(),
        adSales: 1800 + (i * 60).toDouble(), totalSales: 2200 + (i * 70).toDouble(),
        budget: 400, topKeyword: 'original tulsi mala', topKwAcos: 0.18,
        notes: '',
      ));
    }

    final kwTerms = [
      ('tulsi mala 108 beads', 'Exact', 320, 18, 3, 140.0, 580.0, 15.0),
      ('tulsi mala original', 'Exact', 280, 14, 2, 112.0, 420.0, 15.0),
      ('rudraksha mala', 'Broad', 180, 6, 0, 54.0, 0.0, 10.0),
      ('meditation beads', 'Broad', 420, 22, 1, 154.0, 280.0, 10.0),
      ('buy mala online', 'Broad', 95, 3, 0, 24.0, 0.0, 8.0),
      ('tulsi mala benefits', 'Phrase', 210, 8, 1, 64.0, 180.0, 12.0),
    ];
    for (final t in kwTerms) {
      keywords.add(Keyword(
        id: _uuid.v4(), campaignId: c1.id, term: t.$1,
        matchType: t.$2, status: 'Active',
        impressions: t.$3, clicks: t.$4, orders: t.$5,
        spend: t.$6, sales: t.$7, bid: t.$8,
        lastUpdated: now,
      ));
    }
  }

  // ── CAMPAIGNS ─────────────────────────────────────────────────────────────
  void addCampaign(Campaign c) { campaigns.add(c); _save(); notifyListeners(); }
  void updateCampaign(Campaign c) {
    final i = campaigns.indexWhere((x) => x.id == c.id);
    if (i != -1) { campaigns[i] = c; _save(); notifyListeners(); }
  }
  void deleteCampaign(String id) {
    campaigns.removeWhere((c) => c.id == id);
    dailyLogs.removeWhere((d) => d.campaignId == id);
    keywords.removeWhere((k) => k.campaignId == id);
    _save(); notifyListeners();
  }

  // ── DAILY LOGS ────────────────────────────────────────────────────────────
  void addLog(DailyLog log) { dailyLogs.add(log); _save(); notifyListeners(); }
  void updateLog(DailyLog log) {
    final i = dailyLogs.indexWhere((x) => x.id == log.id);
    if (i != -1) { dailyLogs[i] = log; _save(); notifyListeners(); }
  }
  void deleteLog(String id) {
    dailyLogs.removeWhere((l) => l.id == id);
    _save(); notifyListeners();
  }
  List<DailyLog> logsForCampaign(String campaignId) =>
      dailyLogs.where((l) => l.campaignId == campaignId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<DailyLog> recentLogs({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return dailyLogs.where((l) => l.date.isAfter(cutoff)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── KEYWORDS ─────────────────────────────────────────────────────────────
  void addKeyword(Keyword kw) { keywords.add(kw); _save(); notifyListeners(); }
  void updateKeyword(Keyword kw) {
    final i = keywords.indexWhere((x) => x.id == kw.id);
    if (i != -1) { keywords[i] = kw; _save(); notifyListeners(); }
  }
  void deleteKeyword(String id) {
    keywords.removeWhere((k) => k.id == id);
    _save(); notifyListeners();
  }
  List<Keyword> keywordsForCampaign(String campaignId) =>
      keywords.where((k) => k.campaignId == campaignId).toList();

  // ── AGGREGATES ────────────────────────────────────────────────────────────
  double get todaySpend {
    final today = DateTime.now();
    return dailyLogs
        .where((l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day)
        .fold(0.0, (s, l) => s + l.spend);
  }
  double get todaySales {
    final today = DateTime.now();
    return dailyLogs
        .where((l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day)
        .fold(0.0, (s, l) => s + l.adSales);
  }
  double get todayAcos {
    final s = todaySpend; final r = todaySales;
    return r > 0 ? s / r : 0;
  }
  int get todayOrders {
    final today = DateTime.now();
    return dailyLogs
        .where((l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day)
        .fold(0, (s, l) => s + l.orders);
  }

  String newId() => _uuid.v4();
}
