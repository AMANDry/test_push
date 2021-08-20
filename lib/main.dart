import 'package:flutter/material.dart';
import 'package:test_push/second_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_push/third_screen.dart';
import '/services/local_notification_service.dart';
import 'first_screen.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print(message.data.toString());
  print('background message ${message.notification!.body}');
  print('background message ${message.notification!.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        "first": (_) => FirstScreen(),
        "second": (_) => SecondScreen(),
        "third": (_) => ThirdScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String messageTitle = "Empty";

  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });

    //when the app is in background but still works
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data['route'];
      Navigator.of(context).pushNamed(routeFromMessage);
      // print(routeFromMessage);
      print('Message clicked!');
    });

    //foreground work
    FirebaseMessaging.onMessage.listen(
      (message) {
        setState(() {
          messageTitle = message.data["title"];
        });

        print('i got printed the message title : $messageTitle');
        LocalNotificationService.display(message);
        // print("message received");
        // if (message.notification != null) {
        //   print(message.notification!.body);
        //   print(message.notification!.title);
        // }

        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text("Notification"),
        //       content: Text(message.notification!.body!),
        //       actions: [
        //         TextButton(
        //           child: Text("Ok"),
        //           onPressed: () {
        //             Navigator.pop(context);
        //           },
        //         )
        //       ],
        //     );
        //   },
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('first');
                },
                child: Text('send')),
            Text('Main'),
            Text(
              messageTitle,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
