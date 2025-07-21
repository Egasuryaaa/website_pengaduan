class PengaduanStatistics {
  final int total;
  final int pending;
  final int proses;
  final int selesai;

  PengaduanStatistics({
    required this.total,
    required this.pending,
    required this.proses,
    required this.selesai,
  });

  factory PengaduanStatistics.fromJson(Map<String, dynamic> json) {
    return PengaduanStatistics(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      proses: json['proses'] ?? 0,
      selesai: json['selesai'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'proses': proses,
      'selesai': selesai,
    };
  }

  // Helper method to get percentage
  double getPercentage(int value) {
    return total > 0 ? (value / total * 100) : 0.0;
  }
}
