import 'package:firebase_messaging/firebase_messaging.dart';

final logger = SimpleLogger()
  ..setLevel(
    Level.ALL,
    includeCallerInfo: true, // ログ出力時に、対象ファイルと行を表示
  );

class PushUtility {
  factory PushUtility() => _instance;
  static final PushUtility _instance = PushUtility._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  PushUtility._internal();

  Future<void> init() async {
    final _fcmTokensStream = _firebaseMessaging.onTokenRefresh;

    //iOSのフォアグラウンドのプッシュ通知のオプションを追加
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    //バッググラウンド状態でプッシュ通知押下で、アプリを起動した時の処理
    FirebaseMessaging.onMessageOpenedApp.listen(notificationMessage);

    //Tokenを取得
    _firebaseMessaging.getToken().then(refreshToken);

    //Tokenの変更を監視
    _fcmTokensStream.listen(refreshToken);

    //全体push通知
    _firebaseMessaging.subscribeToTopic('all');
  }

  void refreshToken(String? token) {
    logger.info('token : $token');
  }

  void notificationMessage(RemoteMessage? message) {
    logger.info('notification message');
    logger.info('title ➡ ${message!.notification!.title}');
    logger.info('body ➡ ${message.notification!.body}');
    logger.info('data ➡ ${message.data}');
  }
}