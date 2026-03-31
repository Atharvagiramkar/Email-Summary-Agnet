import 'package:flutter/material.dart';

extension ValueNotifierAsStream<T> on ValueNotifier<T> {
  Stream<T> asStream() async* {
    yield value;
    yield* Stream<T>.multi((controller) {
      void listener() => controller.add(value);
      addListener(listener);
      controller.onCancel = () => removeListener(listener);
    });
  }
}
