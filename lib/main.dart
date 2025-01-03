import 'package:education_apps/app/modules/loading_screen/views/loading_screen_view.dart';
import 'package:education_apps/app/modules/profile/views/profile_settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:education_apps/provider/auth_provider.dart';
import 'package:education_apps/provider/imagepick_provider.dart';
import 'package:education_apps/app/modules/home/views/home_view.dart';
import 'package:education_apps/screen/login_screen.dart';
import 'package:education_apps/app/modules/course/views/course_view.dart';
import 'package:education_apps/app/modules/news/views/news_view_.dart';
import 'package:education_apps/app/modules/profile/views/Profile_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler for background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProfider()),
        ChangeNotifierProvider(create: (_) => ImagePickProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        // Check if the user is logged in before showing the main screen
        home: AuthCheckScreen(),
      ),
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check login status
    final User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // If user is logged in, navigate to HomeView
      return MainPage();
    } else {
      // If user is not logged in, navigate to LoginScreen
      return LoadingScreenView();
    }
  }
}

// MainPage with FlashyTabBar
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final RxInt _selectedIndex = 0.obs;

  final List<Widget> _pages = [
    HomeView(),
    CourseView(),
    NewsView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Registration Token: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("New FCM Registration Token: $newToken");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[_selectedIndex.value]),
      bottomNavigationBar: Obx(() {
        return FlashyTabBar(
          selectedIndex: _selectedIndex.value,
          onItemSelected: (index) {
            _selectedIndex.value = index;
          },
          items: [
            FlashyTabBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              activeColor:
                  Color.fromARGB(255, 47, 154, 255), // Active icon color
              inactiveColor: Colors.grey, // Inactive icon color
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.school),
              title: Text("Courses"),
              activeColor: Color.fromARGB(255, 47, 154, 255),
              inactiveColor: Colors.grey,
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.newspaper),
              title: Text("News"),
              activeColor: Color.fromARGB(255, 47, 154, 255),
              inactiveColor: Colors.grey,
            ),
            FlashyTabBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              activeColor: Color.fromARGB(255, 47, 154, 255),
              inactiveColor: Colors.grey,
            ),
          ],
          animationDuration: Duration(milliseconds: 300),
          showElevation: true,
          backgroundColor: Colors.white, // Background color of the tab bar
        );
      }),
    );
  }
}
