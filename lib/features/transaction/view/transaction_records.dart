import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/transaction_cubit.dart';
import '../model/transaction.dart';

class TransactionRecordPage extends StatefulWidget {
  const TransactionRecordPage({Key? key}) : super(key: key);

  @override
  State<TransactionRecordPage> createState() => _TransactionRecordPageState();
}

class _TransactionRecordPageState extends State<TransactionRecordPage> {
  @override
  void initState() {
    context.read<TransactionCubit>().initializeWebSocket(
        privateKey: "1",
        publicKey: "0x123d551F438D6921BD92d7a82610a33861b075d2");
    super.initState();
  }

  @override
  void dispose() {
    context.read<TransactionCubit>().closeWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStatus.failure &&
            state.errorMessage != "") {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        if (state.status == TransactionStatus.pending) {
          return const Center(
            child: Text("loading UI"),
          );
        } else if (state.status == TransactionStatus.success) {
          return Center(
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.transactions.length > 10
                        ? 10
                        : state.transactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      TransactionDetail txn =
                          state.transactions.values.elementAt(index);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                txn.isIn ? "Receive" : "Send",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                txn.txValue,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              txn.isIn
                                  ? const Icon(Icons.call_received, color: Colors.green,)
                                  : const Icon(Icons.call_made, color: Colors.red),
                              Text(
                                txn.timestamp.toString().substring(
                                    0, txn.timestamp.toString().length - 7),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                txn.isIn ? "From: " : "To: ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white),
                              ),
                              Text(
                                "${txn.address.substring(0, 5)}...${txn.address.substring(txn.address.length - 4)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Divider(
                            height: 1,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      );
                    }),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text("loading UI"),
          );
        }
      },
    );
  }
}
