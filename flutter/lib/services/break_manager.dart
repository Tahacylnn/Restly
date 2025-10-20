import 'dart:async';
import 'api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreakManager {
  static final BreakManager _i = BreakManager._();
  factory BreakManager() => _i;
  BreakManager._();

  Timer? _timer;
  DateTime? currentEnd;
  String? currentBreakId;
  String? token;
  VoidCallback? onUpdate;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    token = sp.getString('jwt');
  }

  Future<void> startBreak(String type, {int requestedMinutes=10}) async {
    if (token==null) {
      throw Exception('Not authenticated (set token in SharedPreferences for demo)');
    }
    final res = await Api.startBreak(token!, type);
    if (res.statusCode == 201 || res.statusCode == 200) {
      currentBreakId = 'local-'+DateTime.now().millisecondsSinceEpoch.toString();
      currentEnd = DateTime.now().add(Duration(minutes: (type=='meal'?25:10)));
      _startTimer();
      onUpdate?.call();
    } else {
      throw Exception('start failed');
    }
  }

  void _startTimer(){
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds:1), (_){
      if (currentEnd != null && DateTime.now().isAfter(currentEnd!)) {
        stopBreak();
      } else {
        onUpdate?.call();
      }
    });
  }

  Future<void> stopBreak() async {
    if (currentBreakId == null) return;
    if (token!=null) {
      await Api.stopBreak(token!, currentBreakId!);
    }
    currentBreakId = null;
    currentEnd = null;
    _timer?.cancel();
    onUpdate?.call();
  }

  Duration? remaining(){
    if (currentEnd == null) return null;
    final r = currentEnd!.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  void dispose(){ _timer?.cancel(); }
}
