import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/store.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('🗂️ Campaigns')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCampaignForm(context, store, null),
        icon: const Icon(Icons.add), label: const Text('New Campaign'),
      ),
      body: store.campaigns.isEmpty
          ? EmptyState(
              icon: '🗂️', title: 'No Campaigns',
              subtitle: 'Add your first Amazon ad campaign to start tracking',
              onAction: () => _showCampaignForm(context, store, null),
              actionLabel: 'Add Campaign',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: store.campaigns.length,
              itemBuilder: (context, i) => _CampaignCard(campaign: store.campaigns[i], store: store),
            ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final AppStore store;
  const _CampaignCard({required this.campaign, required this.store});

  @override
  Widget build(BuildContext context) {
    final logs = store.logsForCampaign(campaign.id);
    final latest = logs.isNotEmpty ? logs.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(campaign.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Row(children: [
                StatusBadge(label: campaign.status, color: campaign.status == 'Active' ? AppTheme.accentGreen : AppTheme.textMuted),
                const SizedBox(width: 6),
                StatusBadge(label: campaign.type.replaceAll('Sponsored ', 'SP '), color: AppTheme.accent),
              ]),
            ])),
            PopupMenuButton<String>(
              color: AppTheme.surface,
              onSelected: (v) {
                if (v == 'edit') _showCampaignForm(context, store, campaign);
                if (v == 'delete') _confirmDelete(context, store, campaign);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppTheme.textPrimary))),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.accentRed))),
              ],
            ),
          ]),
        ),

        const Divider(color: AppTheme.divider, height: 1),

        // ACOS Targets
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Column(children: [
              Text('Break-even', style: const TextStyle(color: AppTheme.textSecond, fontSize: 10)),
              const SizedBox(height: 4),
              Text(Fmt.pct(campaign.breakEvenAcos), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            ])),
            Container(width: 1, height: 32, color: AppTheme.divider),
            Expanded(child: Column(children: [
              Text('Target ACOS', style: const TextStyle(color: AppTheme.textSecond, fontSize: 10)),
              const SizedBox(height: 4),
              Text(Fmt.pct(campaign.targetAcos), style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w700, fontSize: 16)),
            ])),
            Container(width: 1, height: 32, color: AppTheme.divider),
            Expanded(child: Column(children: [
              Text('Current ACOS', style: const TextStyle(color: AppTheme.textSecond, fontSize: 10)),
              const SizedBox(height: 4),
              Text(latest != null ? Fmt.pct(latest.acos) : '—',
                  style: TextStyle(color: latest != null ? acosColor(latest.acos) : AppTheme.textMuted,
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ])),
          ]),
        ),

        const Divider(color: AppTheme.divider, height: 1),

        // Bids & Budget
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: MetricTile(label: 'DAILY BUDGET', value: Fmt.currency(campaign.dailyBudget), color: AppTheme.accent)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'BID AUTO', value: campaign.bidAuto > 0 ? Fmt.currency(campaign.bidAuto) : '—', color: AppTheme.textSecond)),
            const SizedBox(width: 8),
            Expanded(child: MetricTile(label: 'BID EXACT', value: campaign.bidExact > 0 ? Fmt.currency(campaign.bidExact) : '—', color: AppTheme.accentAmber)),
          ]),
        ),

        // ASIN & Product
        if (campaign.asin.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('${campaign.asin}  •  ${campaign.product}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ),
      ]),
    );
  }
}

void _confirmDelete(BuildContext context, AppStore store, Campaign campaign) {
  showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: AppTheme.card, title: const Text('Delete Campaign?', style: TextStyle(color: AppTheme.textPrimary)),
    content: Text('This will also delete all logs and keywords for "${campaign.name}".',
        style: const TextStyle(color: AppTheme.textSecond)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      TextButton(onPressed: () { store.deleteCampaign(campaign.id); Navigator.pop(context); },
          child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed))),
    ],
  ));
}

void _showCampaignForm(BuildContext context, AppStore store, Campaign? existing) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final asinCtrl = TextEditingController(text: existing?.asin ?? '');
  final productCtrl = TextEditingController(text: existing?.product ?? '');
  final budgetCtrl = TextEditingController(text: existing?.dailyBudget.toString() ?? '');
  final priceCtrl = TextEditingController(text: existing?.sellingPrice.toString() ?? '');
  final marginCtrl = TextEditingController(text: existing != null ? (existing.netMargin * 100).toStringAsFixed(0) : '');
  final bidAutoCtrl = TextEditingController(text: existing?.bidAuto.toString() ?? '');
  final bidBroadCtrl = TextEditingController(text: existing?.bidBroad.toString() ?? '');
  final bidExactCtrl = TextEditingController(text: existing?.bidExact.toString() ?? '');
  final tosCtrl = TextEditingController(text: existing?.topOfSearchAdj.toString() ?? '0');
  final notesCtrl = TextEditingController(text: existing?.notes ?? '');

  String selectedType = existing?.type ?? 'Sponsored Products';
  String selectedStatus = existing?.status ?? 'Active';

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(existing == null ? 'New Campaign' : 'Edit Campaign',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close, color: AppTheme.textSecond), onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 16),
          TextField(controller: nameCtrl, style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Campaign Name *')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: selectedType, dropdownColor: AppTheme.card,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Sponsored Products', 'Sponsored Brands', 'Sponsored Display']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            )),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<String>(
              value: selectedStatus, dropdownColor: AppTheme.card,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Active', 'Paused', 'Draft', 'Ended', 'Testing']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedStatus = v!),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: asinCtrl, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'ASIN'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: productCtrl, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Product Name'))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Selling Price (₹)'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: marginCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Net Margin %', hintText: '35'))),
          ]),
          const SizedBox(height: 10),
          TextField(controller: budgetCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Daily Budget (₹)')),
          const SizedBox(height: 10),
          const Text('Bids (₹)', style: TextStyle(color: AppTheme.textSecond, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: bidAutoCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Auto'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: bidBroadCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Broad'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: bidExactCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Exact'))),
          ]),
          const SizedBox(height: 10),
          TextField(controller: notesCtrl, style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final c = Campaign(
                id: existing?.id ?? store.newId(),
                name: nameCtrl.text, type: selectedType,
                asin: asinCtrl.text, product: productCtrl.text,
                startDate: existing?.startDate ?? DateTime.now(),
                status: selectedStatus,
                dailyBudget: double.tryParse(budgetCtrl.text) ?? 0,
                sellingPrice: double.tryParse(priceCtrl.text) ?? 0,
                netMargin: (double.tryParse(marginCtrl.text) ?? 0) / 100,
                bidAuto: double.tryParse(bidAutoCtrl.text) ?? 0,
                bidBroad: double.tryParse(bidBroadCtrl.text) ?? 0,
                bidExact: double.tryParse(bidExactCtrl.text) ?? 0,
                topOfSearchAdj: double.tryParse(tosCtrl.text) ?? 0,
                notes: notesCtrl.text,
              );
              if (existing == null) store.addCampaign(c); else store.updateCampaign(c);
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Create Campaign' : 'Update Campaign'),
          )),
        ])),
      );
    }),
  );
}
