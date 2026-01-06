import 'package:flutter/material.dart';
import 'package:street_cart_pos/domain/models/product.dart';
import 'package:street_cart_pos/ui/core/utils/number_format.dart';
import 'package:street_cart_pos/ui/core/widgets/modifier_group_selection.dart';
import 'package:street_cart_pos/ui/core/widgets/product_image.dart';
import 'package:street_cart_pos/ui/core/widgets/quantity_stepper.dart';
import 'package:street_cart_pos/ui/sale/viewmodel/product_selection_viewmodel.dart';

Future<void> openProductSelectionPage(
  BuildContext context, {
  required Product product,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductSelectionPage(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Avoid the default "swipe/slide" page transition so the Hero feels
        // like a smooth container transform.
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    ),
  );
}

Future<void> showProductSelectionSheet(
  BuildContext context, {
  required Product product,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => ProductSelectionView(product: product, isSheet: true),
  );
}

class ProductSelectionPage extends StatelessWidget {
  const ProductSelectionPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final tag = productSelectionHeroTag(product.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) =>
              MaterialRectCenterArcTween(begin: begin, end: end),
          flightShuttleBuilder:
              (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) {
                final fromHero = fromHeroContext.widget as Hero;
                final toHero = toHeroContext.widget as Hero;

                final fromChild = fromHero.child;
                final toChild = toHero.child;

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeInOutCubic.transform(animation.value);
                    final fromOpacity =
                        flightDirection == HeroFlightDirection.push ? 1 - t : t;
                    final toOpacity =
                        flightDirection == HeroFlightDirection.push ? t : 1 - t;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(opacity: fromOpacity, child: fromChild),
                        Opacity(opacity: toOpacity, child: toChild),
                      ],
                    );
                  },
                );
              },
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: ProductSelectionView(
              product: product,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductSelectionView extends StatefulWidget {
  const ProductSelectionView({
    super.key,
    required this.product,
    this.onClose,
    this.isSheet = false,
  });

  final Product product;
  final VoidCallback? onClose;
  final bool isSheet;

  @override
  State<ProductSelectionView> createState() => _ProductSelectionViewState();
}

class _ProductSelectionViewState extends State<ProductSelectionView> {
  late final ProductSelectionViewModel _viewModel = ProductSelectionViewModel(
    product: widget.product,
  );
  late final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final product = _viewModel.product;
        final categoryName = product.category?.name ?? 'Uncategorized';

        if (_noteController.text != _viewModel.note) {
          _noteController
            ..text = _viewModel.note
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: _noteController.text.length),
            );
        }

        final body = Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              if (widget.onClose != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close',
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox.square(
                            dimension: 96,
                            child: ProductImage(
                              imagePath: product.imagePath,
                              showPlaceholderLabel: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        categoryName,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        formatUsd(_viewModel.unitTotal),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (product.modifierGroups.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No modifiers available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        for (final group in product.modifierGroups)
                          ModifierGroupSelection(
                            group: group,
                            selectedOptionIds:
                                _viewModel.selectedOptionIdsByGroupId[group
                                    .id] ??
                                const {},
                            readOnly: false,
                            onSelectSingle: (optionId) =>
                                _viewModel.selectSingle(
                                  groupId: group.id,
                                  optionId: optionId,
                                ),
                            onToggleMulti: (optionId, selected) =>
                                _viewModel.toggleMulti(
                                  group: group,
                                  optionId: optionId,
                                  selected: selected,
                                ),
                          ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'e.g., no onions, extra sauce',
                        ),
                        onChanged: _viewModel.setNote,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatUsd(_viewModel.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  QuantityStepper(
                    quantity: _viewModel.quantity,
                    onDecrement: _viewModel.quantity <= 1
                        ? null
                        : _viewModel.decrementQuantity,
                    onIncrement: _viewModel.incrementQuantity,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _viewModel.addingToCart
                          ? null
                          : () async {
                              try {
                                await _viewModel.addToCart();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to add to cart: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      child: const Text('Add to cart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (widget.isSheet) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                child: body,
              );
            },
          );
        }

        return body;
      },
    );
  }
}
