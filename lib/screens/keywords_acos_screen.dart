import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/store.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// KEYWORD TRACKER SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class KeywordsScreen extends StatefulWidget {
  const KeywordsScreen({super.key});
  @override
  State<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends State<KeywordsScreen> {
  String _filter = 'All';
  final _filters = ['All', '✅ HARVEST', '👀 WATCH', '⚠️ REDUCE BID', '❌ NEGATIVE'];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    var kws = store.keywords.toList();
    if (_filter != 'All') kws = kws.where((k) => k.action.contains(_filter.replaceAll('✅ ', '').replaceAll('👀 ', '').replaceAll('⚠️ ', '').replaceAll('❌ ', ''))).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('🔑 Keyword Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showKeywordForm(context, store, null),
        icon: const Icon(Icons.add), label: const Text('Add Keyword'),
      ),
      body: Column(children: [
        // Filter chips
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _filters.map((f) {
              final active = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.accent.withOpacity(0.2) : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppTheme.accent : AppTheme.cardBorder),
                  ),
                  child: Text(f, style: TextStyle(color: active ? AppTheme.accent : AppTheme.textSecond, fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
        ),

        // Summary strip
        if (store.keywords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: _KwSummaryChip(label: 'Harvest', count: store.keywords.where((k) => k.action.contains('HARVEST')).length, color: AppTheme.accentGreen)),
              const SizedBox(width: 6),
              Expanded(child: _KwSummaryChip(label: 'Negative', count: store.keywords.where((k) => k.action.contains('NEGATIVE')).length, color: AppTheme.accentRed)),
              const SizedBox(width: 6),
              Expanded(child: _KwSummaryChip(label: 'Watch', count: store.keywords.where((k) => k.action.contains('WATCH')).length, color: AppTheme.accentAmber)),
            ]),
          ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: kws.isEmpty
              ? EmptyState(icon: '🔑', title: 'No Keywords', subtitle: 'Add keywords to track their performance',
                  onAction: () => _showKeywordForm(context, store, null), actionLabel: 'Add Keyword')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: kws.length,
                  itemBuilder: (context, i) => _KeywordCard(kw: kws[i], store: store),
                ),
        ),
      ]),
    );
  }
}

class _KwSummaryChip extends StatelessWidget {
  final String label; final int count; final Color color;
  const _KwSummaryChip({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
      Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
    ]),
  );
}

class _KeywordCard extends StatelessWidget {
  final Keyword kw; final AppStore store;
  const _KeywordCard({required this.kw, required this.store});

  @override
  Widget build(BuildContext context) {
    final campaign = store.campaigns.firstWhere((c) => c.id == kw.campaignId,
        orElse: () => Campaign(id: '', name: 'Unknown', startDate: DateTime.now()));
    final ac = kw.action;
    final acColor = actionColor(ac);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ac.contains('HARVEST') ? AppTheme.accentGreen.withOpacity(0.4)
            : ac.contains('NEGATIVE') ? AppTheme.accentRed.withOpacity(0.4) : AppTheme.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(kw.term, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14))),
          StatusBadge(label: ac, color: acColor),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            color: AppTheme.surface, iconSize: 18,
            onSelected: (v) {
              if (v == 'edit') _showKeywordForm(context, store, kw);
              if (v == 'delete') store.deleteKeyword(kw.id);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppTheme.textPrimary))),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.accentRed))),
            ],
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          StatusBadge(label: kw.matchType, color: AppTheme.accent),
          const SizedBox(width: 6),
          StatusBadge(label: kw.status, color: kw.status == 'Active' ? AppTheme.accentGreen : AppTheme.textMuted),
          const Spacer(),
          Text(campaign.name, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricTile(label: 'SPEND', value: Fmt.currency(kw.spend), color: AppTheme.accentRed)),
          const SizedBox(width: 6),
          Expanded(child: MetricTile(label: 'SALES', value: Fmt.currency(kw.sales), color: AppTheme.accentGreen)),
          const SizedBox(width: 6),
          Expanded(child: MetricTile(label: 'ACOS', value: kw.sales > 0 ? Fmt.pct(kw.acos) : '—', color: acosColor(kw.acos))),
          const SizedBox(width: 6),
          Expanded(child: MetricTile(label: 'BID', value: Fmt.currency(kw.bid), color: AppTheme.accentAmber)),
        ]),
      ]),
    );
  }
}

