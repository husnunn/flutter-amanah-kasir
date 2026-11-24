enum ReportPeriod {
  hari('Hari', 'Pendapatan per jam'),
  minggu('Minggu', 'Pendapatan harian'),
  bulan('Bulan', 'Pendapatan harian'),
  tahun('Tahun', 'Pendapatan bulanan');

  const ReportPeriod(this.label, this.chartTitle);

  final String label;
  final String chartTitle;
}

class RevenueBar {
  const RevenueBar(this.label, this.value);

  final String label;

  /// Pendapatan dalam Rupiah.
  final double value;
}

/// Spesifikasi grafik batang: data + skala sumbu Y.
class ChartSpec {
  const ChartSpec({
    required this.bars,
    required this.maxY,
    required this.interval,
    required this.axisDivisor,
    required this.axisSuffix,
    this.visibleLabels,
  });

  final List<RevenueBar> bars;
  final double maxY;
  final double interval;

  /// Pembagi untuk label sumbu: 1e6 -> "jt", 1e3 -> "rb".
  final double axisDivisor;
  final String axisSuffix;

  /// Label sumbu X yang ditampilkan (null = semua).
  final Set<String>? visibleLabels;
}

enum PaymentKind { cash, qris, transfer }

class PaymentShare {
  const PaymentShare(this.kind, this.label, this.percent, this.amountLabel);

  final PaymentKind kind;
  final String label;
  final int percent;
  final String amountLabel;
}

class TopProduct {
  const TopProduct(this.name, this.sold);

  final String name;
  final int sold;
}

class LowStockItem {
  const LowStockItem(this.name, this.stock, this.minStock);

  final String name;
  final int stock;
  final int minStock;
}

/// Ringkasan dashboard untuk satu periode. DATA CONTOH, bukan data sungguhan.
class DashboardData {
  const DashboardData({
    required this.rangeLabel,
    required this.heroCaption,
    required this.grossSales,
    required this.txCount,
    required this.grossProfit,
    required this.expense,
    required this.expenseCount,
    required this.netBalance,
    required this.todaySales,
    required this.chart,
    required this.paymentSplit,
    required this.topProducts,
  });

  final String rangeLabel;
  final String heroCaption;
  final int grossSales;
  final int txCount;
  final int grossProfit;
  final int expense;
  final int expenseCount;
  final int netBalance;
  final int todaySales;
  final ChartSpec chart;
  final List<PaymentShare> paymentSplit;
  final List<TopProduct> topProducts;
}
