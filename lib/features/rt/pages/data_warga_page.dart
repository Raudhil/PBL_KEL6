import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/warga_provider.dart';
import 'warga_detail_page.dart';
import 'warga_form_page.dart';

class DataWargaPage extends ConsumerWidget {
  const DataWargaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wargaNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              // prefer GoRouter pop to keep navigation consistent
              context.pop();
            } catch (_) {
              // fallback to route when pop isn't possible
              context.go('/perangkat');
            }
          },
        ),
        title: const Text('Data Warga RT'),
      ),
      body: state.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada data warga.'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final w = list[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () async {
                        // open details
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WargaDetailPage(warga: w),
                          ),
                        );
                      },
                      title: Text(w.namaLengkap),
                      subtitle: Text('NIK: ${w.nik}\nHP: ${w.nomorHp ?? '-'}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WargaFormPage(warga: w),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Hapus data warga ini?'),
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
                                // ensure context is still valid after async work
                                if (!context.mounted) return;
                                try {
                                  await ref
                                      .read(wargaNotifierProvider.notifier)
                                      .deleteWarga(w.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data dihapus'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal hapus: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
