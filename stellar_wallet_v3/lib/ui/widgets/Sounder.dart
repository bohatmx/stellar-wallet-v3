import 'package:audioplayer/audioplayer.dart';
import 'package:stellar_wallet_v3/ui/PresentQRCode.dart';
import 'package:stellar_wallet_v3/ui/cccount_details.dart';

class Sounder {
  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  bool isMuted;
  Duration duration;
  Duration position;
  AccountDetails accountDetails;
  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

//    audioPlayer.setDurationHandler((d) {
//      accountDetails.setState(() {
//
//      });
//    });
//    audioPlayer.setDurationHandler((d) => setState(() {
//      duration = d;
//    }));
//
//    audioPlayer.setPositionHandler((p) => setState(() {
//      position = p;
//    }));
//
//    audioPlayer.setCompletionHandler(() {
//      onComplete();
//      setState(() {
//        position = duration;
//      });
//    });
//
//    audioPlayer.setErrorHandler((msg) {
//      setState(() {
//        playerState = PlayerState.stopped;
//        duration = new Duration(seconds: 0);
//        position = new Duration(seconds: 0);
//      });
//    });
//  }
//
//  Future _playSound() async {
//    final file = new File('${(await getTemporaryDirectory()).path}/drama.mp3');
//    await file.writeAsBytes((await _loadAsset()).buffer.asUint8List());
//    final result = await audioPlayer.play(file.path, isLocal: true);
//    if (result == 1) setState(() => playerState = PlayerState.playing);
//  }
//
//  Future<ByteData> _loadAsset() async {
//    var path;
//    var index = rand.nextInt(5);
//    switch (index) {
//      case 0:
//        path = 'assets/pin.mp3';
//        break;
//      case 1:
//        path = 'assets/glass.mp3';
//        break;
//      case 20:
//        path = 'assets/ting.mp3';
//        break;
//      case 3:
//        path = 'assets/coins.mp3';
//        break;
//      case 4:
//        path = 'assets/flyby.mp3';
//        break;
//      case 5:
//        path = 'assets/drama.mp3';
//        break;
//      default:
//        path = 'assets/coins.mp3';
//        break;
//    }
//    print('loading asset $path ----------------');
//    return await rootBundle.load(path);
//  }
//
//  Future pause() async {
//    final result = await audioPlayer.pause();
//    if (result == 1) setState(() => playerState = PlayerState.paused);
//  }
//
//  Future stop() async {
//    final result = await audioPlayer.stop();
//    if (result == 1)
//      setState(() {
//        playerState = PlayerState.stopped;
//        position = new Duration();
//      });
//  }
//
//  Future mute(bool muted) async {
//    final result = await audioPlayer.mute(muted);
//    if (result == 1)
//      setState(() {
//        isMuted = muted;
//      });
//  }
//
//  void onComplete() {
//    //setState(() => playerState = PlayerState.stopped);
//  }
  }
}
