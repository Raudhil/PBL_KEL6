import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../data/models/produk_marketplace_model.dart';
import '../../../../core/providers/marketplace_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final ProdukMarketplaceModel? product;
  final int storeId;

  const ProductFormPage({super.key, this.product, required this.storeId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  String _selectedCategory = 'Kentang';
  late String _selectedImagePath;

  final Map<String, String> _categoryImages = {
    'Kentang': 'assets/images/kentang.png',
    'Wortel': 'assets/images/wortel.png',
    'Tomat': 'assets/images/tomat.png',
    'Lainnya': 'assets/images/kentang.png',
  };

  @override
  void initState() {
    super.initState();
    _selectedImagePath = _categoryImages[_selectedCategory]!;
    if (widget.product != null) {
      _nameController.text = widget.product!.nama;
      _priceController.text = widget.product!.harga.toInt().toString();
      _stockController.text = widget.product!.stok.toString();
      _descController.text = widget.product!.deskripsi ?? '';
      _selectedCategory = 'Lainnya'; // Default category for existing products
      _selectedImagePath =
          widget.product!.fotoProduk ?? _categoryImages[_selectedCategory]!;
    } else {
      _selectedImagePath = _categoryImages[_selectedCategory]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: CustomTopBar(
        title: isEdit ? 'Edit Produk' : 'Tambah Produk',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Contoh: Kentang Organik',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Harga',
                hint: '15000',
                keyboardType: TextInputType.number,
                prefix: 'Rp ',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _stockController,
                label: 'Stok',
                hint: '50',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descController,
                label: 'Deskripsi',
                hint: 'Deskripsikan produk Anda...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              if (isEdit) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _showDeleteDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text(
                      'Hapus Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
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
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                          style: const TextStyle(
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
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'kentang':
        return '🥔';
      case 'wortel':
        return '🥕';
      case 'tomat':
        return '🍅';
      default:
        return '📦';
    }
  }

  Widget _buildImagePicker() {
    final emoji = _getCategoryEmoji(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Produk',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyDark.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 80)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Icon akan menyesuaikan kategori',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLines,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.greyLight),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.greyLight),
            ),
          ),
          items: ['Kentang', 'Wortel', 'Tomat', 'Lainnya']
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
              _selectedImagePath =
                  _categoryImages[_selectedCategory] ?? _selectedImagePath;
            });
          },
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      if (widget.product != null) {
        // Update existing product
        final updates = {
          'nama': _nameController.text.trim(),
          'harga': price,
          'stok': stock,
          'deskripsi': _descController.text.trim(),
          'foto_produk': _selectedImagePath,
        };

        await ref
            .read(marketplaceRepositoryProvider)
            .updateProduk(widget.product!.id, updates);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diupdate'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Create new product
        final newProduct = ProdukMarketplaceModel(
          id: 0,
          idToko: widget.storeId,
          nama: _nameController.text.trim(),
          deskripsi: _descController.text.trim(),
          harga: price,
          fotoProduk: _selectedImagePath,
          stok: stock,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(marketplaceRepositoryProvider).createProduk(newProduct);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Invalidate providers to refresh product list
      if (mounted) {
        ref.invalidate(produkByTokoProvider(widget.storeId));
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan produk: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showDeleteDialog() {
    final productName = _nameController.text;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text(
          'Anda yakin ingin menghapus "$productName"? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(marketplaceRepositoryProvider)
                    .deleteProduk(widget.product!.id);

                if (!mounted) return;
                Navigator.pop(ctx); // Close dialog

                // Invalidate and refresh
                ref.invalidate(produkByTokoProvider(widget.storeId));

                Navigator.pop(context, true); // Close form page with success

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produk "$productName" berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(ctx); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus produk: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
