import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/product.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../../core/widgets/app_toast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class ProductDescriptionPage extends StatefulWidget {
  final Product product;

  const ProductDescriptionPage({super.key, required this.product});

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  int _quantity = 1;
  bool _whatsInsideExpanded = false;

  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final topImageH = screenH * 0.40;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                SizedBox(
                  height: topImageH,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.08),
                                child: const Center(
                                  child: Icon(Icons.eco_rounded,
                                      color: AppColors.primaryGreen, size: 60),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.08),
                                child: const Center(
                                  child: Icon(Icons.eco_rounded,
                                      color: AppColors.primaryGreen, size: 60),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0A6847),
                                    Color(0xFF064E34)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.eco_rounded,
                                    color: Colors.white, size: 80),
                              ),
                            ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              AutoSizeText(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                                maxLines: 1,
                                minFontSize: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildHowItWorks(context),
                          const SizedBox(height: 14),
                          _buildWatchTutorial(context),
                          const SizedBox(height: 24),
                          _buildWhatsInside(context),
                          const SizedBox(height: 24),
                          _buildBestFor(context),
                          const SizedBox(height: 24),
                          _buildSavingsCard(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          'How It Works',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          maxLines: 1,
          minFontSize: 14,
        ),
        const SizedBox(height: 16),
        _StepItem(
          step: '1',
          title: 'Place',
          desc:
              'Place 18 inches from door and 18 inches in front of fans',
          icon: Icons.place_rounded,
          color: AppColors.info,
        ),
        _buildConnector(),
        _StepItem(
          step: '2',
          title: 'Absorb',
          desc: 'Absorbs Ethylene Gases, Moisture, and Odors',
          icon: Icons.bubble_chart_rounded,
          color: AppColors.warning,
        ),
        _buildConnector(),
        _StepItem(
          step: '3',
          title: 'Fresh',
          desc:
              'Your food stays fresh up to 50% longer, reducing waste and saving money',
          icon: Icons.eco_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        width: 2,
        height: 20,
        color: AppColors.primaryGreen.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildWatchTutorial(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTutorialVideo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.watchTutorial,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.primaryGreen.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorialVideo(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(AppStrings.tutorialVideoUrl);
    if (videoId == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => _TutorialVideoPopup(
        title: AppStrings.videoInstallationTitle,
        videoId: videoId,
      ),
    );
  }

  Widget _buildWhatsInside(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _whatsInsideExpanded = !_whatsInsideExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.inputFillColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    "What's Inside",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    minFontSize: 13,
                  ),
                ),
                Icon(
                  _whatsInsideExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: context.textSecondary,
                ),
              ],
            ),
            if (_whatsInsideExpanded) ...[
              const SizedBox(height: 12),
              ...[
                'Natural zeolite minerals',
                'FDA-approved DuPont Tyvek breathable packaging',
                '100% non-toxic and food-safe',
                'Depleted packs can be used as plant fertilizer',
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryGreen,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBestFor(BuildContext context) {
    final chips = [
      'Walk-in Coolers',
      'Produce Drawers',
      'Dairy Storage',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          'Best For',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map((c) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: AutoSizeText(
                      c,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.08),
            AppColors.success.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Monthly Savings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Restaurants using this product save an average of \$200-400/month in reduced food waste',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: _quantity > 1
                        ? context.textPrimary
                        : context.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AutoSizeText(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A6847), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Sign In Required', style: TextStyle(fontWeight: FontWeight.w700)),
                          content: const Text('Please sign in or create an account to add items to your cart.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                GoRouter.of(context).go(AppRoutes.login);
                              },
                              child: const Text('Sign In', style: TextStyle(color: Color(0xFF0A6847), fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    for (var i = 0; i < _quantity; i++) {
                      context.read<CartBloc>().add(
                            AddProductToCart(
                              CartItem(
                                productId: product.id,
                                sku: product.sku,
                                name: product.name,
                                price: product.price,
                                imageUrl: product.imageUrl,
                              ),
                              userId,
                            ),
                          );
                    }
                    AppToast.show(context, message: '$_quantity × ${product.name} added to cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                  label: AutoSizeText(
                    'Add to Cart',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _StepItem({
    required this.step,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TutorialVideoPopup extends StatefulWidget {
  final String title;
  final String videoId;
  const _TutorialVideoPopup({required this.title, required this.videoId});

  @override
  State<_TutorialVideoPopup> createState() => _TutorialVideoPopupState();
}

class _TutorialVideoPopupState extends State<_TutorialVideoPopup> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B3A2D),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    aspectRatio: 16 / 9,
                    progressIndicatorColor: AppColors.primaryGreen,
                    progressColors: const ProgressBarColors(
                      playedColor: AppColors.primaryGreen,
                      handleColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
