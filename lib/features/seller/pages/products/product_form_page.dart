import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

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
      _nameController.text = widget.product!['name'] as String;
      _priceController.text = widget.product!['price'] as String;
      _stockController.text = widget.product!['stock'].toString();
      _selectedCategory = widget.product!['category'] as String;
      _selectedImagePath =
          widget.product!['image'] as String? ??
          _categoryImages[_selectedCategory]!;
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
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product != null
                ? 'Produk berhasil diupdate'
                : 'Produk berhasil ditambahkan',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
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
            onPressed: () {
              // TODO: Delete from database
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close form page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Produk "$productName" berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
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
