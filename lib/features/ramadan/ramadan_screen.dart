import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/ramadan/ramadan_provider.dart';
import 'package:islamic_app/models/ramadan_fast_model.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ramadanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ramadan Tracker',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fasting summary header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ramadan Kareem',
                          style: TextStyle(
                            color: AppTheme.goldAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSumItem('Fasts Kept', '${state.totalFastsKept} days'),
                            _buildSumItem('Quran Progress', '${state.totalQuranPages} pgs'),
                            _buildSumItem('Total Charity', '\$${state.totalCharity.toStringAsFixed(1)}'),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Duas Section
                  Text(
                    'Daily Ramadan Duas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildDuasCard(context),
                  const SizedBox(height: 32),

                  Text(
                    'Ramadan Calendar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Calendar ListView
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.ramadanDays.length,
                    separatorBuilder: (c, idx) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final day = state.ramadanDays[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ramadan Day ${day.fastDay}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    day.date,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      day.isFasting ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: day.isFasting ? AppTheme.primaryEmerald : Colors.grey,
                                    ),
                                    onPressed: () {
                                      ref.read(ramadanProvider.notifier).updateDay(
                                            day.copyWith(isFasting: !day.isFasting),
                                          );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_note, color: AppTheme.primaryEmerald),
                                    onPressed: () {
                                      _showEditDialog(context, ref, day);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSumItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildDuasCard(BuildContext context) {
    return Card(
      color: AppTheme.primaryEmerald.withOpacity(0.04),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.primaryEmerald, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ، أَسْتَغْفِرُ اللَّهَ، أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ',
              style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Translation: "I bear witness that there is no god but Allah, I ask Allah for forgiveness, I ask Him for Paradise and seek refuge in Him from Hellfire."',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, RamadanFastModel day) {
    final quranController = TextEditingController(text: day.quranPagesRead.toString());
    final charityController = TextEditingController(text: day.charityAmount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Day ${day.fastDay} Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quranController,
                decoration: const InputDecoration(labelText: 'Quran Pages Read'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: charityController,
                decoration: const InputDecoration(labelText: 'Charity Contributed ($)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pages = int.tryParse(quranController.text) ?? 0;
                final charity = double.tryParse(charityController.text) ?? 0.0;
                ref.read(ramadanProvider.notifier).updateDay(
                      day.copyWith(
                        quranPagesRead: pages,
                        charityAmount: charity,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }
}
