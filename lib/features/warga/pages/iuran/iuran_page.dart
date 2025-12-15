import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../controllers/iuran_warga_controller.dart';
import '../../widgets/iuran_summary_card.dart';
import '../../widgets/iuran_list_item.dart';

class WargaIuranPage extends ConsumerStatefulWidget {
  const WargaIuranPage({super.key});

  @override
  ConsumerState<WargaIuranPage> createState() => _WargaIuranPageState();
}

class _WargaIuranPageState extends ConsumerState<WargaIuranPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            : _buildContent(context, iuranState, controller),
      ),
    );
  }

  /// Error widget
  Widget _buildErrorWidget(
    BuildContext context,
    IuranWargaController controller,
    IuranWargaState iuranState,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(iuranState.errorMessage!, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchData(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  /// Main content widget
  Widget _buildContent(
    BuildContext context,
    IuranWargaState iuranState,
    IuranWargaController controller,
  ) {
    // Pisahkan tagihan dan riwayat
    final tagihanList = iuranState.listIuran
        .where((item) => item.status == 'Belum Lunas')
        .toList();

    final riwayatList = iuranState.listIuran
        .where((item) => item.status == 'Lunas')
        .toList();

    // Sort riwayat dari terbaru ke paling lama berdasarkan tanggal bayar
    riwayatList.sort((a, b) {
      final dateA = a.tanggalBayar;
      final dateB = b.tanggalBayar;

      // Jika keduanya null, tetap pada posisi
      if (dateA == null && dateB == null) return 0;

      // Jika salah satu null, prioritas yang bukan null
      if (dateA == null) return 1; // a di bawah
      if (dateB == null) return -1; // b di bawah

      // Keduanya ada, urutkan descending (terbaru dulu)
      return dateB.compareTo(dateA);
    });

    print('🔍 DEBUG Riwayat sorting:');
    for (var item in riwayatList) {
      print('  - ${item.iuran.jenis}: ${item.tanggalBayar}');
    }

    return Column(
      children: [
        // Summary Card
        Padding(
          padding: const EdgeInsets.all(16),
          child: IuranSummaryCard(
            totalTagihan: iuranState.totalTagihan,
            jatuhTempo: iuranState.jatuhTempoTerdekat,
          ),
        ),

        // TabBar
        Container(
          color: AppColors.creamWhite,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt),
                    const SizedBox(width: 8),
                    Text('Tagihan (${tagihanList.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text('Riwayat (${riwayatList.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Tagihan (Belum Lunas)
              _buildListView(context, controller, tagihanList, 'Belum Lunas'),

              // Tab 2: Riwayat (Lunas) - sudah sorted
              _buildListView(context, controller, riwayatList, 'Lunas'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build list view untuk setiap tab
  Widget _buildListView(
    BuildContext context,
    IuranWargaController controller,
    List items,
    String status,
  ) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 'Belum Lunas'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  status == 'Belum Lunas'
                      ? Icons.check_circle_outline
                      : Icons.history,
                  size: 64,
                  color: status == 'Belum Lunas'
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                status == 'Belum Lunas'
                    ? 'Tidak Ada Tagihan'
                    : 'Belum Ada Riwayat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  status == 'Belum Lunas'
                      ? 'Selamat! Anda tidak memiliki tagihan iuran yang jatuh tempo saat ini. Terus jaga kedisiplinan pembayaran.'
                      : 'Belum ada riwayat pembayaran. Pembayaran Anda akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IuranListItem(
                  data: item,
                  onPay: status == 'Belum Lunas'
                      ? (idIuran) {
                          _handlePayment(context, controller, idIuran, item);
                        }
                      : (_) {},
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Handle payment dengan loading dialog yang simple
  void _handlePayment(
    BuildContext context,
    IuranWargaController controller,
    int idIuran,
    dynamic item,
  ) async {
    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Bayar tagihan "${item.iuran.jenis}" sebesar ${_formatCurrency(item.iuran.nominal)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Ya, Bayar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Show loading dialog
    late BuildContext loadingContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        loadingContext = ctx;
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Memproses...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      print('⏱️ Starting payment process...');
      await controller.bayarIuran(idIuran);
      print('✅ Payment done, closing dialog...');

      // Close loading dialog dengan context yang tepat
      if (loadingContext.mounted) {
        Navigator.pop(loadingContext);
        print('🔴 Dialog closed');
      }

      // REFRESH DATA setelah pembayaran berhasil
      print('🔄 Refreshing data...');
      await controller.fetchData();
      print('✅ Data refreshed');

      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Pembayaran berhasil!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        print('✅ Success message shown');
      }
    } catch (e) {
      print('❌ Error: $e');

      // Close loading dialog
      if (loadingContext.mounted) {
        Navigator.pop(loadingContext);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Format currency
  String _formatCurrency(num nominal) {
    return 'Rp ${nominal.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }
}
