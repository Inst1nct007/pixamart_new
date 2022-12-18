import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pixamart/routing/route_generator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:open_store/open_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixamart/front_end/pages/splash_screen.dart';
import 'package:pixamart/backend/model/favourites_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(FavouritesAdapter());
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if(FirebaseAuth.instance.currentUser?.uid != null) {
    await Hive.openBox('${FirebaseAuth.instance.currentUser?.uid}-downloads');
    await Hive.openBox('${FirebaseAuth.instance.currentUser?.uid}-favourites');
  }
  runApp(PixaMartApp(initialLink: initialLink));
}

class PixaMartApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const PixaMartApp({required this.initialLink, Key? key}) : super(key: key);

  @override
  State<PixaMartApp> createState() => _PixaMartAppState();
}

class _PixaMartAppState extends State<PixaMartApp> {
  late PackageInfo packageInfo;
  late CollectionReference buildNumber;
  late RxDouble opacityManager = 0.0.obs;
  late RouteGenerator route;

  @override
  void initState() {
    super.initState();
    buildNumber = FirebaseFirestore.instance.collection('version');
    initializePackageInfo();
    route = RouteGenerator();
    route.initialLink = widget.initialLink;
  }

  initializePackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    await buildNumber.doc('appVersion').get().then((value) => {
      if (value
          .data()
          .toString()
          .substring(0, value.data().toString().length - 1)
          .split(':')[1]
          .removeAllWhitespace !=
          packageInfo.buildNumber)
        {opacityManager.value = 1.0}
    });
    return packageInfo;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: FutureBuilder(
          future: initializePackageInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (opacityManager.value == 1) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 550),
                  opacity: opacityManager.value,
                  child: AlertDialog(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update PixaMart?',
                          style: TextStyle(
                              fontSize:
                              MediaQuery.of(context).size.height / 41.721),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 27.814,
                        ),
                        Text(
                          'PixaMart recommends that you update to the latest version.',
                          style: TextStyle(
                              fontSize:
                              MediaQuery.of(context).size.height / 52.151),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 27.814,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white, elevation: 0),
                              child: Text('No thanks',
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize:
                                      MediaQuery.of(context).size.height /
                                          64.186)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                OpenStore.instance.open(
                                    androidAppBundleId:
                                    'com.wallpaper.pixamart');
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SplashScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.greenAccent, elevation: 0),
                              child: Text(
                                'Update',
                                style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.height /
                                        64.186),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SplashScreen();
            }
            return Container();
          }),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      title: 'PixaMart',
      onGenerateRoute: route.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: Theme.of(context).textTheme.headline6,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
