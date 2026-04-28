import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/store.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final logs = store.dailyLogs.toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('📈 Daily Log'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLog(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Log Today'),
      ),
      body: logs.isEmpty
          ? EmptyState(
              icon: '📈', title: 'No Logs Yet',
              subtitle: 'Tap "Log Today" to enter today\'s ad metrics',
              onAction: () => _showAddLog(context, store),
              actionLabel: 'Log Today',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final campaign = store.campaigns.firstWhere(
                    (c) => c.id == log.campaignId,
                    orElse: () => Campaign(id: '', name: 'Unknown', startDate: DateTime.now()));
                return _LogCard(log: log, campaign: campaign, store: store);
              },
            ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final DailyLog log;
  final Campaign campaign;
  final AppStore store;
  const _LogCard({required this.log, required this.campaign, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogDetail(context, log, campaign),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('EEE, d MMM').format(log.date),
                  style: const TextStyle(color: AppTheme.textSecond, fontSize: 11)),
              const SizedBox(height: 2),
              Text(campaign.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
            const Spacer(),
            HealthGauge(score: log.healthScore),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              color: AppTheme.surface,
              onSelected: (v) {
                if (v == 'edit') _showEditLog(context, log, store);
                if (v == 'delete') {
                  store.deleteLog(log.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppTheme.textPrimary))),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.accentRed))),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: MetricTile(label: 'SPEND', value: Fmt.currency(log.spend), color: AppTheme.accentRed)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'SALES', value: Fmt.currency(log.adSales), color: AppTheme.accentGreen)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'ACOS', value: Fmt.pct(log.acos), color: acosColor(log.acos))),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'ORDERS', value: '${log.orders}', color: AppTheme.accentPurple)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: MetricTile(label: 'CLICKS', value: '${log.clicks}', color: AppTheme.accent)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'IMPR.', value: Fmt.compact(log.impressions), color: AppTheme.textSecond)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'ROAS', value: Fmt.num(log.roas), color: AppTheme.accentAmber)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'CVR', value: Fmt.pct(log.cvr), color: AppTheme.accentGreen)),
          ]),
          if (log.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
              child: Text(log.notes, style: const TextStyle(color: AppTheme.textSecond, fontSize: 12)),
            ),
          ],
        ]),
      ),
    );
  }
}

void _showLogDetail(BuildContext context, DailyLog log, Campaign campaign) {
  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Log Details', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, color: AppTheme.textSecond), onPressed: () => Navigator.pop(context)),
        ]),
        Text(campaign.name, style: const TextStyle(color: AppTheme.textSecond)),
        Text(DateFormat('EEEE, d MMMM y').format(log.date), style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 16),
        InfoRow(label: 'Impressions', value: Fmt.compact(log.impressions)),
        InfoRow(label: 'Clicks', value: '${log.clicks}'),
        InfoRow(label: 'CTR', value: Fmt.pct(log.ctr), valueColor: AppTheme.accent),
        InfoRow(label: 'Avg CPC', value: Fmt.currency(log.avgCpc)),
        InfoRow(label: 'Orders', value: '${log.orders}', valueColor: AppTheme.accentPurple),
        InfoRow(label: 'CVR', value: Fmt.pct(log.cvr), valueColor: acosColor(1 - log.cvr * 5)),
        const Divider(color: AppTheme.divider),
        InfoRow(label: 'Ad Spend', value: Fmt.currency(log.spend), valueColor: AppTheme.accentRed),
        InfoRow(label: 'Ad Sales', value: Fmt.currency(log.adSales), valueColor: AppTheme.accentGreen),
        InfoRow(label: 'Total Sales', value: Fmt.currency(log.totalSales)),
        InfoRow(label: 'ACOS', value: Fmt.pct(log.acos), valueColor: acosColor(log.acos)),
        InfoRow(label: 'TACOS', value: Fmt.pct(log.tacos), valueColor: acosColor(log.tacos)),
        InfoRow(label: 'ROAS', value: Fmt.num(log.roas), valueColor: AppTheme.accentAmber),
        InfoRow(label: 'Budget Used', value: Fmt.pct(log.budgetUsed)),
        const SizedBox(height: 16),
      ]),
    ),
  );
}

