part of 'providers.dart';

class IoBloc extends ChangeNotifier {
  static const topic = "news";

  IoBloc({String server}) {
    init(server);
  }

  SocketIO _socket;
  List<Message> _messages;
  List<Message> get messages => _messages;

  Future<void> init(String server) async {
    SocketIOManager manager = SocketIOManager();
    SocketOptions options = SocketOptions(
      server,
      enableLogging: false,
    );
    _socket = await manager.createInstance(options);
    _socket.onConnect((data) {
      print('Connected with data: $data');
      //sendMessage(message: "Hello, Flutter!");
    });
    _socket.connect();
    _socket.on(topic, onNewMessage);
    _socket.on('disconnect', (_) => print('disconnect'));
    _socket.on('fromServer', (_) => print(_));
  }

  void sendMessage({dynamic message}) {
    final data = <String, dynamic>{
      'username': AuthBloc.username,
      Message.secretTag: AuthBloc.user.$data,
      'message': message,
    };
    _socket.emit(topic, [data]);
    _addMessage(Message.fromMap(data));
  }

  void onNewMessage(dynamic data) {
    print('onNewMessage: (${data.runtimeType}) $data');

    // Force to cast Map<dynamic,dynamic> to Map<String, dynamic> in ios
    final m = Message.fromMap(<String, dynamic>{
      'username': data['username'],
      'user': data['user'],
      'message': data['message'],
    });
    print(m.user.$data);
    return _addMessage(m);
  }

  void _addMessage(Message message) {
    const maxMessages = 50;
    if (_messages == null) {
      _messages = [];
    } else if (_messages.length == maxMessages) {
      _messages.removeAt(0);
    }

    _messages.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _messages = null;
    super.dispose();
  }
}
