import 'dart:developer';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "logitem.dart";
import "pseudoresources.dart";


DatePair loggingRange = new DatePair("09/01/2018","09/30/2018");
DatePair statsRange = new DatePair("09/01/2018","09/30/2018");
Logitem chosen;

/*
void _setDate() {
//  Navigator.of(context).pop();

   var datemess = (dobKey.currentState.dobStrMonth +
      ' ${dobKey.currentState.dobDate}' +
      ' ${dobKey.currentState.dobYear}');

}
*/

void askCupertinoDate(BuildContext context,String originalDate, void actOnDate(String value) )
{
  String rv = originalDate;
  List<String> datelets = originalDate.split("/");
  DateTime currentDate = new DateTime(int.parse(datelets[2]),int.parse(datelets[0]), int.parse(datelets[1]));
  DateTime minDate = new DateTime(currentDate.year,currentDate.month-2,1);
  DateTime maxDate = new DateTime(currentDate.year,currentDate.month+2,-1);



  DatePicker.showDatePicker(
      context,
      dateFormat:"mmm-dd-yyyy",
      minYear:minDate.year,
      maxYear:maxDate.year,
      initialYear:currentDate.year,
      initialMonth: currentDate.month,
      initialDate: currentDate.day,
      locale:'en_US',
      showTitleActions:true,
      onConfirm:((int year, int month, int date){
        rv=fromISOtoUS("$year-$month-$date");
        actOnDate(rv);
      })
  );
}

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

    return new Scaffold (
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(content),
            actions: <Widget>[
        // action button
          FlatButton(
              child: Text("CANCEL",
                style:TextStyle(fontSize:Theme.of(context).textTheme.headline.fontSize,
                    color:Color(0xFFFFFFFF))
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          // action button
          FlatButton(
              child: Text("DONE",
                  style:TextStyle(fontSize:Theme.of(context).textTheme.headline.fontSize,
                      color:Color(0xFFFFFFFF))
              ),
              onPressed: () {
                Navigator.of(context).pop(chosen);
              },
            ),
          ]

        ),
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: RealItemPage()
        )
    );
  }
}

class CupertinoItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String content = "(new)";
    if (chosen != null) {
      content = chosen.title;
    }


    return CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
            automaticallyImplyLeading: true,
            trailing: CupertinoButton(
              child:Text("Done"),
              onPressed: (){
                Navigator.of(context).pop(chosen);
            }
            ),
            backgroundColor: CupertinoColors.white
        )
        ,
        child: RealItemPage()
    );
  }
}
/*

 */
class RealItemPage extends StatefulWidget {
  @override
  _RealItemPageState createState() => new _RealItemPageState();
}

class _RealItemPageState extends State<RealItemPage> {

  TextEditingController _controllerAmount;
  TextEditingController _controllerTitle;
  TextEditingController _controllerDetails;
  GlobalKey _keyAmt = new GlobalKey(debugLabel:"amt");
  GlobalKey _keyTitle = new GlobalKey(debugLabel:"title");
  GlobalKey _keyDetails = new GlobalKey(debugLabel:"details");

  @override
  initState()
  {
    if(chosen == null)
    {
      var ahora = DateTime.now();
      String mo = "${ahora.month}";
      String da = "${ahora.day}";
      while (da.length < 2)
      {
        da = "0" +da;
      }
      while (mo.length < 2)
      {
        mo = "0" +mo;
      }


      chosen = new Logitem(
          name:"Test shot 5",
          amt: 1.82,
          category: "Groceries",
          date:"${ahora.year}-$mo-$da"
      );
    }
    _controllerAmount = TextEditingController(text:chosen.stramount());
    _controllerTitle = TextEditingController(text:chosen.title);
    if(chosen.details == null ||chosen.details.isEmpty)
    {
      _controllerDetails = TextEditingController();
    }
    else
    {
      _controllerDetails = TextEditingController(text:chosen.details);
    }
    super.initState();
  }
  @override
  dispose()
  {
    if(_controllerAmount != null)
    {
      _controllerAmount.dispose();
    }
    if(_controllerTitle != null)
    {
      _controllerTitle.dispose();
    }
    if(_controllerDetails != null)
    {
      _controllerDetails.dispose();
    }

    super.dispose();
  }

  Widget menumakerAndroid(String currentsel)
  {
    List<String> categoryName = [];
    List<String> categoryNote = [];
    List<DropdownMenuItem<String>> droplist = [];

    for(int i=0;i<categories.length;i++)
    {
      categoryName.add(categories[i].keys.first);
      categoryNote.add(categories[i].values.first);
      droplist.add(
          DropdownMenuItem<String>(
            value: categoryName[i],
            child: Text(categoryName[i],
              textAlign: TextAlign.end,
              style: Theme
                  .of(context)
                  .textTheme
                  .title
            ),
          )
      );
    }
    return DropdownButton<String>(
      items: droplist,
      value: currentsel,
      onChanged: (String value){
        chosen.category = value;
        setState((){});
      },
    );
  }

