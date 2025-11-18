import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';

class SellerReviewListPage extends ConsumerStatefulWidget {
  const SellerReviewListPage({super.key});

  @override
  ConsumerState<SellerReviewListPage> createState() =>
      _SellerReviewListPageState();
}

class _SellerReviewListPageState extends ConsumerState<SellerReviewListPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    // TODO: connect to provider
    final reviews = _dummyReviews;
    final filteredReviews = _selectedFilter == 'Semua'
        ? reviews
        : reviews
              .where((review) => '${review['rating']}' == _selectedFilter)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Ulasan Pembeli', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _RatingSummary(),
            const SizedBox(height: 16),
            _buildFilter(),
            const SizedBox(height: 16),
            ...filteredReviews.map((review) => _ReviewCard(review: review)),
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
  const _RatingSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, const Color(0xFFF8B500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '4.8 / 5',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rata-rata rating dari 120 ulasan',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
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
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary50,
                child: Text(
                  review['buyerName'].toString().substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['buyerName'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['productName'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < (review['rating'] as int)
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review['date'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pesanan selesai',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final _dummyReviews = [
  {
    'buyerName': 'Budi Santoso',
    'productName': 'Kentang Organik',
    'rating': 5,
    'comment':
        'Kentangnya segar dan ukuran besar, pengiriman tepat waktu. Recommended!',
    'date': '02 Des',
  },
  {
    'buyerName': 'Siti Aminah',
    'productName': 'Wortel Segar',
    'rating': 4,
    'comment': 'Wortelnya bagus, beberapa ukuran kecil tapi masih ok.',
    'date': '30 Nov',
  },
  {
    'buyerName': 'Ahmad Rizki',
    'productName': 'Kentang Premium',
    'rating': 5,
    'comment': 'Pelayanan ramah, packing rapi. Akan order lagi.',
    'date': '29 Nov',
  },
];
