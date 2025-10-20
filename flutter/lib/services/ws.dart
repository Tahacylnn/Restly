import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:async';

class WsService {
  IOWebSocketChannel? _channel;
  StreamController<Map<String,dynamic>> events = StreamController.broadcast();

  void connect(String wsUrl, String token) {
    final uri = wsUrl.contains('?') ? wsUrl + '&token=$token' : wsUrl + '?token=$token';
    _channel = IOWebSocketChannel.connect(Uri.parse(uri));
    _channel!.stream.listen((msg){
      try {
        final j = jsonDecode(msg);
        events.add(j);
      } catch(e){}
    }, onDone: (){
      Future.delayed(Duration(seconds:3), (){
        // reconnect logic if needed
      });
    }, onError: (e){});
  }

  void send(Map<String,dynamic> m) {
    _channel?.sink.add(jsonEncode(m));
  }

  void dispose(){ _channel?.sink.close(status.goingAway); events.close(); }
}
