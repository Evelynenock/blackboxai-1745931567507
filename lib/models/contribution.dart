class Contribution {
  final String id;
  final String userId;
  final double amount; // amount in Tsh.
  final DateTime date;

  Contribution({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
  });
}
