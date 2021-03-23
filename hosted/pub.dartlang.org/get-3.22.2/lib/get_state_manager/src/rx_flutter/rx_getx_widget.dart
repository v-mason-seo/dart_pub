import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../get_core/get_core.dart';
import '../../../get_instance/src/get_instance.dart';
import '../../../get_rx/src/rx_types/rx_types.dart';
import '../../get_state_manager.dart';

typedef GetXControllerBuilder<T extends DisposableInterface> = Widget Function(
    T controller);

class GetX<T extends DisposableInterface> extends StatefulWidget {
  final GetXControllerBuilder<T> builder;
  final bool global;

  // final Stream Function(T) stream;
  // final StreamController Function(T) streamController;
  final bool autoRemove;
  final bool assignId;
  final void Function(State state) initState, dispose, didChangeDependencies;
  final void Function(GetX oldWidget, State state) didUpdateWidget;
  final T init;
  final String tag;

  const GetX({
    this.tag,
    this.builder,
    this.global = true,
    this.autoRemove = true,
    this.initState,
    this.assignId = false,
    //  this.stream,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.init,
    // this.streamController
  });

  @override
  GetXState<T> createState() => GetXState<T>();
}

class GetXState<T extends DisposableInterface> extends State<GetX<T>> {
  GetXState() {
    _observer = RxNotifier();
  }
  RxInterface _observer;
  T controller;
  bool isCreator = false;
  StreamSubscription subs;

  @override
  void initState() {
    var isPrepared = GetInstance().isPrepared<T>(tag: widget.tag);
    var isRegistered = GetInstance().isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isPrepared) {
        if (Get.smartManagement != SmartManagement.keepFactory) {
          isCreator = true;
        }
        controller = GetInstance().find<T>(tag: widget.tag);
      } else if (isRegistered) {
        controller = GetInstance().find<T>(tag: widget.tag);
        isCreator = false;
      } else {
        controller = widget.init;
        isCreator = true;
        GetInstance().put<T>(controller, tag: widget.tag);
      }
    } else {
      controller = widget.init;
      isCreator = true;
      controller?.onStart();
    }
    if (widget.initState != null) widget.initState(this);
    if (widget.global && Get.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }
    subs = _observer.listen((data) => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies(this);
    }
  }

  @override
  void didUpdateWidget(GetX oldWidget) {
    super.didUpdateWidget(oldWidget as GetX<T>);
    if (widget.didUpdateWidget != null) widget.didUpdateWidget(oldWidget, this);
  }

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose(this);
    if (isCreator || widget.assignId) {
      if (widget.autoRemove && GetInstance().isRegistered<T>(tag: widget.tag)) {
        GetInstance().delete<T>(tag: widget.tag);
      }
    }
    subs.cancel();
    _observer.close();
    controller = null;
    isCreator = null;
    super.dispose();
  }

  Widget get notifyChildren {
    final observer = RxInterface.proxy;
    RxInterface.proxy = _observer;
    final result = widget.builder(controller);
    if (!_observer.canUpdate) {
      throw """
      [Get] the improper use of a GetX has been detected. 
      You should only use GetX or Obx for the specific widget that will be updated.
      If you are seeing this error, you probably did not insert any observable variables into GetX/Obx 
      or insert them outside the scope that GetX considers suitable for an update 
      (example: GetX => HeavyWidget => variableObservable).
      If you need to update a parent widget and a child widget, wrap each one in an Obx/GetX.
      """;
    }
    RxInterface.proxy = observer;
    return result;
  }

  @override
  Widget build(BuildContext context) => notifyChildren;
}
