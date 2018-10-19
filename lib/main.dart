import 'dart:async';

import 'package:flutter/material.dart';
import "logitem.dart";
import "pseudoresources.dart";


DatePair loggingRange = new DatePair("09/01/2018","09/30/2018");
DatePair statsRange = new DatePair("09/01/2018","09/30/2018");
Logitem chosen;

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
    rv=fromISOtoUS("${value.year}-${value.month}-${value.day}");
  }
  return rv;
}

_LoggingPageState yakker;
String monthStart(DateTime monthAtHand)
{
  DateTime firstOfMonth = new DateTime(
      monthAtHand.year,
      monthAtHand.month,
      1
  );
  List<String> textual = firstOfMonth.toString().split(" ");
  return textual[0];
}

String monthEnd(DateTime monthAtHand)
{
  DateTime holder = new DateTime(
      monthAtHand.year,
      monthAtHand.month + 1,
      1
  );
  holder= holder.subtract(new Duration(days: 1));

  List<String> textual = holder.toString().split(" ");
  return textual[0];
}


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp() {
    var ahora = DateTime.now();
    var date1=fromISOtoUS(monthStart(ahora));
    var date2=fromISOtoUS(monthEnd(ahora));
    loggingRange.setDates(date1, date2);
    statsRange.setDates(date1, date2);
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
       '/item': (BuildContext context) => new ItemPage(),
     },

    );
  }
}



class ItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String content = "(new)";
    if(chosen !=  null)
      {
        content = chosen.title;
      }
      else
        {
          chosen = new Logitem(
              name:"Test shot 5",
              amt: 105.82,
              category: "Groceries",
              date:"2018-10-28"
          );
        }
    return new Scaffold (
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(content),
            actions: <Widget>[
        // action button
          FlatButton(
              child: Text("CANCEL",
                style:TextStyle(fontSize:Theme.of(context).textTheme.subtitle.fontSize,
                    color:Color(0xFFFFFFFF))
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          // action button
          FlatButton(
              child: Text("DONE",
                  style:TextStyle(fontSize:Theme.of(context).textTheme.subtitle.fontSize,
                      color:Color(0xFFFFFFFF))
              ),
              onPressed: () {
                Navigator.of(context).pop(chosen);
              },
            ),
          ]
          /*
          bottom: new TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
*/
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

  FloatingActionButton adder;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    adder = new FloatingActionButton(
      onPressed: newItem,
      tooltip: 'Add Item',
      child: new Icon(Icons.add),
    );
  //  _pageDates =[new DatePair("09/01/2018","09/30/2018"),new DatePair("09/01/2018","09/30/2018")];
   // _pages = <Widget>[new LoggingPage(owner:this),new DummyPage()];
    _tabController = new TabController(vsync:this,length: myTabs.length);
    _tabController.addListener((){
      if(_tabController.index == 1)
        {
          adder = null;
          setState((){

          });
        }
      else {
        adder = new FloatingActionButton(
          onPressed: newItem,
          tooltip: 'Add Item',
          child: new Icon(Icons.add),
        );

        setState((){

        });
      }
    });
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


  void newItem() async {
/*
    Navigator.of(context).push(new MaterialPageRoute(
      builder: new ChooseCredentialsPage().build,
      settings: new RouteSettings(name:"signup/choose_credentials")
    ));
    */
      chosen=null;
      Logitem feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder:ItemPage().build)
      );
      //("/item");
      if(feedback != null)
      {
        chosen = feedback;
        //this looks ridiculous to those used to declarative languages
        //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
        chosen.save().then((value) {
          yakker.fetchRows().then((goods) {
            setState(() {});
          });

        });
      }
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
      floatingActionButton: adder, // This trailing comma makes auto-formatting nicer for build methods.
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

//yyyy-mm-dd to mm/dd/yyyy
String fromISOtoUS(String inDate)
{
  List<String> datelets = inDate.split("-");

  while(datelets[1].length <2)
  {
    datelets[1]= "0" + datelets[1];
  }
  while(datelets[2].length <2)
  {
    datelets[2]= "0" + datelets[2];
  }

  return datelets[1]+"/"+datelets[2]+"/"+datelets[0];
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
  void setDates(String date1,String date2)
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
  List<Widget> gottenRows = [];
  bool fired = false;


  
  @override
  Widget build(BuildContext context) {
    if(!fired)
    { //this plus a race condition required ditching the custom initState()
      fired = true;
      fetchRows().then((goods) {
        setState(() {});
      });
    }
    yakker = this;
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

                loggingRange.setDate1(value);
                fetchRows().then((goods) {
                  setState(() {});
                }
                );
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
                  loggingRange.setDate2(value);
                  fetchRows().then((goods) {
                    setState(() {});
                  }
                  );
              });
            }
            ),
            Expanded(
               child: ListView(
                    children:gottenRows
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
      onPressed: (() async {
        chosen = content;
        bool feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder:ItemPage().build)
        );
        //("/item");
        if(feedback == true)
          {
            //this looks ridiculous to those used to declarative languages
            //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
            chosen.save().then((value) {
              fetchRows().then((goods) {
                setState(() {});
              });
            });
          }
      }),
    );

  }

  //I suspect that this should be a global function
  Future<List<Widget>>fetchRows() async {
    List<Widget> panelBody = [];
    if(Logitem.database == null)
      {
        await Logitem.createSampleData();
      }
    //get the Logitems matching this.range, ordered by date DESC
    List<Logitem> hits = await Logitem.getRange(
        loggingRange.isoFrom(), loggingRange.isoTo());


    String dateLabel = "";
    if (hits.length > 0) {
      dateLabel = hits[0].thedate;
      panelBody.add(dateMark("Date: $dateLabel"));
      panelBody.add(dataRow(hits[0]));
    }

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
    gottenRows = panelBody;
    return panelBody;
  }
}


