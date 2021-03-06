// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// Emits values from the stream until [trigger] fires.
///
/// Completing [trigger] differs from canceling a subscription in that values
/// which are emitted before the trigger, but have further asynchronous delays
/// in transformations following the takeUtil, will still go through. Cancelling
/// a subscription immediately stops values.
StreamTransformer<T, T> takeUntil<T>(Future<void> trigger) =>
    _TakeUntil(trigger);

class _TakeUntil<T> extends StreamTransformerBase<T, T> {
  final Future<void> _trigger;

  _TakeUntil(this._trigger);

  @override
  Stream<T> bind(Stream<T> values) {
    var controller = values.isBroadcast
        ? StreamController<T>.broadcast(sync: true)
        : StreamController<T>(sync: true);

    StreamSubscription<T> subscription;
    var isDone = false;
    _trigger.then((_) {
      if (isDone) return;
      isDone = true;
      subscription?.cancel();
      controller.close();
    });

    controller.onListen = () {
      if (isDone) return;
      subscription = values.listen(controller.add, onError: controller.addError,
          onDone: () {
        if (isDone) return;
        isDone = true;
        controller.close();
      });
      if (!values.isBroadcast) {
        controller
          ..onPause = subscription.pause
          ..onResume = subscription.resume;
      }
      controller.onCancel = () {
        if (isDone) return null;
        var toCancel = subscription;
        subscription = null;
        return toCancel.cancel();
      };
    };
    return controller.stream;
  }
}