void _showAddLog(BuildContext context, AppStore store) => _showLogForm(context, store, null);
void _showEditLog(BuildContext context, DailyLog log, AppStore store) => _showLogForm(context, store, log);

void _showLogForm(BuildContext context, AppStore store, DailyLog? existing) {
  final campaigns = store.campaigns.where((c) => c.status == 'Active').toList();
  if (campaigns.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add a campaign first!'), backgroundColor: AppTheme.accentRed));
    return;
  }

  String selectedCampaignId = existing?.campaignId ?? campaigns.first.id;
  DateTime selectedDate = existing?.date ?? DateTime.now();

  final impCtrl = TextEditingController(text: existing?.impressions.toString() ?? '');
  final clickCtrl = TextEditingController(text: existing?.clicks.toString() ?? '');
  final orderCtrl = TextEditingController(text: existing?.orders.toString() ?? '');
  final spendCtrl = TextEditingController(text: existing?.spend.toString() ?? '');
  final adSalesCtrl = TextEditingController(text: existing?.adSales.toString() ?? '');
  final totalSalesCtrl = TextEditingController(text: existing?.totalSales.toString() ?? '');
  final budgetCtrl = TextEditingController(text: existing?.budget.toString() ?? '');
  final kwCtrl = TextEditingController(text: existing?.topKeyword ?? '');
  final notesCtrl = TextEditingController(text: existing?.notes ?? '');

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(existing == null ? 'Log Today\'s Data' : 'Edit Log',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: AppTheme.textSecond), onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 16),

            // Campaign Picker
            DropdownButtonFormField<String>(
              value: selectedCampaignId,
              dropdownColor: AppTheme.card,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Campaign'),
              items: campaigns.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => selectedCampaignId = v!),
            ),
            const SizedBox(height: 12),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: ctx, initialDate: selectedDate,
                    firstDate: DateTime(2024), lastDate: DateTime.now());
                if (d != null) setState(() => selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(8), color: AppTheme.surface,
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: AppTheme.textSecond, size: 16),
                  const SizedBox(width: 8),
                  Text(DateFormat('d MMM y').format(selectedDate), style: const TextStyle(color: AppTheme.textPrimary)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _NumField(ctrl: impCtrl, label: 'Impressions', hint: '3200')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: clickCtrl, label: 'Clicks', hint: '64')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _NumField(ctrl: orderCtrl, label: 'Orders', hint: '4')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: budgetCtrl, label: 'Budget (₹)', hint: '300')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _NumField(ctrl: spendCtrl, label: 'Ad Spend (₹)', hint: '280')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: adSalesCtrl, label: 'Ad Sales (₹)', hint: '1100')),
            ]),
            const SizedBox(height: 10),
            _NumField(ctrl: totalSalesCtrl, label: 'Total Sales (₹) incl. organic', hint: '1600'),
            const SizedBox(height: 10),
            TextField(
              controller: kwCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Top Keyword', hintText: 'tulsi mala 108 beads'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes / Issues', hintText: 'Any observations for today...'),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final log = DailyLog(
                    id: existing?.id ?? store.newId(),
                    campaignId: selectedCampaignId,
                    date: selectedDate,
                    impressions: int.tryParse(impCtrl.text) ?? 0,
                    clicks: int.tryParse(clickCtrl.text) ?? 0,
                    orders: int.tryParse(orderCtrl.text) ?? 0,
                    spend: double.tryParse(spendCtrl.text) ?? 0,
                    adSales: double.tryParse(adSalesCtrl.text) ?? 0,
                    totalSales: double.tryParse(totalSalesCtrl.text) ?? 0,
                    budget: double.tryParse(budgetCtrl.text) ?? 0,
                    topKeyword: kwCtrl.text,
                    notes: notesCtrl.text,
                  );
                  if (existing == null) store.addLog(log); else store.updateLog(log);
                  Navigator.pop(ctx);
                },
                child: Text(existing == null ? 'Save Log' : 'Update Log'),
              ),
            ),
          ]),
        ),
      );
    }),
  );
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  const _NumField({required this.ctrl, required this.label, required this.hint});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: AppTheme.textPrimary),
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}