void _showKeywordForm(BuildContext context, AppStore store, Keyword? existing) {
  if (store.campaigns.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a campaign first!'), backgroundColor: AppTheme.accentRed));
    return;
  }
  String selectedCampaignId = existing?.campaignId ?? store.campaigns.first.id;
  String matchType = existing?.matchType ?? 'Exact';
  String status = existing?.status ?? 'Active';
  final termCtrl = TextEditingController(text: existing?.term ?? '');
  final bidCtrl = TextEditingController(text: existing?.bid.toString() ?? '');
  final impCtrl = TextEditingController(text: existing?.impressions.toString() ?? '');
  final clickCtrl = TextEditingController(text: existing?.clicks.toString() ?? '');
  final orderCtrl = TextEditingController(text: existing?.orders.toString() ?? '');
  final spendCtrl = TextEditingController(text: existing?.spend.toString() ?? '');
  final salesCtrl = TextEditingController(text: existing?.sales.toString() ?? '');

  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Text(existing == null ? 'Add Keyword' : 'Edit Keyword',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textSecond), onPressed: () => Navigator.pop(ctx)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: selectedCampaignId, dropdownColor: AppTheme.card,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: const InputDecoration(labelText: 'Campaign'),
          items: store.campaigns.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (v) => setState(() => selectedCampaignId = v!),
        ),
        const SizedBox(height: 10),
        TextField(controller: termCtrl, style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Keyword / Search Term')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(value: matchType, dropdownColor: AppTheme.card,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Match Type'),
            items: ['Exact', 'Broad', 'Phrase', 'Auto'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => matchType = v!),
          )),
          const SizedBox(width: 10),
          Expanded(child: DropdownButtonFormField<String>(value: status, dropdownColor: AppTheme.card,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Status'),
            items: ['Active', 'Paused', 'Negative'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => status = v!),
          )),
        ]),
        const SizedBox(height: 10),
        TextField(controller: bidCtrl, keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Current Bid (₹)')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: impCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Impressions'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: clickCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Clicks'))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: orderCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Orders'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: spendCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Spend (₹)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: salesCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Sales (₹)'))),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () {
            final kw = Keyword(
              id: existing?.id ?? store.newId(), campaignId: selectedCampaignId,
              term: termCtrl.text, matchType: matchType, status: status,
              impressions: int.tryParse(impCtrl.text) ?? 0, clicks: int.tryParse(clickCtrl.text) ?? 0,
              orders: int.tryParse(orderCtrl.text) ?? 0,
              spend: double.tryParse(spendCtrl.text) ?? 0, sales: double.tryParse(salesCtrl.text) ?? 0,
              bid: double.tryParse(bidCtrl.text) ?? 0, lastUpdated: DateTime.now(),
            );
            if (existing == null) store.addKeyword(kw); else store.updateKeyword(kw);
            Navigator.pop(ctx);
          },
          child: Text(existing == null ? 'Add Keyword' : 'Update Keyword'),
        )),
      ])),
    )),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACOS OPTIMIZER SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class AcosOptimizerScreen extends StatefulWidget {
  const AcosOptimizerScreen({super.key});
  @override
  State<AcosOptimizerScreen> createState() => _AcosOptimizerState();
}

class _AcosOptimizerState extends State<AcosOptimizerScreen> {
  final _priceCtrl    = TextEditingController(text: '499');
  final _marginCtrl   = TextEditingController(text: '35');
  final _currentAcosC = TextEditingController(text: '');
  final _spendCtrl    = TextEditingController(text: '');
  final _salesCtrl    = TextEditingController(text: '');
  final _cvrCtrl      = TextEditingController(text: '');
  final _cpcCtrl      = TextEditingController(text: '');

