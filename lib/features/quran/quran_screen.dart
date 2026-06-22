import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/quran/quran_provider.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  bool _showBookmarksOnly = false;

  // Basic layout list of key Quran Surahs with names and Ayah counts
  final List<Map<String, dynamic>> _surahList = [
    {'number': 1, 'nameEn': 'Al-Fatihah', 'nameAr': 'الفاتحة', 'totalAyahs': 7},
    {'number': 2, 'nameEn': 'Al-Baqarah', 'nameAr': 'البقرة', 'totalAyahs': 286},
    {'number': 3, 'nameEn': 'Ali \'Imran', 'nameAr': 'آل عمران', 'totalAyahs': 200},
    {'number': 4, 'nameEn': 'An-Nisa\'', 'nameAr': 'النساء', 'totalAyahs': 176},
    {'number': 36, 'nameEn': 'Ya-Sin', 'nameAr': 'يس', 'totalAyahs': 83},
    {'number': 55, 'nameEn': 'Ar-Rahman', 'nameAr': 'الرحمن', 'totalAyahs': 78},
    {'number': 67, 'nameEn': 'Al-Mulk', 'nameAr': 'الملك', 'totalAyahs': 30},
    {'number': 112, 'nameEn': 'Al-Ikhlas', 'nameAr': 'الإخلاص', 'totalAyahs': 4},
    {'number': 113, 'nameEn': 'Al-Falaq', 'nameAr': 'الفلق', 'totalAyahs': 5},
    {'number': 114, 'nameEn': 'An-Nas', 'nameAr': 'الناس', 'totalAyahs': 6},
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quranProvider);

    // Apply Bookmark Filters
    final displayedSurahs = _showBookmarksOnly
        ? _surahList.where((s) => state.bookmarkedSurahs.contains(s['number'])).toList()
        : _surahList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quran Progress',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_showBookmarksOnly ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              setState(() {
                _showBookmarksOnly = !_showBookmarksOnly;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Last Read Banner
            if (state.lastRead != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryEmerald.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Read Surah',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.lastRead!.surahNameEn} (Ayah ${state.lastRead!.lastReadAyah})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.bookmark_added, color: AppTheme.goldAccent, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              _showBookmarksOnly ? 'Bookmarked Surahs' : 'Surah Directory',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: displayedSurahs.length,
                separatorBuilder: (c, idx) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final surah = displayedSurahs[index];
                  final surahNum = surah['number'] as int;
                  final totalAyahs = surah['totalAyahs'] as int;

                  // Find logged progress for this Surah
                  final progressItem = state.progressList.firstWhere(
                    (p) => p.surahNumber == surahNum,
                    orElse: () => QuranProgressModel(
                      surahNumber: surahNum,
                      lastReadAyah: 0,
                      surahNameEn: surah['nameEn'],
                      surahNameAr: surah['nameAr'],
                      progressPercentage: 0.0,
                      isCompleted: false,
                    ),
                  );

                  final isBookmarked = state.bookmarkedSurahs.contains(surahNum);

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$surahNum',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            surah['nameEn'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            surah['nameAr'],
                            style: GoogleFonts.amiri(
                              color: AppTheme.primaryEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress: ${progressItem.progressPercentage.toStringAsFixed(0)}% (Ayah ${progressItem.lastReadAyah}/$totalAyahs)',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: progressItem.progressPercentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: AppTheme.primaryEmerald,
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? AppTheme.goldAccent : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(quranProvider.notifier).toggleBookmark(surahNum);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryEmerald),
                            onPressed: () {
                              _showProgressLogDialog(context, ref, surah, progressItem);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressLogDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> surah,
    QuranProgressModel progress,
  ) {
    final ayahController = TextEditingController(text: progress.lastReadAyah.toString());
    final totalAyahs = surah['totalAyahs'] as int;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log Reading: ${surah['nameEn']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Ayahs in this Surah: $totalAyahs'),
              const SizedBox(height: 16),
              TextField(
                controller: ayahController,
                decoration: const InputDecoration(
                  labelText: 'Last Read Ayah Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                final lastReadVal = int.tryParse(ayahController.text) ?? 0;
                if (lastReadVal < 0 || lastReadVal > totalAyahs) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ayah must be between 1 and $totalAyahs')),
                  );
                  return;
                }

                final double percentage = (lastReadVal / totalAyahs) * 100;
                ref.read(quranProvider.notifier).updateProgress(
                      surahNum: surah['number'],
                      ayahNum: lastReadVal,
                      nameEn: surah['nameEn'],
                      nameAr: surah['nameAr'],
                      progressPercent: percentage,
                    );

                Navigator.pop(context);
              },
              child: const Text('Save Progress'),
            )
          ],
        );
      },
    );
  }
}
