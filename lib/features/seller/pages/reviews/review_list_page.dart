import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../../../../data/models/review_produk_model.dart';

class SellerReviewListPage extends ConsumerStatefulWidget {
  const SellerReviewListPage({super.key});

  @override
  ConsumerState<SellerReviewListPage> createState() =>
      _SellerReviewListPageState();
}

class _SellerReviewListPageState extends ConsumerState<SellerReviewListPage> {
  String _selectedFilter = 'Semua';

  Future<int?> _getUserIntId(String authId) async {
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('id_auth', authId)
          .maybeSingle();
      return userData?['id'] as int?;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  Future<int?> _getStoreId(int userId) async {
    try {
      final storeData = await Supabase.instance.client
          .from('toko')
          .select('id')
          .eq('id_pemilik', userId)
          .maybeSingle();
      return storeData?['id'] as int?;
    } catch (e) {
      print('❌ Error getting store ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(
          title: 'Ulasan Pembeli',
          showBackButton: true,
        ),
        body: const Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return FutureBuilder<int?>(
      future: _getUserIntId(currentUser.id),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.creamWhite,
            appBar: const CustomTopBar(
              title: 'Ulasan Pembeli',
              showBackButton: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final userId = userSnapshot.data;
        if (userId == null) {
          return Scaffold(
            backgroundColor: AppColors.creamWhite,
            appBar: const CustomTopBar(
              title: 'Ulasan Pembeli',
              showBackButton: true,
            ),
            body: const Center(child: Text('User ID tidak ditemukan')),
          );
        }

        return FutureBuilder<int?>(
          future: _getStoreId(userId),
          builder: (context, storeSnapshot) {
            if (!storeSnapshot.hasData) {
              return Scaffold(
                backgroundColor: AppColors.creamWhite,
                appBar: const CustomTopBar(
                  title: 'Ulasan Pembeli',
                  showBackButton: true,
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final storeId = storeSnapshot.data;
            if (storeId == null) {
              return Scaffold(
                backgroundColor: AppColors.creamWhite,
                appBar: const CustomTopBar(
                  title: 'Ulasan Pembeli',
                  showBackButton: true,
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Toko Belum Dibuat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buat toko terlebih dahulu untuk melihat ulasan',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return _buildReviewPage(context, storeId);
          },
        );
      },
    );
  }

  Widget _buildReviewPage(BuildContext context, int storeId) {
    final reviewsAsync = ref.watch(storeReviewsProvider(storeId));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Ulasan Pembeli', showBackButton: true),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return _buildEmptyState();
          }

          // Filter reviews based on rating
          final filteredReviews = _selectedFilter == 'Semua'
              ? reviews
              : reviews
                    .where(
                      (review) => review.rating.toString() == _selectedFilter,
                    )
                    .toList();

          // Calculate rating summary
          final totalReviews = reviews.length;
          final averageRating = totalReviews > 0
              ? reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                    totalReviews
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RatingSummary(
                  averageRating: averageRating,
                  totalReviews: totalReviews,
                ),
                const SizedBox(height: 16),
                _buildFilter(),
                const SizedBox(height: 16),
                if (filteredReviews.isEmpty)
                  _buildNoResultsForFilter()
                else
                  ...filteredReviews.map(
                    (review) => _ReviewCard(review: review),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat ulasan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(storeReviewsProvider(storeId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Ulasan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ulasan dari pembeli akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsForFilter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada ulasan $_selectedFilter★',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba filter rating lainnya',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    const filters = ['Semua', '5', '4', '3', '2', '1'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter == 'Semua' ? 'Semua' : '$filter★'),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: AppColors.primary600,
            backgroundColor: AppColors.white,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const _RatingSummary({
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'dari $totalReviews ulasan',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.thumb_up, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${((averageRating / 5) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewProdukModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  review.namaPembeli != null && review.namaPembeli!.isNotEmpty
                      ? review.namaPembeli![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.namaPembeli ?? 'Pembeli',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      review.namaProduk ?? 'Produk',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
          if (review.komentar != null && review.komentar!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.komentar!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDate(review.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
