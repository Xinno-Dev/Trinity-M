import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:trinity_m_00/domain/viewModel/market_view_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../common/provider/firebase_provider.dart';
import '../../../common/provider/login_provider.dart';
import '../../../common/provider/market_provider.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../domain/model/app_start_model.dart';
import '../../../presentation/view/main_screen.dart';
import '../../../services/localization_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:logger/logger.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../firebase_options.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../presentation/view/signup/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart' as provider;
import 'common/const/utils/convertHelper.dart';
import 'common/const/utils/dialogHelper.dart';
import 'common/const/utils/languageHelper.dart';
import 'common/const/utils/localStorageHelper.dart';
import 'common/provider/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'common/provider/language_provider.dart';
import 'domain/viewModel/profile_view_model.dart';

/////////////////////////////
final logger = Logger(
  printer: PrettyPrinter(),
);
final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);
///////////////////////////////

final navigatorKey = GlobalKey<NavigatorState>();

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
String? _lastConsumedMessageId;
DateTime? currentBackPressTime;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> main() async {
  // demo();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // init kakao..
  KakaoSdk.init(
    nativeAppKey: 'c3f93654a2020273492f218aba8f7e69',
    javaScriptAppKey: '36d85e37ca3e597f8c6dacd1820bf016',
  );

  // init firebase..
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // await FirebaseAppCheck.instance.activate(
  //   webProvider: ReCaptchaV3Provider('6Ldzot8pAAAAAFreQ89tKciFuJV9assNxUWDJpR-'),
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.appAttest,
  // );

  //background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //Foreground
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Check if you received the link via `getInitialLink` first
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    LOG('---> initialLink : $deepLink');
    // Example of using the dynamic link to push the user to a different screen
    // Navigator.pushNamed(context, deepLink.path);
  }

  FirebaseDynamicLinks.instance.onLink.listen(
        (dynamicLink) {
      // Set up the `onLink` event listener next as it may be received here
      // if (pendingDynamicLinkData.link.isAbsolute) {
        final Uri deepLink = dynamicLink.link;
        LOG('---> dynamicLink : $deepLink');
        // Example of using the dynamic link to push the user to a different screen
        // Navigator.pushNamed(context, deepLink.path);
      // }
    },
  );

  // await FirebaseMessaging.instance.getToken().then((value) {
  //   print('Token value : $value');
  // });

  //isGlobalLogin = await UserHelper().get_loginDate();

  // reset user data..
  final prefs = await SharedPreferences.getInstance();

  if (await prefs.getBool(FIRSTRUN_KEY) ?? true) {
    FlutterSecureStorage storage = FlutterSecureStorage();
    isGlobalLogin = false;
    await storage.deleteAll();
    await UserHelper().clearUser();
    await prefs.setBool(FIRSTRUN_KEY, false);
  }
  print(await UserHelper().get_userID());

  // runApp(const MyApp());
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (context) => FirebaseProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => LanguageProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => CoinProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => NavigationProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => StakesData(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => NetworkProvider(),
          ),
          provider.ChangeNotifierProvider(
            create: (context) => MarketProvider()
          ),
          provider.ChangeNotifierProvider(
            create: (context) => LoginProvider()
          )
        ],
        child: FutureBuilder(
          future: MarketProvider().getStartData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MyApp();
            } else {
              return showLoadingFull(50);
            }
          }
        )
      ),
    ),
    // ProviderScope(
    //     observers: [LoggerProvder()],
    //     child: provider.ChangeNotifierProvider(
    //         create: (context) => StakesData(), child: const MyApp())),
  );
}

class LoggerProvder extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}

final appLocaleDelegate = AppLocalizationDelegate();

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(languageProvider);

    var pushToken = provider.Provider.of<FirebaseProvider>(context,
        listen: false).pushToken;
    print('---> main locale : ${lang.getLocale} / ${pushToken}');

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, child) => MaterialApp.router(
        key: navigatorKey,
        theme: ThemeData(fontFamily: 'Pretendard'),
        debugShowCheckedModeBanner: false,
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        localizationsDelegates: [
          appLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: LanguageHelper.supportedLocales,
        locale: lang.getLocale
      )
    );
  }
}

//firebase 관련 설정들 이곳에 설정 후 다음 화면 ex) 메인 으로 넘어갈 수 있도록 작성.
class FirebaseSetup extends ConsumerStatefulWidget {
  const FirebaseSetup({
    super.key,
  });
  static String get routeName => 'firebaseSetup';

