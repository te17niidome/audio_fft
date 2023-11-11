import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'spectrogram_state.g.dart';

@riverpod
class SpectrogramNotifier extends _$SpectrogramNotifier {
  @override
  Float64List build() {
    return Float64List(1);
  }

  void updateState(spectrogram) {
    state = Float64List.fromList([...spectrogram]);
  }
}
