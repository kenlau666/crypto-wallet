import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class GlobalBlocObserver extends BlocObserver {
  const GlobalBlocObserver();

  // @override
  // void onCreate(BlocBase<dynamic> bloc) {
  //   super.onCreate(bloc);
  //
  //   log("onCreate()", name: "${bloc.runtimeType}");
  // }
  //
  // @override
  // void onClose(BlocBase<dynamic> bloc) {
  //   super.onClose(bloc);
  //
  //   log("onClose()", name: "${bloc.runtimeType}");
  // }
  //
  // @override
  // void onEvent(Bloc bloc, Object? event) {
  //   super.onEvent(bloc, event);
  //
  //   log("onEvent(): $event", name: "${bloc.runtimeType}");
  // }
  //
  // @override
  // void onChange(BlocBase bloc, Change change) {
  //   super.onChange(bloc, change);
  //
  //   log("onChange(): $change", name: "${bloc.runtimeType}");
  //   // log("onChange()", name: "${bloc.runtimeType}");
  // }

  // @override
  // void onTransition(Bloc bloc, Transition transition) {
  //   super.onTransition(bloc, transition);
  //
  //   log("onTransition(): $transition", name: "${bloc.runtimeType}");
  // }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("[${bloc.runtimeType}] onError(): $error: $stackTrace");
    super.onError(bloc, error, stackTrace);
  }
}