  Widget menumakerCupertino(BuildContext context,String currentsel)
  {
    List<Widget> visualCategories = [
      /*
      CupertinoButton(
          onPressed:((){
            //not quite right
            Navigator.of(context).pop();
          }) ,
          child: Text("Cancel")

      )*/
    ];
    for(int i=0; i<categories.length;i++)
    {
      List<Widget> interieur =[
        CupertinoButton(
            onPressed:(categories[i].keys.first == currentsel)?null:((){
        //not quite right
        Navigator.of(context).pop(categories[i].keys.first);
      }) ,
            child: Text(categories[i].keys.first)

        )
      ];
      if(categories[i].values.first != null)
      {
        interieur.add(
            Text(categories[i].values.first)
        );
      }
      visualCategories.add(
          Column(
              children:interieur
          )

      );
    }
    return CupertinoButton(
      child: Text(currentsel),
      onPressed:((){
        //run that bottom sheet thing, containing a CupertinoPicker
        Future<String> newvalue = showModalBottomSheet<String>(
          context:context,
          builder:((context){
            return Column(
              children: [
                CupertinoButton(
                  onPressed:((){
                    Navigator.of(context).pop();
                  }),
                  child:Text("Cancel")

                )
                ,
                Expanded(
                  child: ListView(
                      shrinkWrap: true,
                      children:visualCategories
                  ),
                )

                /*
                */
              ]
            );

          /*
            return ListView(
              children:visualCategories
            );
        */
  })
        );
        newvalue.then((String value)
        {
          if(value != null)
          {
            chosen.category = value;
            setState((){});
          }
        });

      })
      /*
      onChanged: (String value){
        chosen.category = value;
        setState((){});
      },
      */
    );
  }