class DummyPage extends StatefulWidget {
  DummyPage({Key key}):super(key:key);

  @override
  _DummyPageState createState() {
    return new _DummyPageState();
  }

}

class _DummyPageState extends State<DummyPage> {
  //can you smell the potential for reuse?


  List<Widget> gottenRows = [];
  bool fired = false;
  Future<bool> getTotals() async
  {
    bool rv = false;
    //just in case this page is ever drawn first
    if(Logitem.database == null)
    {
      await Logitem.createSampleData();
    }
    List<Widget> rows = [];
    List<Map<String,String>> stats = await Logitem.getTotals(statsRange.isoFrom(), statsRange.isoTo());
    for(int i=0;i<stats.length;i++)
    {
      rows.add(
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                    child:Text(stats[i].keys.first,style: Theme
                        .of(context)
                        .textTheme
                        .title)
                ),
              ),
              Expanded(
                flex: 2,
                child:Text(stats[i].values.first,style: Theme
                    .of(context)
                    .textTheme
                    .title,
                    textAlign: TextAlign.right
                ),
              ),
            ],

          )
      );
    }
    rv = true;
    gottenRows = rows;
    return rv;
  }


  @override
  Widget build(BuildContext context) {
    if(!fired)
    {
      fired = true;
      getTotals().then((goods) {
        setState(() {});
      });
    }
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
          children: <Widget>[

            new FlatButton(
                child:new Text(
                  'From: ${statsRange._date1}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1,
                ),
                onPressed:(){
                  Future<String> newdate = askDate(context,statsRange._date1);
                  newdate.then((value) {

                    statsRange.setDate1(value);
                    getTotals().then((goods) {
                      setState(() {});
                    }
                    );
                  });
                }
            ),
            new FlatButton(
                child:new Text(
                  'To: ${statsRange._date2}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1,
                ),
                onPressed:(){
                  Future<String> newdate = askDate(context,statsRange._date2);
                  newdate.then((value) {
                    statsRange.setDate2(value);
                    getTotals().then((goods) {
                      setState(() {});
                    }
                    );
                  });
                }
            ),
            Expanded(
                child: ListView(
                    children:gottenRows
                )
            ),

          ],
        )
    );
  }
}
