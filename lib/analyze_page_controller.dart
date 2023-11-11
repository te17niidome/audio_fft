import 'dart:math';
import 'dart:typed_data';

import 'package:audio_fft/audio_state.dart';
import 'package:audio_fft/spectrogram_state.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:fftea/fftea.dart';
import 'package:fftea/stft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analyze_page_controller.g.dart';

@riverpod
AnalyzePageController analyzePageController(AnalyzePageControllerRef ref) {
  return AnalyzePageController();
}

const LENGTH = 32768;
const SAMPLE_LATE = 44100;

class AnalyzePageController {
  /// プライベート変数
  // TODO: プライベート変数を記述
  List<double> _audio = List<double>.filled(LENGTH, 0);

  /// メソッド
  // TODO: 任意の処理を実装
  void onAudio(List<double> buffer, WidgetRef ref) {
    for (var i = 0; i < buffer.length; i++) {
      _audio[i] = buffer[i];
    }
    ref.read(audioNotifierProvider.notifier).updateState(_audio);

    // FFT
    final _spectrogram = fft();

    // パワースペクトルをdBに変換
    var _spectrogram_dB = [];
    for (var _index in _spectrogram) {
      _spectrogram_dB.add(-10 * (log10(_index)));
    }

    // 保存
    ref.read(spectrogramNotifierProvider.notifier).updateState(_spectrogram_dB);
  }

  Float64List fft() {
    final fft = FFT(_audio.length);
    final c = fft.realFft(_audio);

    // discardConjugatesで余分な半分を取り除き，
    // magnitudeで振幅を求めて返す．
    return c.discardConjugates().magnitudes();
  }

  List<Float64List> stft() {
    final chunkSize = 2048;
    final stft = STFT(chunkSize, Window.hanning(chunkSize));

    final spectrogram = <Float64List>[];
    stft.run(_audio, (Float64x2List freq) {
      spectrogram.add(freq.discardConjugates().magnitudes());
    });
    return spectrogram; // data_length(2^15)/chunkSize(2048)の長さの配列
  }
}