  Widget saneTextField({GlobalKey key,String inText, TextEditingController controller, String hint, String type,int maxLines = 2,
    void Function(String newValue) changeHandler } ) {

    TextInputType kbdType = TextInputType.text;
    TextAlign align = TextAlign.start;
    TextStyle editStyle = Theme
        .of(context)
        .textTheme
        .title;
    if(type == "longedit")
      {
        editStyle =Theme
            .of(context)
            .textTheme
            .headline;
      }
    if(type == "currency")
    {
      maxLines = 1;
      kbdType = TextInputType.numberWithOptions(signed: false,decimal:true);
      //align = TextAlign.end;
    }


    return Row(

      children: <Widget>[
        Expanded(
          flex:3,
          child:Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline
          )

        )
        ,
        Spacer(
          flex: 1,
        ),

        Expanded(
          flex:4,
          child:Material(
              child:
              TextField(
                controller:controller,
                keyboardType: kbdType,
                maxLines: maxLines,
                textAlign:align,
                style: editStyle,
                onChanged: changeHandler,
              )
          )
        )
,

/*
        TextFormField(
          key: key,
       //   initialValue:inText,
          keyboardType: kbdType,
          maxLines: maxLines,
          textAlign:align,
          style: editStyle,
          controller: controller,
        )
        */

      ],
    )
    ;
  }
  @override
  Widget build(BuildContext context)
  {




//went from Column to ListView for all platforms
    return ListView (
      children: <Widget>[
        Row(
            children:[
              Expanded(
                  flex: 1,
                  child: CupertinoButton(
                      onPressed:(){
                        askCupertinoDate(context,fromISOtoUS(chosen.thedate),((String value)
                        {
                          chosen.thedate=fromUStoISO(value);
                          setState(() {});
                        })
                        );

                        /*
                        Future<String> newdate = askDate(context,fromISOtoUS(chosen.thedate));
                        newdate.then((value){
                          chosen.thedate=fromUStoISO(value);
                          setState(() {});
                        }
                        );
                        */
                      },
                      child: Text("Date: ")
                  )
              )
              ,
              Expanded(
                  flex: 3,
                  child: new Text(
                    fromISOtoUS(chosen.thedate),
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  )
              )
            ]
        )
        ,
        /*
        Container(
        height:90.0,
          child:
        )*/
        saneTextField(
            controller:_controllerTitle,
            key:_keyTitle,
            inText:chosen.title,
            hint:"What it was",
            changeHandler:(String newValue) {
              chosen.title = newValue;
            }
        ),
        saneTextField(
            controller:_controllerAmount,
            key:_keyAmt,
            inText:chosen.stramount(),
            hint:"How much",
            type:"currency",
            changeHandler:(String newValue) {
              var auldSel = _controllerAmount.selection;
              num goodNumber = Logitem.toNumber(newValue.replaceAll("\$", ""));
              _controllerAmount.text = Logitem.toDollarString(goodNumber);
              chosen.amount = goodNumber;
              _controllerAmount.selection = auldSel;
            }
        )
        /*
        Row(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              Expanded(
                  flex:2,
                  child:saneTextField(
                      controller:_controllerTitle,
                      key:_keyTitle,
                      inText:chosen.title,
                      hint:"What it was",
                      changeHandler:(String newValue) {
                        chosen.title = newValue;
                      }
                  )
              ),
              Expanded(
                  flex:1,
                  child:saneTextField(
                      controller:_controllerAmount,
                      key:_keyAmt,
                      inText:chosen.stramount(),
                      hint:"How much",
                      type:"currency",
                      changeHandler:(String newValue) {
                        var auldSel = _controllerAmount.selection;
                        num goodNumber = Logitem.toNumber(newValue.replaceAll("\$", ""));
                        _controllerAmount.text = Logitem.toDollarString(goodNumber);
                        chosen.amount = goodNumber;
                        _controllerAmount.selection = auldSel;
                      }
                  )
              ),

            ]
        )
        */
        ,
        Row(
          children:[
            Expanded(
              flex:2,
              child:new Text(
                "Category:",
                textAlign: TextAlign.start,
                style: Theme
                    .of(context)
                    .textTheme
                    .title
              )
            ),

              Platform.isIOS ? menumakerCupertino(context,chosen.category) :
              menumakerAndroid(chosen.category)
            /*
            Expanded(
              flex:3,
              child:
            )*/

          ]
        ),

        saneTextField(
            controller:_controllerDetails,
          key:_keyDetails,
          inText:chosen.details,
            hint:"Details",
            type:"longedit",
            changeHandler:(String newValue) {
              chosen.details = newValue;
            }
        )

      ]
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

  @override
  void initState() {
    super.initState();

    _popupItems = ["Import...","Export..."];
    adder = new FloatingActionButton(
      onPressed: newItem,
      tooltip: 'Add Item',
      child: new Icon(Icons.add),
    );

    cupertinoAdder = CupertinoButton(
      onPressed: newItem,
      child: new Icon(CupertinoIcons.add)
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
      Logitem feedback;
      if(!Platform.isIOS) {
        feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder:ItemPage().build)
      );
      }
      else {
        feedback = await Navigator.of(context).push(
            MaterialPageRoute(builder: CupertinoItemPage().build)
        );
      }
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

    //hey Cupertino
    if(Platform.isIOS)
      {

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
      }
      else
      {
        return new Scaffold(
          appBar: new AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: new Text(widget.title),
            actions:[
              PopupMenuButton<String>(
                onSelected: ((String value) {
                  _handlePopupMenu(value,context);
                })
                ,
                itemBuilder: (BuildContext context) {
                  return _popupItems.map((String choice){
                    return PopupMenuItem<String>(
                      value:choice,
                      child:Text(choice),
                    );
                  }).toList();
                },
              )
            ],

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

  CupertinoPageScaffold theTabPage(BuildContext context, int index) {
    if(index == 0)
    {
      return CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
          middle:Text("Logging"),
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
              middle:Text("Stats"),//rework the look of that FAB
              backgroundColor:CupertinoColors.white
          )
          ,
        child:DummyPage()
      );
    }
  }
  

  Future<String> exportProcedure(BuildContext context) async {
    String prospective = "";
    /*
    var dasaver = FlatButton(
        child:Text("Save"),
        onPressed: prospective.isEmpty ? null : ((){
          Navigator.of(context).pop(prospective.trim());
        })
    );
*/
    String tailname = await showDialog<String>(
      context:context,
      builder:((BuildContext context) {
        return AlertDialog(
          title: Text("Save entries to your Documents folder"),
          content:SingleChildScrollView(
            child: Column(
                children:[
                  Text("Entries from ${loggingRange._date1} to ${loggingRange._date2}",
                    textAlign: TextAlign.start,
                  ),
                  TextField(
                    maxLines: 1,
                    decoration: new InputDecoration(hintText: "File Name.csv"),
                    onChanged: ((String value){
                      prospective = value;
                      setState((){

                      });
                    }),

                  ),

                ]
            ),
          ),


          actions:[
            FlatButton(
                child:Text("Cancel"),
                onPressed:((){
                  Navigator.of(context).pop("");
                })
            ),
            FlatButton(
                child:Text("Save"),
                onPressed: prospective.isEmpty ? null : ((){
                  Navigator.of(context).pop(prospective.trim());
                })
            )

          ]
      );
    }

    )
    );
    if(tailname == null || tailname.isEmpty)
    {
      return null;
    }
    if(!tailname.endsWith(".csv"))
    {
      //too simplistic, but it gets the job done
      tailname += ".csv";
    }
    return tailname;
  }

  void _handlePopupMenu(String value, BuildContext context) {
    int seleccion = this._popupItems.indexOf(value);
    switch(seleccion)
    {
      case 1 : //Logitem.doExport(loggingRange.isoFrom(),loggingRange.isoTo());
      Future<String> result = exportProcedure(context);
      result.then((value) {
        if (value != null)
          {
          Logitem.doExport(value, loggingRange.isoFrom(), loggingRange.isoTo());
        }
      });
      break;
      default:
        {
          var ls="doh";
        }
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

  Widget _getDateButton(String label,String initialDate,actOnDate(String value)) {

    if(Platform.isIOS)
    {
      return CupertinoButton(
          onPressed:(){
            askCupertinoDate(context,initialDate,actOnDate);

          },
          child: Text(label)
      );
    }
    else
    {
      return RaisedButton(
        child: Text(label),
        onPressed:() {
          Future<String> newdate = askDate(context,initialDate);
          newdate.then((value)
          {
            actOnDate(value);
          });
        }
            /*
            (value) {
            loggingRange.setDate1(value);
            fetchRows().then((goods) {
              setState(() {});
            }
            );
          }
             */
      );
    }
  }


  
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
        Row(
            children:[
              Expanded(
                  flex: 1,
                  child: _getDateButton("From: ",loggingRange._date1,((String value)
                  {
                    loggingRange.setDate1(value);
                    fetchRows().then((goods) {
                      setState(() {});
                    }
                    );
                  })
                  )
              )
              ,
              Expanded(
                  flex: 3,
                  child: new Text(
                    loggingRange._date1,
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  )
              )
            ]
        ),

        Row(
            children:[
              Expanded(
                  flex: 1,
                  child: _getDateButton("To: ",loggingRange._date2,((String value)
                  {
                    loggingRange.setDate2(value);
                    fetchRows().then((goods) {
                      setState(() {});
                    });
                  })
                  )
              )
              ,
              Expanded(
                  flex: 3,
                  child: new Text(
                    loggingRange._date2,
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  )
              )
            ]
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
        Logitem feedback;
        if(!Platform.isIOS)
        {
          feedback = await Navigator.of(context).push(
              MaterialPageRoute(builder:ItemPage().build)
          );

        }
        else
        {
          feedback = await Navigator.of(context).push(
              MaterialPageRoute(builder:CupertinoItemPage().build)
          );
        }

        //("/item");
        if(feedback != null)
          {
            //this looks ridiculous to those used to declarative languages
            //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
            chosen.save().then((value) {
              fetchRows().then((goods) {
                setState(() {});
              });
            });
          }
        else
        {
          chosen.revert().then((value) {
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

  Widget _getDateButton(String label,String initialDate,actOnDate(String value)) {

    if(Platform.isIOS)
    {
      return CupertinoButton(
          onPressed:(){
            askCupertinoDate(context,initialDate,actOnDate);

          },
          child: Text(label)
      );
    }
    else
    {
      return RaisedButton(
          child: Text(label),
          onPressed:() {
            Future<String> newdate = askDate(context,initialDate);
            newdate.then((value)
            {
              actOnDate(value);
            });
          }
        /*
            (value) {
            loggingRange.setDate1(value);
            fetchRows().then((goods) {
              setState(() {});
            }
            );
          }
             */
      );
    }
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
            Row(
                children:[
                  Expanded(
                      flex: 1,
                      child: _getDateButton("From: ",statsRange._date1,((String value)
                      {
                        statsRange.setDate1(value);
                        getTotals().then((goods) {
                          setState(() {});
                        }
                        );
                      })),


                  )
                  ,
                  Expanded(
                      flex: 3,
                      child: new Text(
                        statsRange._date1,
                        textAlign: TextAlign.center,
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1,
                      )
                  )
                ]
            ),

            Row(
                children:[
                  Expanded(
                      flex: 1,
                      child: _getDateButton("To: ",statsRange._date2,((String value)
                      {
                        statsRange.setDate2(value);
                        getTotals().then((goods) {
                          setState(() {});
                        }
                        );
                      })),

                  )
                  ,
                  Expanded(
                      flex: 3,
                      child: new Text(
                        statsRange._date2,
                        textAlign: TextAlign.center,
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1,
                      )
                  )
                ]
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
