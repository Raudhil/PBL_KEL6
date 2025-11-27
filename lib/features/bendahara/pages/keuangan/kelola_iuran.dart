import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../controllers/iuran_controllers.dart';
import 'iuran_form_page.dart';
import '../../../../data/models/iuran_model.dart';
import '../../widgets/iuran_card.dart';

class KelolaIuranPage extends ConsumerWidget {
  const KelolaIuranPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iuranState = ref.watch(iuranControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Kelola Iuran', showBackButton: true),
      body: iuranState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (iuranList) {
          if (iuranList.isEmpty) {
            return const Center(child: Text('Belum ada data iuran'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: iuranList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = iuranList[index];
              return IuranCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IuranFormPage()),
          );
        },
        backgroundColor: AppColors.primary600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Iuran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