  final _rootCauses = [
    'High bids on low-converting keywords',
    'Broad/Auto match driving irrelevant traffic',
    'Low CVR — listing issue (not ads)',
    'Budget depleting early — losing peak hours',
    'Bidding on competitor KWs with low win rate',
    'Weak negative keyword list',
    'No harvesting from Auto → Exact',
  ];
  final List<bool> _checked = List.filled(7, false);

  double get _price    => double.tryParse(_priceCtrl.text) ?? 0;
  double get _margin   => (double.tryParse(_marginCtrl.text) ?? 0) / 100;
  double get _curAcos  => (double.tryParse(_currentAcosC.text) ?? 0) / 100;
  double get _spend    => double.tryParse(_spendCtrl.text) ?? 0;
  double get _sales    => double.tryParse(_salesCtrl.text) ?? 0;
  double get _cvr      => (double.tryParse(_cvrCtrl.text) ?? 0) / 100;
  double get _cpc      => double.tryParse(_cpcCtrl.text) ?? 0;
  double get _breakEven => _margin;
  double get _target   => _margin * 0.7;
  double get _gap      => _curAcos > 0 ? _curAcos - _target : 0;
  double get _maxCpc   => _price * _target * _cvr;
  double get _roas     => _spend > 0 ? _sales / _spend : 0;

  String get _severity {
    if (_gap <= 0) return '✅ ON TARGET';
    if (_gap > 0.2) return '🔴 CRITICAL';
    if (_gap > 0.1) return '🟠 MODERATE';
    return '🟡 MINOR';
  }
  Color get _severityColor {
    if (_gap <= 0) return AppTheme.accentGreen;
    if (_gap > 0.2) return AppTheme.accentRed;
    if (_gap > 0.1) return AppTheme.accentAmber;
    return const Color(0xFFD29922);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('⚡ ACOS Optimizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── INPUTS ─────────────────────────────────────────────────────────
          _Section(title: '📥 Input Your Numbers', color: AppTheme.accent, child: Column(children: [
            Row(children: [
              Expanded(child: _InputField(ctrl: _priceCtrl, label: 'Selling Price (₹)', onChanged: (_) => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(child: _InputField(ctrl: _marginCtrl, label: 'Net Margin %', onChanged: (_) => setState(() {}))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _InputField(ctrl: _spendCtrl, label: 'Ad Spend (₹)', onChanged: (_) => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(child: _InputField(ctrl: _salesCtrl, label: 'Ad Sales (₹)', onChanged: (_) => setState(() {}))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _InputField(ctrl: _currentAcosC, label: 'Current ACOS %', onChanged: (_) => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(child: _InputField(ctrl: _cvrCtrl, label: 'CVR %', onChanged: (_) => setState(() {}))),
            ]),
            const SizedBox(height: 10),
            _InputField(ctrl: _cpcCtrl, label: 'Avg CPC (₹)', onChanged: (_) => setState(() {})),
          ])),
          const SizedBox(height: 16),

          // ── CALCULATED METRICS ─────────────────────────────────────────────
          _Section(title: '📊 Calculated Metrics', color: AppTheme.accentAmber, child: Column(children: [
            Row(children: [
              Expanded(child: MetricTile(label: 'BREAK-EVEN ACOS', value: Fmt.pct(_breakEven), color: AppTheme.textSecond)),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(label: 'TARGET ACOS', value: Fmt.pct(_target), color: AppTheme.accentGreen)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: MetricTile(label: 'ACOS GAP', value: _gap > 0 ? '+${Fmt.pct(_gap)}' : Fmt.pct(_gap), color: _gap > 0 ? AppTheme.accentRed : AppTheme.accentGreen)),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(label: 'MAX CPC', value: _maxCpc > 0 ? Fmt.currency(_maxCpc) : '—', color: AppTheme.accent)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: MetricTile(label: 'ROAS', value: _roas > 0 ? Fmt.num(_roas) : '—', color: AppTheme.accentAmber)),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(label: 'CPC vs MAX CPC', value: _cpc > 0 && _maxCpc > 0 ? (_cpc <= _maxCpc ? '✓ OK' : '✗ HIGH') : '—',
                  color: _cpc <= _maxCpc || _maxCpc == 0 ? AppTheme.accentGreen : AppTheme.accentRed)),
            ]),
            const SizedBox(height: 12),
            // Severity banner
            if (_curAcos > 0) Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _severityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _severityColor.withOpacity(0.5))),
              child: Row(children: [
                Text(_severity, style: TextStyle(color: _severityColor, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text(_gap > 0 ? '${Fmt.pct(_gap)} above target' : 'Within target range',
                    style: TextStyle(color: _severityColor.withOpacity(0.8), fontSize: 13)),
              ]),
            ),
          ])),
          const SizedBox(height: 16),

          // ── ROOT CAUSE ────────────────────────────────────────────────────
          _Section(title: '🔍 Root Cause Checklist', color: AppTheme.accentRed, child: Column(
            children: List.generate(_rootCauses.length, (i) => GestureDetector(
              onTap: () => setState(() => _checked[i] = !_checked[i]),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _checked[i] ? AppTheme.accentRed.withOpacity(0.1) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _checked[i] ? AppTheme.accentRed.withOpacity(0.4) : AppTheme.cardBorder),
                ),
                child: Row(children: [
                  Icon(_checked[i] ? Icons.check_box : Icons.check_box_outline_blank,
                      color: _checked[i] ? AppTheme.accentRed : AppTheme.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_rootCauses[i], style: TextStyle(
                      color: _checked[i] ? AppTheme.accentRed : AppTheme.textSecond, fontSize: 13))),
                ]),
              ),
            )),
          )),
          const SizedBox(height: 16),

