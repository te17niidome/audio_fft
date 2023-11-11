import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'audio_state.g.dart';

@riverpod
class AudioNotifier extends _$AudioNotifier {
  @override
  List<double> build() {
    return [0];
  }

  void updateState(List<double> audio) {
    state = [...audio];
  }
}