  @override
  ConsumerState<FirebaseSetup> createState() => _FirebaseSetupState();
}

class _FirebaseSetupState extends ConsumerState<FirebaseSetup> {
  bool initLogin = false;

  @override
  void initState() {
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); //Icon 설정

    var initialzationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      var androidNotiDetails = AndroidNotificationDetails(
          channel.id, channel.name,
          channelDescription: channel.description, icon: android?.smallIcon);

      var iOSNotiDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      var details =
          NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);

      if (notification != null) {
        Map<String, dynamic> _payload = Map<String, dynamic>.from(message.data)
          ..addAll({"body": "${message.notification?.body}"});
        String _payloadString = jsonEncode(_payload);
        print('response : $_payloadString');
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(notification.hashCode,
              notification.title, notification.body, details,
              payload: _payloadString);
        }
        //푸시 메세지 수신 시 초기화면으로 이동
        // context.go('/firebaseSetup');
        // context.pushReplacement('/firebaseSetup');

        // context.pushNamed(AuthPasswordScreen.routeName, queryParams: {
        //   'noti': _payloadString,
        //   'auth': 'true',
        // });
      }
    });

    // //알림이 왔을 때 사용되는 listner
    // //App이 Background일 때 사용되는 함수.
    // FirebaseMessaging.onMessageOpenedApp
    //     .listen((event) => _handleMessage(event));

    //요주의 함수. iOS 에서 noti 선택했을때 호출 되는것으로 보임.
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('onMessageOpenedApp');
      _handleMessage(event);
    });

    //App이 Terminated 되었고, 그 상태에서 앱을 실행하면 실행되는 함수.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) _handleMessage(message);
    });

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) =>
                onSelectNotification(notificationResponse.payload ?? ''),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    super.initState();

    if (defaultTargetPlatform == TargetPlatform.android) {
      setupInteractedMessage();
    }
  }

//TODO: - Android Select Notification
  Future<void> onSelectNotification(String payload) async {
    print('onSelectNotification : $payload');
    // navService.pushNamed(SignGenerateScreen.routeName);
    // context.pushNamed(SignGenerateScreen.routeName);
    // context.go('/firebaseSetup');
    // context.goNamed(FirebaseSetup.routeName);
    // context.pushReplacement('/firebaseSetup');
    // context.pushNamed(AuthPasswordScreen.routeName, queryParams: {
    //   'noti': payload,
    //   'auth': 'true',
    // });

    // FcmPushData fcmPushData = FcmPushData.fromPaylad(payload);
    // fcmPushData.openDialog(context);
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // //알림이 왔을 때 사용되는 listner
    // //App이 Background일 때 사용되는 함수.

    FirebaseMessaging.onMessageOpenedApp
        .listen(((event) => _handleMessage(event)));
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    print('mounted : $mounted');
    if (!mounted) return;
    print('_messageAlreadyConsumed : ${message.messageId}');
    if (_messageAlreadyConsumed(message.messageId)) return;

    Map<String, dynamic> _payload = Map<String, dynamic>.from(message.data)
      ..addAll({"body": "${message.notification?.body}"});

    String _payloadString = jsonEncode(_payload);

    //TODO: - 어떤 noti  가 왔을때 어디로 보내야 할지 분기처리가 필요함.
    // context.pushNamed(SignGenerateScreen.routeName,
    //     queryParams: {'noti': _payloadString});
    // context.go('/firebaseSetup');
    // context.goNamed(FirebaseSetup.routeName);
    // context.pushReplacement('/firebaseSetup');
    // context.go('location')
    // context.pushNamed(AuthPasswordScreen.routeName, queryParams: {
    //   'noti': _payloadString,
    //   'auth': 'true',
    // });

    // context.pushNamed('signGenerate');
    // Navigator.of(context).pushNamed(SignGenerateScreen.routeName);
    // return;
    // FcmPushData fcmPushData = FcmPushData.fromPaylad(_payloadString);

    // WidgetsBinding.instance!.addPostFrameCallback(
    //     (_) => );
    // fcmPushData.openDialog(context);
  }

  bool _messageAlreadyConsumed(String? newMessageId) {
    if (_lastConsumedMessageId == newMessageId) {
      return true;
    }

    _lastConsumedMessageId = newMessageId;
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.read(loginProvider);
    // LOG('---> main : ${loginProv.isLogin}');
    return loginProv.isLogin ? MainScreen() :
      FutureBuilder(
      future: loginProv.checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainScreen();
        } else {
          return showLoadingFull();
        }
      }
    );
  }
}
