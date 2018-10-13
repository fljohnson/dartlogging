import 'dart:async';

import 'package:flutter/material.dart';
import "logitem.dart";
import "pseudoresources.dart";


DatePair loggingRange = new DatePair("09/01/2018","09/30/2018");
DatePair statsRange = new DatePair("09/01/2018","09/30/2018");
Logitem chosen;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp() {
    Logitem.createSampleData();
  }
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
    String content = "(new)";
    if(chosen !=  null)
      {
        content = chosen.title;
      }
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
                'Editing $content',
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
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [new Text("boo")],
          ),
        )
    );
  }
}


class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) :
  super(
  key: key,
      );


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

class _MyHomePageState extends State<MyHomePage>  with SingleTickerProviderStateMixin {

  List<Tab> myTabs = <Tab>[
    new Tab(text: 'Logging'),
    new Tab(text: 'Stats'),
  ];

  List<DatePair> _pageDates;


  TabController _tabController;
  TabBarView _barTool;
  @override
  void initState() {
    super.initState();
  //  _pageDates =[new DatePair("09/01/2018","09/30/2018"),new DatePair("09/01/2018","09/30/2018")];
   // _pages = <Widget>[new LoggingPage(owner:this),new DummyPage()];
    _tabController = new TabController(vsync:this,length: myTabs.length);
    /*
    _barTool = new TabBarView(
        controller: _tabController,
        children:myTabs.map((Tab tab){
      return _pages[myTabs.indexOf(tab)];

    }).toList()
    );*/

  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setDates(DatePair range) {
    setState(() {
      int whichPair=_tabController.index;
      _pageDates[whichPair].setDates(range._date1, range._date2);
    });
  }


  void _movePage() {
/*
    Navigator.of(context).push(new MaterialPageRoute(
      builder: new ChooseCredentialsPage().build,
      settings: new RouteSettings(name:"signup/choose_credentials")
    ));
    */
chosen=null;
Navigator.of(context).pushNamed("/signup");
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
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),

      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        //child:LoggingPage(),

        child:TabBarView(
          controller:_tabController,
          children:[
            LoggingPage(),
            DummyPage()
          ]
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

//mm/dd/yyyy to yyyy-mm-dd
String fromUStoISO(String inDate)
{
  List<String> datelets = inDate.split("/");
  while(datelets[0].length <2)
  {
    datelets[0]= "0" + datelets[0];
  }
  while(datelets[1].length <2)
  {
    datelets[1]= "0" + datelets[1];
  }
  return datelets[2]+"-"+datelets[0]+"-"+datelets[1];
}
class DatePair {
  String _date1;
  String _date2;

  DatePair(String date1,date2)
  {
    setDates(date1,date2);
  }

  void setDate1(String date)
  {
    setDates(date,this._date2);
  }
  void setDate2(String date)
  {
    setDates(this._date1,date);
  }
  void setDates(String date1,date2)
  {
    String comparedate1=fromUStoISO(date1);
    String comparedate2=fromUStoISO(date2);
    if (comparedate1.compareTo(comparedate2)<=0)
    {
      _date1=date1;
      _date2=date2;
    }
    else
    {
      _date1=date2;
      _date2=date1;
    }
  }

  String isoFrom() {
    String comparedate1=fromUStoISO(_date1);
    String comparedate2=fromUStoISO(_date2);
    if (comparedate1.compareTo(comparedate2)<=0)
    {
      return comparedate1;
    }
    else
    {
      return comparedate2;
    }
  }

  String isoTo() {
    String comparedate1=fromUStoISO(_date1);
    String comparedate2=fromUStoISO(_date2);
    if (comparedate1.compareTo(comparedate2)<=0)
    {
      return comparedate2;
    }
    else
    {
      return comparedate1;
    }
  }
}


class LoggingPage extends StatefulWidget {
  LoggingPage({Key key}) :
    super(key:key);

  @override
  _LoggingPageState createState() {
    return new _LoggingPageState();
  }

}

class _LoggingPageState extends State<LoggingPage> {


  Future<String> askDate(BuildContext context,String originalDate) async {
    String rv = originalDate;
    List<String> datelets = originalDate.split("/");
    DateTime currentDate = new DateTime(int.parse(datelets[2]),int.parse(datelets[0]), int.parse(datelets[1]));
    DateTime minDate = new DateTime(currentDate.year,currentDate.month-2,1);
    DateTime maxDate = new DateTime(currentDate.year,currentDate.month+2,-1);
    DateTime value = await showDatePicker(
        context:context,
        initialDate:currentDate,
        firstDate:minDate,
        lastDate:maxDate
    );
    if(value != null)
    {
      rv="${value.month}/${value.day}/${value.year}";
    }
    return rv;
  }

  @override
  /*
  Widget build(BuildContext context){
    return new ListView(
          children:fetchRows()
      );
  }*/
  
  @override
  Widget build(BuildContext context) {
    return new Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /*
        new GestureDetector(
          onTap: () {
            Future<String> newdate = askDate(context,loggingRange._date1);
            newdate.then((value) {
              setState(() {
                loggingRange.setDate1(value);
              });
            });
          },
          child:new Text(
            'From: ${loggingRange._date1}',
            style: Theme
                .of(context)
                .textTheme
                .display1,
          )
        ),
        new GestureDetector(
            onTap: () {
              Future<String> newdate = askDate(context,loggingRange._date2);
              newdate.then((value) {
                setState(() {
                  loggingRange.setDate2(value);
                });

              });
            },
            child:new Text(
              'To: ${loggingRange._date2}',
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            )
        ),
        */
        new FlatButton(
            child:new Text(
              'From: ${loggingRange._date1}',
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            ),
            onPressed:(){
              Future<String> newdate = askDate(context,loggingRange._date1);
              newdate.then((value) {
                setState(() {
                  loggingRange.setDate1(value);
                });
              });
            }
        ),
        new FlatButton(
            child:new Text(
          'To: ${loggingRange._date2}',
          style: Theme
              .of(context)
              .textTheme
              .display1,
        ),
            onPressed:(){
              Future<String> newdate = askDate(context,loggingRange._date2);
              newdate.then((value) {
                setState(() {
                  loggingRange.setDate1(value);
                });
              });
            }
            ),
            Expanded(
               child: ListView(
                    children:fetchRows()
                )
            ),

      ],
    );
  }

  Widget dateMark(String content)
  {
    return Text(content,style: Theme
        .of(context)
        .textTheme
        .headline);
  }

  Widget dataRow(Logitem content)
  {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical:4.0),
      child:new Row(
          children:[
            Expanded(
              flex: 3,
              child: Container(
                  child:Text(content.title,style: Theme
                      .of(context)
                      .textTheme
                      .title)
              ),
            ),


            Expanded(
              flex: 4,
              child: Container(
                  //margin: EdgeInsets.symmetric(horizontal:10.0),
                  child:Text(content.category,style: Theme
                      .of(context)
                      .textTheme
                      .title)
              ),
            ),
            Expanded(
              flex: 2,
            child:Text(content.stramount(),style: Theme
                        .of(context)
                        .textTheme
                        .title,
                      textAlign: TextAlign.right
                          ),
            ),
          ]
      )
        ,
      onPressed: ((){
        chosen = content;
        Navigator.of(context).pushNamed("/signup");
      }),
    );

  }

  List<Widget>fetchRows() {
    List<Widget> rv = [];
    //get the Logitems matching this.range, ordered by date DESC
    List<Logitem> hits = Logitem.getRange(loggingRange.isoFrom(),loggingRange.isoTo());
    String dateLabel = hits[0].thedate;
    Column currentPanel; //rename this to reflect "just completed"
    List<Widget> panelBody = [];

    panelBody.add(dateMark("Date: $dateLabel"));
    panelBody.add(dataRow(hits[0]));
    for(int i=1;i<hits.length;i++)
    {

      if(hits[i].thedate != dateLabel)
        {
          //flush it
/*
          rv.add(
              Text(hits[i].title)
          );
          */
          dateLabel = hits[i].thedate;

          panelBody.add(dateMark("Date: $dateLabel"));
        }
      panelBody.add(dataRow(hits[i]));
    }
    return panelBody;
  }
}




class DummyPage extends StatelessWidget {
  DummyPage({Key key}):super(key:key);

  List<Widget> getTotals()
  {
    List<Widget> rows = [];
    List<Map<String,String>> stats = Logitem.getTotals(statsRange._date1, statsRange._date2);
    for(int i=0;i<stats.length;i++)
    {
      rows.add(
          Row(
            children: <Widget>[
              new Text(stats[i].keys.first),
              new Text(stats[i].values.first)
            ],

          )
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
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
          //mainAxisAlignment: MainAxisAlignment.center,
          children: getTotals(),
        )
    );
  }
}
