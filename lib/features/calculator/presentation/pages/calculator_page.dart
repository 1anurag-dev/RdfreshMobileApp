import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import 'package:rdfresh/features/Products/presentation/bloc/product_bloc.dart';
import 'package:rdfresh/features/Products/presentation/bloc/product_event.dart';
import 'package:rdfresh/features/Products/presentation/bloc/product_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rdfresh/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:rdfresh/features/cart/presentation/bloc/cart_event.dart';
import 'package:rdfresh/features/cart/domain/entities/cart_item.dart';
import 'package:rdfresh/features/Products/domain/entities/product.dart';
import '../../../../injection_container.dart' as di;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Inputs
  final TextEditingController _lengthController = TextEditingController(
    text: '12',
  );
  final TextEditingController _widthController = TextEditingController(
    text: '10',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '8',
  );

  double _fans = 2;
  Product? _selectedProduct;
  String _selectedProfile = 'WALK_IN';

  // Calculated Values
  double get _length => double.tryParse(_lengthController.text) ?? 0;
  double get _width => double.tryParse(_widthController.text) ?? 0;
  double get _height => double.tryParse(_heightController.text) ?? 0;

  double get _volume => _length * _width * _height;

  int get _coverageUnits {
    if (_volume <= 0) return 0;
    return (_volume / 300).ceil();
  }

  int get _doorUnits => 1;
  int get _fanUnits => _fans.toInt();
  int get _finalTotal => (_volume / 300).ceil();

  String get _bagConfigName {
    return _selectedProfile;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider(
            create: (context) =>
                di.sl<CartBloc>()..add(LoadCart(userId))),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Panel Calculator',
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + 100,
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: _buildInputSections(context)),
                          const SizedBox(width: 30),
                          Expanded(
                              flex: 1,
                              child: _buildResultCard(context)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildInputSections(context),
                          const SizedBox(height: 30),
                          _buildResultCard(context),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSections(BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          context,
          number: '01',
          title: 'INTERIOR DIMENSIONS',
          child: Row(
            children: [
              _buildDimField(context, 'LENGTH', _lengthController),
              const SizedBox(width: 15),
              _buildDimField(context, 'WIDTH', _widthController),
              const SizedBox(width: 15),
              _buildDimField(context, 'HEIGHT', _heightController),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          context,
          number: '02',
          title: 'MECHANICAL HARDWARE',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EVAPORATOR FANS',
                    style: AppTypography.overline.copyWith(
                      color: context.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_fans.toInt()}',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryGreen,
                  inactiveTrackColor: context.borderColor,
                  thumbColor: AppColors.primaryGreen,
                  overlayColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: _fans,
                  min: 0,
                  max: 12,
                  onChanged: (val) => setState(() => _fans = val),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MIN: 0',
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'MAX: 12',
                    style: AppTypography.caption.copyWith(
                      color: context.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: AppRadius.smBr,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Standard protocol requires 1 panel per fan and 1 dedicated door panel.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          context,
          number: '03',
          title: 'INVENTORY PROFILE',
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const ShimmerGrid(
                  itemCount: 3,
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                );
              }
              if (state is ProductError) {
                return Text(
                  'Error loading products',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                );
              }
              if (state is ProductLoaded) {
                final products = state.products;
                if (products.isEmpty) {
                  return Text(
                    'No profiles found',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  );
                }

                if (_selectedProduct == null && products.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedProduct = products.first;
                        _selectedProfile = products.first.name;
                      });
                    }
                  });
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductTile(context, product);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String number,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.pillBr,
                ),
                child: Text(
                  number,
                  style: AppTypography.small.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildDimField(
      BuildContext context, String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.overline.copyWith(
                  color: context.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'FEET',
                style: AppTypography.overline.copyWith(
                  color: context.textTertiary,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              constraints: const BoxConstraints(minHeight: 56),
              hintText: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    final isSelected = _selectedProduct?.id == product.id;
    return InkWell(
      onTap: () => setState(() {
        _selectedProduct = product;
        _selectedProfile = product.name;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.mdBr,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: AppRadius.smBr,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: context.shimmerBase,
                    highlightColor: context.shimmerHighlight,
                    child: Container(
                      width: 40,
                      height: 40,
                      color: context.shimmerBase,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                      Icons.inventory_2_outlined,
                      size: 30,
                      color: context.textTertiary),
                ),
              )
            else
              Icon(Icons.inventory_2_outlined,
                  size: 30, color: context.textTertiary),
            const SizedBox(height: 6),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryGreen
                    : context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.elevatedShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: AppColors.cardAccentGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.base),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.smBr,
                      ),
                      child: const Icon(Icons.edit_note,
                          color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RECOMMENDED UNITS',
                          style: AppTypography.overline.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _finalTotal.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: AppRadius.mdBr,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INTERIOR VOLUME',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_volume.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} CU.FT',
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLACEMENT SPECIFICATION',
                  style: AppTypography.overline.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSpecRow('Main Entrance (Door)', '01 UNIT'),
                const SizedBox(height: AppSpacing.lg),
                _buildSpecRow(
                  'Evaporator Hardware',
                  '${_fanUnits.toString().padLeft(2, '0')} UNITS',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSpecRow(
                  'Equalized Coverage',
                  '${_coverageUnits.toString().padLeft(2, '0')} UNITS',
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Bag Config Selection
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.inputFillColor,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primaryGreen
                              .withValues(alpha: 0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'BAG CONFIG SELECTION',
                            style: AppTypography.overline.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _bagConfigName,
                        style: AppTypography.titleMedium.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Auto-selected based on inventory profile.',
                        style: AppTypography.caption.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.mdBr,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedProduct != null) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please login to continue'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          context.read<CartBloc>().add(
                                AddProductToCart(
                                  CartItem(
                                    productId: _selectedProduct!.id,
                                    sku: _selectedProduct!.sku,
                                    name: _selectedProduct!.name,
                                    price: _selectedProduct!.price,
                                    imageUrl: _selectedProduct!.imageUrl,
                                    quantity: _finalTotal.toInt(),
                                  ),
                                  user.uid,
                                ),
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${_selectedProduct!.name} ($_finalTotal units) added to cart'),
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          context.push(AppRoutes.cart);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdBr,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONFIGURE IN STORE',
                            style: AppTypography.button.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 3,
              backgroundColor: AppColors.primaryGreen,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