          // ── 4-WEEK FIX PLAN ───────────────────────────────────────────────
          _Section(title: '📅 4-Week Fix Plan', color: AppTheme.accentGreen, child: Column(children: [
            _WeekPlan(week: 'Week 1', title: 'STOP THE BLEEDING', color: AppTheme.accentRed,
              steps: ['Pull STR. Find top 20% spend, 0-sale keywords → add as negatives', 'Lower bids 25% on keywords with ACOS > 2× target', 'Pause Auto loose/complements if ACOS > 60%']),
            const SizedBox(height: 10),
            _WeekPlan(week: 'Week 2', title: 'HARVEST & TIGHTEN', color: AppTheme.accentAmber,
              steps: ['Add converting STR terms → Exact campaign', 'Raise exact bids 15% on ACOS < 50% of target', 'Add 15 new negatives from waste patterns']),
            const SizedBox(height: 10),
            _WeekPlan(week: 'Week 3', title: 'RESTRUCTURE', color: AppTheme.accent,
              steps: ['Move top 5 converters to dedicated campaign', 'Set individual keyword bids', '+20% top-of-search if CTR is strong']),
            const SizedBox(height: 10),
            _WeekPlan(week: 'Week 4', title: 'SCALE WINNERS', color: AppTheme.accentGreen,
              steps: ['Raise bids 10% + budget 30% on ACOS < 60% of target', 'Simulate bid increments on top 3 exact keywords', 'Set automated pause rules for wasted spend']),
          ])),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl; final String label; final Function(String) onChanged;
  const _InputField({required this.ctrl, required this.label, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: AppTheme.textPrimary),
    decoration: InputDecoration(labelText: label),
  );
}

class _Section extends StatelessWidget {
  final String title; final Color color; final Widget child;
  const _Section({required this.title, required this.color, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _WeekPlan extends StatelessWidget {
  final String week, title; final Color color; final List<String> steps;
  const _WeekPlan({required this.week, required this.title, required this.color, required this.steps});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(week, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      ...steps.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('• ', style: TextStyle(color: color.withOpacity(0.7))),
          Expanded(child: Text(s, style: const TextStyle(color: AppTheme.textSecond, fontSize: 12))),
        ]),
      )),
    ]),
  );
}
