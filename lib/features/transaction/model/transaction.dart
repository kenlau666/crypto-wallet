class TransactionDetail {
  final bool isIn;
  final String address;
  final String txHash;
  final String txValue;
  final DateTime timestamp;
  final String operation;
  final bool isPending;
  final bool isSuccess;
  final String remark;

  TransactionDetail({
    required this.isIn,
    required this.address,
    required this.txHash,
    required this.txValue,
    required this.timestamp,
    required this.operation,
    required this.isPending,
    required this.isSuccess,
    required this.remark,
  });

  TransactionDetail copyWith({
    bool? isIn,
    String? address,
    String? txHash,
    String? txValue,
    DateTime? timestamp,
    String? operation,
    bool? isPending,
    bool? isSuccess,
    String? remark,
  }) {
    return TransactionDetail(
      isIn: isIn ?? this.isIn,
      address: address ?? this.address,
      txHash: txHash ?? this.txHash,
      txValue: txValue ?? this.txValue,
      timestamp: timestamp ?? this.timestamp,
      operation: operation ?? this.operation,
      isPending: isPending ?? this.isPending,
      isSuccess: isSuccess ?? this.isSuccess,
      remark: remark ?? this.remark,
    );
  }

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      isIn: json['isIn'],
      address: json['address'],
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
      'isIn': isIn,
      'address': address,
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
    return other is TransactionDetail &&
        other.isIn == isIn &&
        other.address == address &&
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
    return isIn.hashCode ^
        address.hashCode ^
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
    return 'Transaction(isIn: $isIn, address: $address,txHash: $txHash,txValue: $txValue,timestamp: $timestamp, operation: $operation, isPending: $isPending,isSuccess: $isSuccess, remark: $remark)';
  }
}
