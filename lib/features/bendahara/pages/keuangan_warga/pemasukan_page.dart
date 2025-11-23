import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/features/bendahara/controllers/keuangan_controller.dart';
import 'package:jawara/features/bendahara/pages/keuangan_warga/pemasukan_form.dart';
import 'package:jawara/features/bendahara/widgets/transaction_card.dart';
import 'package:jawara/core/widgets/custom_top_bar.dart';
import 'package:jawara/theme/app_colors.dart';

class PemasukanPage extends ConsumerWidget {
  const PemasukanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keuanganControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: const CustomTopBar(title: 'Daftar Pemasukan', showBackButton: true, actions: [],),      
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (list) {
          final items = list.where((e) {
            final t = e.type;
            if (t != null && t.trim().isNotEmpty) {
              return t.trim().toLowerCase() == 'pemasukan';
            }
            // fallback to sign if type is missing
            return e.amount > 0;
          }).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

          if (items.isEmpty) return const Center(child: Text('Belum ada pemasukan'));

          return RefreshIndicator(
            onRefresh: () => ref.read(keuanganControllerProvider.notifier).fetchTransactions(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return TransactionCard(
                  title: item.title,
                  date: item.createdAt,
                  amount: item.amount,
                  type: item.type,
                  note: item.note,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (_) => const PemasukanFormPage()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Pemasukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
