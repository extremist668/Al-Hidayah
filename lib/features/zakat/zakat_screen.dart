import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/zakat/zakat_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class ZakatScreen extends ConsumerStatefulWidget {
  const ZakatScreen({super.key});

  @override
  ConsumerState<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends ConsumerState<ZakatScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _businessController = TextEditingController();
  final _otherController = TextEditingController();
  final _liabilitiesController = TextEditingController();

  String _nisabType = 'gold';

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _businessController.dispose();
    _otherController.dispose();
    _liabilitiesController.dispose();
    super.dispose();
  }

  void _calculate() {
    final cash = double.tryParse(_cashController.text) ?? 0.0;
    final gold = double.tryParse(_goldController.text) ?? 0.0;
    final silver = double.tryParse(_silverController.text) ?? 0.0;
    final business = double.tryParse(_businessController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;

    ref.read(zakatProvider.notifier).saveCalculation(
          cash: cash,
          goldGrams: gold,
          silverGrams: silver,
          business: business,
          other: other,
          liabilities: liabilities,
          nisabType: _nisabType,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zakat calculation completed & saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zakatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Zakat & Fitra Calculator',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current calculations settings
            Text(
              'Calculate Your Zakat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Nisab Selector Switch
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Gold Nisab Threshold'),
                    selected: _nisabType == 'gold',
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _nisabType = 'gold';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Silver Nisab Threshold'),
                    selected: _nisabType == 'silver',
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _nisabType = 'silver';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInputField(_cashController, 'Cash & Bank Savings ($)'),
            _buildInputField(_goldController, 'Gold Holdings weight in Grams (g)'),
            _buildInputField(_silverController, 'Silver Holdings weight in Grams (g)'),
            _buildInputField(_businessController, 'Business Capital & Shares ($)'),
            _buildInputField(_otherController, 'Other Assets & Properties ($)'),
            _buildInputField(_liabilitiesController, 'Debts & Immediate Liabilities ($)'),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate & Log Record'),
            ),

            const SizedBox(height: 40),
            Text(
              'Calculation History Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // History Logs Lists
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.history.isEmpty
                    ? const Center(child: Text('No historical calculation records found.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final rec = state.history[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rec.calculationDate,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Using ${rec.nisabType.toUpperCase()} Nisab',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Zakat Payable:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '\$${rec.totalZakat.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppTheme.primaryEmerald,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}
