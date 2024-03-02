class IncomingTransaction {
  final String fromAddress;
  final String txHash;
  final String txValue;
  final DateTime timestamp;
  final String operation;
  final bool isPending;
  final bool isSuccess;
  final String remark;

  IncomingTransaction({
    required this.fromAddress,
    required this.txHash,
    required this.txValue,
    required this.timestamp,
    required this.operation,
    required this.isPending,
    required this.isSuccess,
    required this.remark,
  });

  IncomingTransaction copyWith({
    String? fromAddress,
    String? txHash,
    String? txValue,
    DateTime? timestamp,
    String? operation,
    bool? isPending,
    bool? isSuccess,
    String? remark,
  }) {
    return IncomingTransaction(
      fromAddress: fromAddress ?? this.fromAddress,
      txHash: txHash ?? this.txHash,
      txValue: txValue ?? this.txValue,
      timestamp: timestamp ?? this.timestamp,
      operation: operation ?? this.operation,
      isPending: isPending ?? this.isPending,
      isSuccess: isSuccess ?? this.isSuccess,
      remark: remark ?? this.remark,
    );
  }

  factory IncomingTransaction.fromJson(Map<String, dynamic> json) {
    return IncomingTransaction(
      fromAddress: json['fromAddress'],
      txHash: json['txHash'],
      txValue: json['txValue'],
      timestamp: DateTime.parse(json['timestamp']),
      operation: json['operation'],
      isPending: json['isPending'],
      isSuccess: json['isSuccess'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromAddress': fromAddress,
      'txHash': txHash,
      'txValue': txValue,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
      'isPending': isPending,
      'isSuccess': isSuccess,
      'remark': remark,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncomingTransaction &&
        other.fromAddress == fromAddress &&
        other.txHash == txHash &&
        other.txValue == txValue &&
        other.timestamp == timestamp &&
        other.operation == operation &&
        other.isPending == isPending &&
        other.isSuccess == isSuccess &&
        other.remark == remark;
  }

  @override
  int get hashCode {
    return fromAddress.hashCode ^
        txHash.hashCode ^
        txValue.hashCode ^
        timestamp.hashCode ^
        operation.hashCode ^
        isPending.hashCode ^
        isSuccess.hashCode ^
        remark.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(fromAddress: $fromAddress,txHash: $txHash,txValue: $txValue,timestamp: $timestamp, operation: $operation, isPending: $isPending,isSuccess: $isSuccess, remark: $remark)';
  }
}
