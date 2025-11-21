import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import 'package:jawara/features/warga/controllers/profil_controller.dart';

class DataDiriPage extends ConsumerWidget {
  const DataDiriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilControllerProvider);

    return state.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: const CustomTopBar(
          title: 'Data Diri',
          showBackButton: true,
          actions: [],
        ),
        body: Center(child: Text('Error: $e')),
      ),
      data: (profil) {
        final warga = profil.warga;

        String formatDate(DateTime? d) =>
            d == null ? '-' : d.toLocal().toString().split(' ')[0];

        final noKkStr = profil.noKk?.toString() ?? warga?.idKk.toString() ?? '-';

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomTopBar(
            title: 'Data Diri',
            showBackButton: true,
            actions: [],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionCard(
                  title: 'Data Diri',
                  items: [
                    _buildListTile("NIK", warga?.nik ?? '-'),
                    _buildListTile("Nama Lengkap", warga?.namaLengkap ?? profil.namaLengkap ?? '-'),
                    _buildListTile("Tanggal Lahir", formatDate(warga?.tanggalLahir)),
                    _buildListTile("Jenis Kelamin", warga?.jenisKelamin ?? '-'),
                    _buildListTile("Nomor HP", warga?.nomorHp ?? '-'),
                    _buildListTile("No. KK", noKkStr),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'Alamat',
                  items: [
                    _buildListTile("Alamat", profil.alamat ?? '-'),
                    _buildListTile("RT", profil.rt?.toString() ?? '-'),
                    _buildListTile("RW", profil.rw?.toString() ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> items}) {
    return Card(
      color: AppColors.white, // Warna kartu putih
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const Divider(height: 20, thickness: 1),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      title: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: Text(
        value,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
