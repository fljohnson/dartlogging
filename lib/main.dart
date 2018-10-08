import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: new MyHomePage(title: 'Flutter Demo Home Page'),
      // MaterialApp contains our top-level Navigator
     initialRoute: '/',
     routes: {
       '/': (BuildContext context) => new MyHomePage(title: 'Flutter Demo Home Page'),
       '/signup': (BuildContext context) => new SignUpPage(),
     },
    );
  }
}

class SignUpPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // SignUpPage builds its own Navigator which ends up being a nested
    // Navigator in our app.
    return new Navigator(
      initialRoute: 'signup/personal_info',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'signup/personal_info':
          // Assume CollectPersonalInfoPage collects personal info and then
          // navigates to 'signup/choose_credentials'.
            builder = (BuildContext _) => new CollectPersonalInfoPage();
            break;
          case 'signup/choose_credentials':
          // Assume ChooseCredentialsPage collects new credentials and then
          // invokes 'onSignupComplete()'.
            builder = (BuildContext _) => new ChooseCredentialsPage(
              onSignupComplete: () {
                // Referencing Navigator.of(context) from here refers to the
                // top level Navigator because SignUpPage is above the
                // nested Navigator that it created. Therefore, this pop()
                // will pop the entire "sign up" journey and return to the
                // "/" route, AKA HomePage.
                Navigator.of(context).pop();
              },
            );
            break;
          default:
            throw new Exception('Invalid route: ${settings.name}');
        }
        return new MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class CollectPersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: new Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug paint" (press "p" in the console where you ran
            // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
            // window in IntelliJ) to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Here is one page',
              ),
            ],
          ),
        )
    );
  }
}

class ChooseCredentialsPage extends StatelessWidget {
  ChooseCredentialsPage({Null onSignupComplete()});
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
        appBar: new AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: new Text("URK"),
    ),
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: new Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug paint" (press "p" in the console where you ran
            // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
            // window in IntelliJ) to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Here is other page',
              ),
            ],
          ),
        )
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _movePage() {

    Navigator.of(context).push(new MaterialPageRoute(
      builder: new ChooseCredentialsPage().build,
      settings: new RouteSettings(name:"signup/choose_credentials")
    ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _movePage,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
