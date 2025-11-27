import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../controllers/iuran_warga_controller.dart';
import '../../widgets/iuran_summary_card.dart';
import '../../widgets/iuran_list_item.dart';

class WargaIuranPage extends ConsumerWidget {
  const WargaIuranPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iuranState = ref.watch(iuranWargaProvider);
    final controller = ref.read(iuranWargaProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchData();
        },
        child: iuranState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : iuranState.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(iuranState.errorMessage!),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => controller.fetchData(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Summary Card (Total & Jatuh Tempo)
                    IuranSummaryCard(
                      totalTagihan: iuranState.totalTagihan,
                      jatuhTempo: iuranState.jatuhTempoTerdekat,
                    ),
                    const SizedBox(height: 24),

                    // 2. Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Tagihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Filter sederhana (Opsional)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.greyLight),
                          ),
                          child: const Row(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. List Iuran (Flow: Expand -> Bayar -> Selesai)
                    if (iuranState.listIuran.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text("Tidak ada data iuran"),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: iuranState.listIuran.length,
                        itemBuilder: (context, index) {
                          final item = iuranState.listIuran[index];
                          return IuranListItem(
                            data: item,
                            onPay: (idIuran) async {
                              // Tampilkan konfirmasi sebelum bayar
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Pembayaran'),
                                  content: Text(
                                    'Bayar tagihan "${item.iuran.jenis}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                      ),
                                      child: const Text(
                                        'Ya, Bayar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await controller.bayarIuran(idIuran);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pembayaran berhasil!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),

                    // Spacer bawah agar tidak tertutup navbar
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }
}
