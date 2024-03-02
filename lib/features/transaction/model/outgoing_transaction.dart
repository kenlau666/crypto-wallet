class OutgoingTransaction {
  final String toAddress;
  final String txHash;
  final String txValue;
  final DateTime timestamp;
  final String operation;
  final bool isPending;
  final bool isSuccess;
  final String remark;

  OutgoingTransaction({
    required this.toAddress,
    required this.txHash,
    required this.txValue,
    required this.timestamp,
    required this.operation,
    required this.isPending,
    required this.isSuccess,
    required this.remark,
  });

  OutgoingTransaction copyWith({
    String? toAddress,
    String? txHash,
    String? txValue,
    DateTime? timestamp,
    String? operation,
    bool? isPending,
    bool? isSuccess,
    String? remark,
  }) {
    return OutgoingTransaction(
      toAddress: toAddress ?? this.toAddress,
      txHash: txHash ?? this.txHash,
      txValue: txValue ?? this.txValue,
      timestamp: timestamp ?? this.timestamp,
      operation: operation ?? this.operation,
      isPending: isPending ?? this.isPending,
      isSuccess: isSuccess ?? this.isSuccess,
      remark: remark ?? this.remark,
    );
  }

  factory OutgoingTransaction.fromJson(Map<String, dynamic> json) {
    return OutgoingTransaction(
      toAddress: json['toAddress'],
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
      'toAddress': toAddress,
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
    return other is OutgoingTransaction &&
        other.toAddress == toAddress &&
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
    return toAddress.hashCode ^
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
    return 'Transaction(toAddress: $toAddress,txHash: $txHash,txValue: $txValue,timestamp: $timestamp, operation: $operation, isPending: $isPending,isSuccess: $isSuccess, remark: $remark)';
  }
}
