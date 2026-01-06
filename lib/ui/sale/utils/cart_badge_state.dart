import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:street_cart_pos/data/repositories/cart_repository.dart';

final ValueNotifier<int> cartItemLineCount = ValueNotifier<int>(0);

void setCartItemLineCount(int value) {
  cartItemLineCount.value = value < 0 ? 0 : value;
}

Future<void> refreshCartItemLineCount() async {
  try {
    final draft = await CartRepository().getDraftOrder();
    setCartItemLineCount(draft?.orderProducts.length ?? 0);
  } catch (_) {
    // Best-effort: don't crash UI for a badge.
  }
}

void refreshCartItemLineCountUnawaited() {
  unawaited(refreshCartItemLineCount());
}
