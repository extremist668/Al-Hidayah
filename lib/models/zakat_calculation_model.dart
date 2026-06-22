class ZakatCalculationModel {
  final String id;
  final String calculationDate; // Format: yyyy-MM-dd
  final double cashAmount;
  final double goldValue;
  final double silverValue;
  final double businessAssets;
  final double otherAssets;
  final double liabilities;
  final double nisabValue;
  final String nisabType; // 'gold' or 'silver'
  final double totalZakat;

  ZakatCalculationModel({
    required this.id,
    required this.calculationDate,
    required this.cashAmount,
    required this.goldValue,
    required this.silverValue,
    required this.businessAssets,
    required this.otherAssets,
    required this.liabilities,
    required this.nisabValue,
    required this.nisabType,
    required this.totalZakat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculation_date': calculationDate,
      'cash_amount': cashAmount,
      'gold_value': goldValue,
      'silver_value': silverValue,
      'business_assets': businessAssets,
      'other_assets': otherAssets,
      'liabilities': liabilities,
      'nisab_value': nisabValue,
      'nisab_type': nisabType,
      'total_zakat': totalZakat,
    };
  }

  factory ZakatCalculationModel.fromJson(Map<String, dynamic> json) {
    return ZakatCalculationModel(
      id: json['id'] ?? '',
      calculationDate: json['calculation_date'] ?? '',
      cashAmount: (json['cash_amount'] ?? 0.0).toDouble(),
      goldValue: (json['gold_value'] ?? 0.0).toDouble(),
      silverValue: (json['silver_value'] ?? 0.0).toDouble(),
      businessAssets: (json['business_assets'] ?? 0.0).toDouble(),
      otherAssets: (json['other_assets'] ?? 0.0).toDouble(),
      liabilities: (json['liabilities'] ?? 0.0).toDouble(),
      nisabValue: (json['nisab_value'] ?? 0.0).toDouble(),
      nisabType: json['nisab_type'] ?? 'gold',
      totalZakat: (json['total_zakat'] ?? 0.0).toDouble(),
    );
  }
}
