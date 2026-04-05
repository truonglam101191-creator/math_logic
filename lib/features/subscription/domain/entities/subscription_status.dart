class SubscriptionStatus {
  final bool isActive;
  final DateTime? expireDate;
  final bool isOfflineFallback;
  final String? productId;

  const SubscriptionStatus({
    required this.isActive,
    this.expireDate,
    this.isOfflineFallback = false,
    this.productId,
  });

  factory SubscriptionStatus.unsubscribed() {
    return const SubscriptionStatus(isActive: false);
  }

  SubscriptionStatus copyWith({
    bool? isActive,
    DateTime? expireDate,
    bool? isOfflineFallback,
    String? productId,
  }) {
    return SubscriptionStatus(
      isActive: isActive ?? this.isActive,
      expireDate: expireDate ?? this.expireDate,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      productId: productId ?? this.productId,
    );
  }
}
