part of 'transaction_cubit.dart';

enum TransactionStatus {
  initial,
  pending,
  minting,
  success,
  failure,
}

final class TransactionState extends Equatable {
  TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = _emptyTransaction,
    this.errorMessage,
  });

  final TransactionStatus status;
  final Map<String,TransactionDetail> transactions;
  static const Map<String,TransactionDetail> _emptyTransaction = {};
  final String? errorMessage;

  TransactionState copyWith({
    TransactionStatus? status,
    Map<String,TransactionDetail>? transactions,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        errorMessage,
      ];
}
