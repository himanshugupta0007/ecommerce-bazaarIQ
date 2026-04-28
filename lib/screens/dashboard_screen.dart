import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/store.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final recent = store.recentLogs(days: 7);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              backgroundColor: AppTheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ad Campaign Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text(DateFormat('EEEE, d MMM').format(DateTime.now()),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecond, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppTheme.textSecond),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // ── TODAY'S KPI STRIP ──────────────────────────────────────
                _TodayKpiStrip(store: store),
                const SizedBox(height: 20),

                // ── ACOS CHART ────────────────────────────────────────────
                const SectionHeader(title: '📈  7-Day ACOS Trend'),
                _AcosChart(logs: recent),
                const SizedBox(height: 20),

                // ── SPEND vs SALES ────────────────────────────────────────
                const SectionHeader(title: '💰  Spend vs Sales (7 days)'),
                _SpendSalesChart(logs: recent),
                const SizedBox(height: 20),

                // ── ISSUE RADAR ───────────────────────────────────────────
                SectionHeader(title: '🚨  Issue Radar',
                  action: _IssueCount(store: store)),
                _IssueRadar(store: store),
                const SizedBox(height: 20),

                // ── CAMPAIGN HEALTH ───────────────────────────────────────
                const SectionHeader(title: '🏥  Campaign Health Scores'),
                _CampaignHealthList(store: store),
                const SizedBox(height: 80),
              ])),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TODAY KPI STRIP ──────────────────────────────────────────────────────────
class _TodayKpiStrip extends StatelessWidget {
  final AppStore store;
  const _TodayKpiStrip({required this.store});

  @override
  Widget build(BuildContext context) {
    final todayLogs = store.recentLogs(days: 1);
    final totalImpressions = todayLogs.fold(0, (s, l) => s + l.impressions);
    final totalClicks = todayLogs.fold(0, (s, l) => s + l.clicks);

    return Column(children: [
      Row(children: [
        Expanded(child: StatCard(label: 'TODAY SPEND', value: Fmt.currency(store.todaySpend),
            sub: '${store.campaigns.where((c) => c.status == 'Active').length} campaigns',
            icon: Icons.payments_outlined, color: AppTheme.accent)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(label: 'TODAY SALES', value: Fmt.currency(store.todaySales),
            icon: Icons.trending_up, color: AppTheme.accentGreen)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: StatCard(label: 'ACOS', value: Fmt.pct(store.todayAcos),
            sub: store.todayAcos < 0.3 ? 'On target ✓' : 'Above target ⚠️',
            icon: Icons.percent, color: acosColor(store.todayAcos))),
        const SizedBox(width: 12),
        Expanded(child: StatCard(label: 'ORDERS', value: '${store.todayOrders}',
            icon: Icons.shopping_bag_outlined, color: AppTheme.accentPurple)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: StatCard(label: 'IMPRESSIONS', value: Fmt.compact(totalImpressions),
            icon: Icons.visibility_outlined, color: AppTheme.textSecond)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(label: 'CLICKS', value: Fmt.compact(totalClicks),
            icon: Icons.ads_click, color: const Color(0xFF79C0FF))),
      ]),
    ]);
  }
}

// ─── ACOS CHART ───────────────────────────────────────────────────────────────
class _AcosChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _AcosChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    // Group by day
    final Map<String, List<DailyLog>> byDay = {};
    for (final l in logs) {
      final key = DateFormat('MM/dd').format(l.date);
      byDay.putIfAbsent(key, () => []).add(l);
    }
    final days = byDay.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final dayLogs = byDay[days[i]]!;
      final spend = dayLogs.fold(0.0, (s, l) => s + l.spend);
      final sales = dayLogs.fold(0.0, (s, l) => s + l.adSales);
      final acos = sales > 0 ? (spend / sales * 100) : 0.0;
      spots.add(FlSpot(i.toDouble(), acos));
    }

    if (spots.isEmpty) {
      return const SizedBox(height: 160, child: Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textMuted))));
    }

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: LineChart(LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.divider, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) {
              final i = v.round();
              if (i < 0 || i >= days.length) return const SizedBox();
              return Text(days[i], style: const TextStyle(color: AppTheme.textMuted, fontSize: 9));
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 32,
            getTitlesWidget: (v, _) => Text('${v.round()}%', style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots, isCurved: true, color: AppTheme.accentAmber,
            barWidth: 2.5, dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.accentAmber.withOpacity(0.1)),
          ),
          // Target ACOS line at 24.5%
          LineChartBarData(
            spots: spots.map((s) => FlSpot(s.x, 24.5)).toList(),
            isCurved: false, color: AppTheme.accentGreen.withOpacity(0.5),
            barWidth: 1.5, dashArray: [4, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      )),
    );
  }
}

