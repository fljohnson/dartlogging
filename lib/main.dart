//import 'dart:developer';
/*
Multiple problems on iOS:

3. There does not seem to be a general-purpose directory on a stock iOS file system, the expectation apparently being "iCloud, dude" for that OR storage space devoted to the application

"iOS apps should always save files to known locations inside their sandbox, and apps should use a custom interface when presenting those documents to the user" -> "ineffective on roadrunners"
*/
//import 'dart:async';
import 'dart:io' show Platform;

//import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:basketnerds/basepage.dart';
import 'package:basketnerds/logging.dart';
import 'package:basketnerds/planning.dart';
import 'package:basketnerds/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "logitem.dart";
import "pseudoresources.dart";



DatePair statsRange = new DatePair("09/01/2018","09/30/2018");






void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp() {
    var ahora = DateTime.now();
    var date1=fromISOtoUS(monthStart(ahora));
    var date2=fromISOtoUS(monthEnd(ahora));
    statsRange.setDates(date1, date2);
  }
  @override
  Widget build(BuildContext context) {

    smashDB();


    return new MaterialApp(
      title: 'The Money Logs',
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
       '/': (BuildContext context) => new MyHomePage(title: 'The Money Logs'),
 //      '/item': (BuildContext context) => new ItemPage(),
     },

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

  List<PageWidget> pages ;
  List<Tab> myTabs = <Tab>[
    new Tab(text: 'Logging'),
    new Tab(text: 'Stats'),
    new Tab(text: 'Planning'),
  ];

  //hey Cupertino
  List<BottomNavigationBarItem> myTabBarItems = <BottomNavigationBarItem> [
    new BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.folder_open),
        activeIcon: Icon(CupertinoIcons.folder_solid),
        title: Text("Logging")
      ),
    new BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.check_mark_circled),
        activeIcon: Icon(CupertinoIcons.check_mark_circled_solid),
        title: Text("Stats")
    )
  ];

  
  List<DatePair> _pageDates;

  FloatingActionButton adder;
  CupertinoButton cupertinoAdder;
  TabController _tabController;

  List<String> _popupItems;

  int cupertinoCurrentTab = 0;





  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync:this,length: myTabs.length);
    _tabController.addListener((){
      setState((){
        gigUI();
      });
    });
    /*
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
*/
    pages = [ LoggingPage(), DummyPage(tabster:_tabController), PlanningPage() ];

    gigUI();

  }


  void gigUI()
  {
    

    if(!Platform.isIOS) {
      if (!pages[_tabController.index].haveFAB()) {
        adder = null;
        cupertinoAdder = null;
      }
      else {
        adder = new FloatingActionButton(
          onPressed: newItem,
          tooltip: 'Add Item',
          child: new Icon(Icons.add),
        );
      }
      _popupItems = pages[_tabController.index].popupChoices();
    }
    else {
      if (!pages[cupertinoCurrentTab].haveFAB()) {
        adder = null;
        cupertinoAdder = null;
      }
      else {
        cupertinoAdder = CupertinoButton(
            onPressed: newItem,
            child: new Icon(CupertinoIcons.add)
        );
      }
      _popupItems = pages[cupertinoCurrentTab].popupChoices();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setDates(DatePair range) {
    setState(() {
      int whichPair=_tabController.index;
      _pageDates[whichPair].setDates(range.date1, range.date2);
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
      /*
      Logitem feedback;
      feedback = await pages[_tabController.index].fabClicked(context);
      */

      // (*bleep*)
      if(!Platform.isIOS) {
        pages[_tabController.index].fabClicked(context);
      }
      else
      {
        pages[this.cupertinoCurrentTab].fabClicked(context);
      }

  }


  @override
  Widget build(BuildContext context) {
    if (Logitem.database == null) {
      print("in main");

    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // u
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.


    //hey Cupertino
    if(Platform.isIOS)
      {
/*
        return new CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
                items:myTabBarItems
            ),
            tabBuilder: (BuildContext context, int index) {
              return CupertinoTabView(
                  builder: (BuildContext context) {
                    return theTabPage(context,index);
                  }
              );
            }

        );
*/
        
        return theTabPage(context,cupertinoCurrentTab);
      }
      else
      {
        var acciones;
        if(_popupItems.length == 0) {
          acciones = null;
        }
        else {
          acciones = [
            PopupMenuButton<String>(
              onSelected: ((String value) {
                _handlePopupMenu(value, context);
              })
              ,
              itemBuilder: (BuildContext context) {
                return _popupItems.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ];
        }
        return new Scaffold(
          appBar: new AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: new Text(widget.title),
            actions:acciones,

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
                children:pages
            ),

          ),
          floatingActionButton: adder, // This trailing comma makes auto-formatting nicer for build methods.
        );

      }

  }

  CupertinoSegmentedControl pageSelector(int index, {BuildContext bc}) {
    Map<int,Widget> botons = {
      0:Text("Logging"),
      1:Text("Stats"),
      2:Text("Planning")
    };
    return CupertinoSegmentedControl<int>(
      children:botons,
      groupValue:index,
      onValueChanged:((int value) {
        setState((){

          for(int i=0;i<pages.length;i++)
          {
            pages[value].notifyActive(i == value);
          }
			this.cupertinoCurrentTab = value;
			gigUI();
        });
      })
    );
  }

  CupertinoPageScaffold theTabPage(BuildContext context, int index) {
  return CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
          //middle:Text("Logging"),
          middle:pageSelector(index,bc:context),
          trailing:cupertinoAdder,
          backgroundColor:CupertinoColors.white
        )
          ,
        child:pages[index]
      );
  /*
    if(index == 0)
    {
      return CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
          //middle:Text("Logging"),
          middle:pageSelector(index),
          trailing:cupertinoAdder,
          backgroundColor:CupertinoColors.white
        )
          ,
        child:LoggingPage()
      );
    }
    else
    {
      return CupertinoPageScaffold(
          navigationBar: new CupertinoNavigationBar(
              //middle:Text("Stats"),//rework the look of that FAB
              middle:pageSelector(index),
              backgroundColor:CupertinoColors.white
          )
          ,
        child:DummyPage()
      );
    }
    */
  }
  

  void _handlePopupMenu(String value, BuildContext context) {
    int seleccion = this._popupItems.indexOf(value);
    if(!pages[_tabController.index].handlePopupChoice(seleccion,context))
      {
        doAlert(context,"Menu item ${seleccion+1} is missing");
      }
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




