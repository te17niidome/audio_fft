import 'package:audio_fft/analyze_page_controller.dart';
import 'package:audio_fft/audio_state.dart';
import 'package:audio_fft/microphone_permission_handler.dart';
import 'package:audio_fft/spectrogram_state.dart';
import 'package:audio_fft/wave_painter.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnalyzePage extends HookConsumerWidget {
  AnalyzePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // マイク許可
    final mic_permission = useMemoized(MicrophonePermissionsHandler().request);
    final snapshot = useFuture(mic_permission);

    if (snapshot.hasData) {
      if (snapshot.data == MicrophonePermissionStatus.granted ||
          snapshot.data == MicrophonePermissionStatus.limited) {
        // 許可：OK
        return Scaffold(
          body: _buildBody(),
        );
      } else {
        // 許可：NG
        return Scaffold(
          body: Center(
            child: Text("ERROR!"),
          ),
        );
      }
    } else {
      // 許可待ち時間
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

class _buildBody extends HookConsumerWidget {
  _buildBody({super.key});
  final stream = AudioStreamer().audioStream;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _conroller = ref.watch(analyzePageControllerProvider);
    final _audio = ref.watch(audioNotifierProvider);
    final _spectrogram = ref.watch(spectrogramNotifierProvider);

    useEffect(
      () {
        final subscription = stream.listen((List<double> buffer) {
          // 値が更新されたときに呼び出される
          _conroller.onAudio(buffer, ref);
        }, onError: (error) {
          debugPrint("Error ACC: " + error.toString());
        }, cancelOnError: true);
        return subscription.cancel;
      },
      [stream],
    );

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_audio.first.toString()),
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            /// パワースペクトルの描画
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return CustomPaint(
                  painter: WavePainter(_spectrogram, Colors.blue, constraints),
                  // painter: WavePainter(_audio, Colors.blue, constraints),
                );
              },
            ),

            /// ラベルの描画
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  children: label(constraints),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> label(BoxConstraints constraints) {
    final list = <Widget>[];
    const maxFrequency = 44100 / 4;
    for (var i = 0; i < (maxFrequency / 1000); i++) {
      list.add(
        Positioned(
          bottom: 50,
          left: i * (constraints.maxWidth / (maxFrequency / 1000)),
          child: Text(
            '${i}k',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return list;
  }
}
