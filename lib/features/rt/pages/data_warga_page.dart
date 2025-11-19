import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// go_router not required here (we use CustomTopBar for back navigation)
import 'package:go_router/go_router.dart';
import '../../../core/providers/warga_provider.dart';
import '../../../core/widgets/custom_top_bar.dart';
import '../../../theme/app_colors.dart';
import 'warga_detail_page.dart';
import 'warga_form_page.dart';

class DataWargaPage extends ConsumerWidget {
  const DataWargaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wargaNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: CustomTopBar(
        title: 'Data Warga RT',
        showBackButton: true,
        onBack: () => context.go('/perangkat'),
      ),
      body: state.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada data warga.'))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final w = list[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WargaDetailPage(warga: w),
                                  ),
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.primary100,
                                  child: Text(
                                    w.namaLengkap.isNotEmpty
                                        ? w.namaLengkap[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  w.namaLengkap,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('NIK: ${w.nik}',
                                          style: TextStyle(
                                              color:
                                                  AppColors.textPrimary.withOpacity(0.8))),
                                      const SizedBox(height: 4),
                                      Text('HP: ${w.nomorHp ?? '-'}',
                                          style: TextStyle(
                                              color:
                                                  AppColors.textPrimary.withOpacity(0.8))),
                                    ],
                                  ),
                                ),
                                isThreeLine: false,
                                trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WargaFormPage(warga: w),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Konfirmasi'),
                                        content: const Text(
                                          'Hapus data warga ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      if (!context.mounted) return;
                                      try {
                                        await ref
                                            .read(
                                              wargaNotifierProvider.notifier,
                                            )
                                            .deleteWarga(w.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Data dihapus'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Gagal hapus: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Hapus'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WargaFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
