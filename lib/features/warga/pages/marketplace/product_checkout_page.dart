import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../data/models/produk_marketplace_model.dart';
import '../../../../core/providers/marketplace_provider.dart';
import 'order_success_page.dart';

class ProductCheckoutPage extends ConsumerStatefulWidget {
  final ProdukMarketplaceModel product;
  final int quantity;

  const ProductCheckoutPage({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  ConsumerState<ProductCheckoutPage> createState() =>
      _ProductCheckoutPageState();
}

class _ProductCheckoutPageState extends ConsumerState<ProductCheckoutPage> {
  String _selectedPayment = 'COD';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.product.harga * widget.quantity;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Checkout', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Summary
                  _buildSection(
                    title: 'Ringkasan Produk',
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: widget.product.fotoProduk != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.product.fotoProduk!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      color: AppColors.greyMedium,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: AppColors.primary400,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.nama,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_formatPrice(widget.product.harga.toInt())} × ${widget.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Info
                  _buildSection(
                    title: 'Toko',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 20,
                          color: AppColors.primary600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.namaToko ?? 'Toko',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildSection(
                    title: 'Metode Pembayaran',
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          'COD',
                          'Cash On Delivery',
                          Icons.money,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          'QRIS',
                          'Scan QRIS',
                          Icons.qr_code_2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Summary
                  _buildSection(
                    title: 'Rincian Harga',
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Subtotal Produk',
                          'Rp ${_formatPrice(subtotal.toInt())}',
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Biaya Pengiriman',
                          'Gratis',
                          valueColor: AppColors.success,
                        ),
                        const Divider(height: 24),
                        _buildPriceRow(
                          'Total',
                          'Rp ${_formatPrice(subtotal.toInt())}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyDark.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Rp ${_formatPrice(subtotal.toInt())}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Konfirmasi Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPayment == value;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : AppColors.creamWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary600 : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary600
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary600
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary600,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color:
                valueColor ??
                (isTotal ? AppColors.primary600 : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);

    try {
      // Get current user
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) throw 'User tidak ditemukan';

      // Get buyer ID
      final userData = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('id_auth', currentUser.id)
          .maybeSingle();

      if (userData == null) throw 'User ID tidak ditemukan';
      final buyerId = userData['id'] as int;

      // Get seller ID
      final tokoData = await Supabase.instance.client
          .from('toko')
          .select('id_pemilik')
          .eq('id', widget.product.idToko)
          .single();
      final sellerId = tokoData['id_pemilik'] as int;

      // Create transaction
      final subtotal = widget.product.harga * widget.quantity;
      final transaksi = await ref
          .read(marketplaceRepositoryProvider)
          .createTransaksi(
            idPembeli: buyerId,
            idPenjual: sellerId,
            total: subtotal,
            items: [
              {
                'id_produk': widget.product.id,
                'qty': widget.quantity,
                'harga': widget.product.harga,
                'subtotal': subtotal,
              },
            ],
          );

      // Save payment method to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('payment_method_${transaksi.id}', _selectedPayment);

      if (!mounted) return;

      // Navigate to success page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            productName: widget.product.nama,
            quantity: widget.quantity,
            total: subtotal,
            paymentMethod: _selectedPayment,
          ),
        ),
        (route) => route.isFirst, // Keep only the first route (home)
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