// ─── SPEND vs SALES CHART ─────────────────────────────────────────────────────
class _SpendSalesChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _SpendSalesChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<DailyLog>> byDay = {};
    for (final l in logs) {
      final key = DateFormat('MM/dd').format(l.date);
      byDay.putIfAbsent(key, () => []).add(l);
    }
    final days = byDay.keys.toList()..sort();

    if (days.isEmpty) {
      return const SizedBox(height: 140, child: Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textMuted))));
    }

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < days.length; i++) {
      final dl = byDay[days[i]]!;
      final spend = dl.fold(0.0, (s, l) => s + l.spend);
      final sales = dl.fold(0.0, (s, l) => s + l.adSales);
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: spend, color: AppTheme.accentRed.withOpacity(0.8), width: 8, borderRadius: BorderRadius.circular(3)),
        BarChartRodData(toY: sales, color: AppTheme.accentGreen.withOpacity(0.8), width: 8, borderRadius: BorderRadius.circular(3)),
      ]));
    }

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _Legend(color: AppTheme.accentRed, label: 'Spend'),
          const SizedBox(width: 12),
          _Legend(color: AppTheme.accentGreen, label: 'Sales'),
        ]),
        const SizedBox(height: 8),
        Expanded(child: BarChart(BarChartData(
          barGroups: groups,
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 20,
              getTitlesWidget: (v, _) {
                final i = v.round();
                if (i < 0 || i >= days.length) return const SizedBox();
                return Text(days[i], style: const TextStyle(color: AppTheme.textMuted, fontSize: 9));
              },
            )),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              Fmt.currency(rod.toY), const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
            ),
          )),
        ))),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: AppTheme.textSecond, fontSize: 11)),
  ]);
}

// ─── ISSUE RADAR ──────────────────────────────────────────────────────────────
class _IssueCount extends StatelessWidget {
  final AppStore store;
  const _IssueCount({required this.store});
  @override
  Widget build(BuildContext context) {
    final issues = _getIssues(store);
    return StatusBadge(label: '${issues.length} issues', color: issues.isEmpty ? AppTheme.accentGreen : AppTheme.accentRed);
  }
}

List<Map<String, String>> _getIssues(AppStore store) {
  final issues = <Map<String, String>>[];
  for (final c in store.campaigns.where((c) => c.status == 'Active')) {
    final logs = store.logsForCampaign(c.id).take(3).toList();
    if (logs.isEmpty) continue;
    final avgAcos = logs.fold(0.0, (s, l) => s + l.acos) / logs.length;
    if (avgAcos > c.targetAcos * 1.5) {
      issues.add({
        'campaign': c.name, 'issue': 'High ACOS',
        'value': Fmt.pct(avgAcos), 'target': Fmt.pct(c.targetAcos),
        'severity': avgAcos > c.targetAcos * 2 ? 'Critical' : 'Moderate',
      });
    }
    final latestLog = logs.first;
    if (latestLog.budgetUsed > 0.95) {
      issues.add({'campaign': c.name, 'issue': 'Budget Exhausted', 'value': Fmt.pct(latestLog.budgetUsed), 'target': '<95%', 'severity': 'Moderate'});
    }
    if (latestLog.cvr < 0.05 && latestLog.clicks > 20) {
      issues.add({'campaign': c.name, 'issue': 'Low CVR — Check Listing', 'value': Fmt.pct(latestLog.cvr), 'target': '>5%', 'severity': 'Moderate'});
    }
  }
  final negKws = store.keywords.where((k) => k.spend > 0 && k.sales == 0 && k.status == 'Active').length;
  if (negKws > 0) {
    issues.add({'campaign': 'All Campaigns', 'issue': 'Wasted Spend Keywords', 'value': '$negKws keywords', 'target': '0', 'severity': 'High'});
  }
  return issues;
}

class _IssueRadar extends StatelessWidget {
  final AppStore store;
  const _IssueRadar({required this.store});

  @override
  Widget build(BuildContext context) {
    final issues = _getIssues(store);
    if (issues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.check_circle_outline, color: AppTheme.accentGreen),
          SizedBox(width: 12),
          Text('All campaigns are within healthy thresholds!', style: TextStyle(color: AppTheme.accentGreen)),
        ]),
      );
    }
    return Column(children: issues.map((issue) {
      final color = issue['severity'] == 'Critical' ? AppTheme.accentRed
          : issue['severity'] == 'High' ? AppTheme.accentAmber : const Color(0xFFD29922);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(issue['issue']!, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(issue['campaign']!, style: const TextStyle(color: AppTheme.textSecond, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(issue['value']!, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            Text('Target: ${issue['target']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ]),
      );
    }).toList());
  }
}

// ─── CAMPAIGN HEALTH LIST ─────────────────────────────────────────────────────
class _CampaignHealthList extends StatelessWidget {
  final AppStore store;
  const _CampaignHealthList({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.campaigns.isEmpty) {
      return const EmptyState(icon: '📊', title: 'No Campaigns Yet', subtitle: 'Add your first campaign in the Campaigns tab');
    }
    return Column(children: store.campaigns.map((c) {
      final logs = store.logsForCampaign(c.id);
      final latest = logs.isNotEmpty ? logs.first : null;
      final health = latest?.healthScore ?? 0;
      final acos = latest?.acos ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(children: [
          HealthGauge(score: health),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              StatusBadge(label: c.status, color: c.status == 'Active' ? AppTheme.accentGreen : AppTheme.textMuted),
              const SizedBox(width: 6),
              StatusBadge(label: c.type.split(' ').last, color: AppTheme.accent),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AcosBadge(acos: acos),
            const SizedBox(height: 4),
            Text('ACOS', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ]),
      );
    }).toList());
  }
}
