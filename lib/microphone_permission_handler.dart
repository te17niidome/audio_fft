// mirophone_permission_handler.dart
import 'package:permission_handler/permission_handler.dart';

enum MicrophonePermissionStatus {
  granted,
  denied,
  restricted,
  limited,
  permanentlyDenied
}

class MicrophonePermissionsHandler {
  Future<bool> get isGranted async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return false;
      default:
        return false;
    }
  }

  Future<MicrophonePermissionStatus> request() async {
    final status = await Permission.microphone.request();
    switch (status) {
      case PermissionStatus.granted:
        return MicrophonePermissionStatus.granted;
      case PermissionStatus.denied:
        return MicrophonePermissionStatus.denied;
      case PermissionStatus.limited:
        return MicrophonePermissionStatus.limited;
      case PermissionStatus.restricted:
        return MicrophonePermissionStatus.restricted;
      case PermissionStatus.permanentlyDenied:
        return MicrophonePermissionStatus.permanentlyDenied;
      default:
        return MicrophonePermissionStatus.denied;
    }
  }
}
