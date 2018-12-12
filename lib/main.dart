//import 'dart:developer';
/*
Multiple problems on iOS:

3. There does not seem to be a general-purpose directory on a stock iOS file system, the expectation apparently being "iCloud, dude" for that OR storage space devoted to the application

"iOS apps should always save files to known locations inside their sandbox, and apps should use a custom interface when presenting those documents to the user" -> "ineffective on roadrunners"
*/
import 'dart:async';
import 'dart:io' show Platform;

//import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:basketnerds/basepage.dart';
import 'package:basketnerds/planning.dart';
import 'package:basketnerds/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "logitem.dart";
import "pseudoresources.dart";


DatePair loggingRange = new DatePair("09/01/2018","09/30/2018");
DatePair statsRange = new DatePair("09/01/2018","09/30/2018");
Logitem chosen;

List<VoidCallback> finishedDB = [];

void smashDB(BuildContext context) async {
  await Logitem.createSampleData();
  for(int i=0;i<finishedDB.length;i++)
    {
      finishedDB[i]();
    }
  /*
  Future<void> result = Logitem.createSampleData();
  result.then((void value){},onError: (e){
    doAlert(context,e.toString());
  });
  */
}

void onDBReady(VoidCallback whatThen) {
  if (Logitem.database == null) {
    finishedDB.add(whatThen);
  }
  else {
    whatThen();
  }
}

_LoggingPageState zeState;
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

    smashDB(context);


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
       '/item': (BuildContext context) => new ItemPage(),
     },

    );
  }
}



class ItemPage extends StatelessWidget {
  final String itemtype; //make a package symbol outta this, willya?

  ItemPage({Key key,this.itemtype = "logging"}):super(key:key);

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
            leading:IconButton(
              icon:Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                }
            ),
            actions: <Widget>[
        // action button
        /*
          FlatButton(
              child: Text("CANCEL",
                style:TextStyle(fontSize:Theme.of(context).textTheme.button.fontSize,
                    color:Color(0xFFFFFFFF))
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          */
          // action button
          FlatButton(
              child: Text("SAVE",
                  style:TextStyle(fontSize:Theme.of(context).textTheme.button.fontSize,
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
          child: RealItemPage(itemtype)
        )
    );
  }
}
//will rebuild this bit later
class CupertinoItemPage extends StatelessWidget {
  final String itemtype = "logging"; //make a package symbol outta this, willya?

  //CupertinoItemPage({key:Key,this.itemtype}):super(key:key);
  @override
  Widget build(BuildContext context) {
    /*
    String content;

    if (chosen != null) {
      content = chosen.title;
    }
    else
    {
      content  = "(new)";
    }
    */

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
        child: RealItemPage(itemtype)
    );
  }
}
/*

 */
class RealItemPage extends StatefulWidget {
  final String itemtype;
  RealItemPage(this.itemtype,{Key key}): super(key:key);
  @override
  _RealItemPageState createState() => new _RealItemPageState();
}

class _RealItemPageState extends State<RealItemPage> with PageState {

  TextEditingController _controllerAmount;
  TextEditingController _controllerTitle;
  TextEditingController _controllerDetails;
  GlobalKey _keyAmt = new GlobalKey(debugLabel:"amt");
  GlobalKey _keyTitle = new GlobalKey(debugLabel:"title");
  GlobalKey _keyDetails = new GlobalKey(debugLabel:"details");

  List<String> categoryName = [];
  List<String> categoryNote = [];


  @override
  initState()
  {

    super.initState();
    for(int i=0;i<categories.length;i++) {
      categoryName.add(categories[i].keys.first);
      categoryNote.add(categories[i].values.first);
    }

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
          name:"",
          amt: 0,
          category: "",
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

  Widget explainCategory(String sel)
  {
    String explainer = categoryNote[categoryName.indexOf(sel)];
    if(explainer == null)
    {
      explainer = "";
    }
    return Text(explainer,
        textAlign: TextAlign.start,
        style: Theme
            .of(context)
            .textTheme
            .caption
    );
  }


  Widget menumakerAndroid(String currentsel)
  {

    List<DropdownMenuItem<String>> droplist = [];

    if(currentsel == null || currentsel.length == 0)
    {
      currentsel = categoryName[0];
      chosen.category = currentsel;
    }

    for(int i=0;i<categories.length;i++)
    {
      droplist.add(
          DropdownMenuItem<String>(
            value: categoryName[i],
            child: Text(categoryName[i],
                textAlign: TextAlign.start,
                style: Theme
                    .of(context)
                    .textTheme
                    .title
            )
          )
      );
    }

    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        DropdownButton<String>(
          items: droplist,
          value: currentsel,
   //puts down-arrow at end of enclosing space
          onChanged: (String value){
            chosen.category = value;

            setState((){});
          },
        )
        ,
        explainCategory(currentsel)
      ]
    );
    //return ;

  }

  Widget menumakerCupertino(BuildContext context,String currentsel)
  {
  if(currentsel == null || currentsel.length == 0)
  {
    currentsel = categoryName[0];
    chosen.category = currentsel;
  }
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
		String aha = categoryName[i];
      List<Widget> interieur =[
        CupertinoButton(
            onPressed:(categoryName[i] == currentsel)?null:((){
        //not quite right
        Navigator.of(context).pop(aha);
      }) ,
            child: Text(aha)

        )
      ];
      if(categoryNote[i] != null)
      {
        interieur.add(
            Text(categoryNote[i])
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


    return Container(
      margin:EdgeInsets.symmetric(vertical:4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              flex:6,
              child:Padding(
                  padding:EdgeInsets.only(top:9.0),
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline,

                  )

              )

          )
          ,
          Spacer(
            flex: 1,
          ),

          Expanded(
              flex:10,
              child:Material(
                  child:Container(
                      decoration: BoxDecoration(color:Colors.black12),
                      child:TextField(
                        controller:controller,
                        keyboardType: kbdType,
                        maxLines: maxLines,
                        textAlign:align,
                        style: editStyle,
                        onChanged: changeHandler,
                      )
                  )

              )
          )


        ],
      )
    )


    ;
  }

  @override
  Widget build(BuildContext context)
  {
    String itemNamePrompt = "What it was";
    if(widget.itemtype == "planning")
    {
      itemNamePrompt = "What it will be";
    }

//went from Column to ListView for all platforms
    return ListView (
      children: <Widget>[
        Row(
            children:[
              Expanded(
                  flex: 1,
                  child:getDateButton(
                    context,
                    "Date: ",
                    fromISOtoUS(chosen.thedate),
                      ((String value){
                        chosen.thedate=fromUStoISO(value);
                        setState(() {});
                      })
                  )
                  /*
                  CupertinoButton(
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
                  */
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
            hint:itemNamePrompt,
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
              //var auldSel = _controllerAmount.selection;
              num goodNumber = Logitem.toNumber(newValue.replaceAll("\$", ""));
              //_controllerAmount.text = Logitem.toDollarString(goodNumber);
              chosen.amount = goodNumber;
              //_controllerAmount.selection = auldSel;
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
        Container(
          margin:EdgeInsets.symmetric(vertical:4.5),
          child: Row(
              children:[
              /*
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
                        */
              Expanded(
              flex:6,
              child:Text(
              "Category",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline
              )

              )
              ,
              Spacer(
              flex: 1,
              ),


              Platform.isIOS ? menumakerCupertino(context,chosen.category) :
              Expanded(flex:12,child:menumakerAndroid(chosen.category))
              /*
                        Expanded(
                          flex:3,
                          child:
                        )*/

              ]
          )
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

      pages[_tabController.index].fabClicked(context);

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
                children:pages
            ),

          ),
          floatingActionButton: adder, // This trailing comma makes auto-formatting nicer for build methods.
        );

      }

  }

  CupertinoSegmentedControl pageSelector(int index) {
    Map<int,Widget> botons = {
      0:Text("Logging"),
      1:Text("Stats"),
      2:Text("Planning")
    };
    return CupertinoSegmentedControl<int>(
      children:botons,
      groupValue:index,
      onValueChanged:((int value) {
        this.cupertinoCurrentTab = value;
        setState((){});
      })
    );
  }

  CupertinoPageScaffold theTabPage(BuildContext context, int index) {
  return CupertinoPageScaffold(
        navigationBar: new CupertinoNavigationBar(
          //middle:Text("Logging"),
          middle:pageSelector(index),
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
    switch(seleccion)
    {
      case 0:
        Future<String> result = Logitem.getFileToOpen();
        result.then((value) {
          Future<int> importResult = Logitem.doImport(value);
          importResult.then((int value) {
            if(value == -1)
            {
              doAlert(context,"${Logitem.lastError}\n\nAny preceding rows got in without trouble.");
            }
            //should do in any event
            if(zeState != null)
            {
              zeState.refresh();
            }

          });

        });
        break;
      case 1 : //Logitem.doExport(loggingRange.isoFrom(),loggingRange.isoTo());
        Future<String> result = Logitem.getFileToWrite();
      result.then((value) {
        if (value != null)
          {
          Logitem.doExport(value, loggingRange.isoFrom(), loggingRange.isoTo());
        }
        else
          {
            if(Logitem.lastError != null) {
              doAlert(context, "Failure on export:${Logitem.lastError}");
            }
          }
      });
      break;
      default:
        {
          doAlert(context,"Menu item ${seleccion+1} is missing");
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



class LoggingPage extends PageWidget {

  LoggingPage({Key key}) :
    super(key:key);


  @override
  fabClicked(BuildContext context) async {
    Logitem feedback;
    if(!Platform.isIOS) {
      feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder: ItemPage(itemtype:"logging").build)
      );
    }
    else {
      //TODO: sort out the iOS stuff per above
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
      chosen.save(entrytype:"logging").then((value) {
        if(zeState != null)
          {
            zeState.refresh();
          }
          /*
        zeState.fetchRows().then((goods) {
          zeState.refresh(); //roundabout way of doing setState()

        });
*/
      });
    }
  }

  @override
  _LoggingPageState createState() {
    return new _LoggingPageState();
  }

}

class _LoggingPageState extends State<LoggingPage> with PageState{
  List<Logitem> logged ;
  List<Widget> gottenRows = [];
  bool fired = false;

  Widget cupertinoToolbar;

void _handleCupertinoMenu(int seleccion, BuildContext context) {
    //int seleccion = this._popupItems.indexOf(value);
    switch(seleccion)
    {
      case 0:
        Future<String> result = Logitem.getFileToOpen();
        result.then((value) {
        //doAlert(context,"Will read in $value");
          Future<int> importResult = Logitem.doIOSImport(value);
          importResult.then((int value) {
            if(value != 1)
            {
              doAlert(context,"${Logitem.lastError}\n\nAny preceding rows got in without trouble.");
            }
            //should do in any event
            if(zeState != null)
            {
              zeState.refresh();
            }

          });

        });
        break;
      case 1 : //Logitem.doExport(loggingRange.isoFrom(),loggingRange.isoTo());
        Future<String> result = Logitem.getFileToWrite();
      result.then((value) async {
        if (value != null)
          {
          /*
          value contains the "path" portion of a localFileURL to be created
          doExport() will write to this file directly
          */
			  doAlert(context,"Target URL is $value");
          //await Logitem.doExport(value, loggingRange.isoFrom(), loggingRange.isoTo());
          if(Logitem.lastError != null)
          {
			  doAlert(context,"result of doExport():${Logitem.lastError}");
		  }
		  else
		  {
			/*
			we now send that path to the native code, which will rebuild the localFileURL, 
			and then try to run the Save to External "dialog". The crackpot theory is that now that the local file exists, creating the picker won't crash.
			*/
			
			Logitem.exportToExternal(localUrl:value).then((String outbound){
				if(outbound != null)
				{
					doAlert(context,"winning at exportToExternal():$outbound");
				}
				else
				{
					if(Logitem.lastError != null)
					  {
						  doAlert(context,"no-go on exportToExternal():${Logitem.lastError}");
					  }
				}
			},onError: (e){
        doAlert(context,e.toString());
      });
      
			
		  }
        }
      });
      break;
      default:
        {
          doAlert(context,"Menu item ${seleccion+1} is missing");
        }
    }
  }

  @override
  initState()
  {
    super.initState();
    zeState = this;
    primeLogs();
    onDBReady(loadLogs);
    /*
    if(!fired)
    { //this plus a race condition required ditching the custom initState()
      fired = true;
      finishedDB.add((){
        fetchRows().then((goods) {
          setState(() {});
        });
      });

    }
    else {
      print("HALLO");
      fetchRows().then((goods) {
        setState(() {});
      });
    }*/
  }

  primeLogs()
  {
    logged = [];
  }
  loadLogs() async {
    var hits = await Logitem.getRange(loggingRange.isoFrom(), loggingRange.isoTo());
    setState((){
      logged.clear();
      logged.addAll(hits);
      print("Got hits ${hits.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    this.cupertinoToolbar = Row (
        children:[
          new CupertinoButton(
              child:Text("Import..."),
              onPressed:((){
                _handleCupertinoMenu(0,context);
              })
          ),
          new CupertinoButton(
              child:Text("Export..."),
              onPressed:((){
                _handleCupertinoMenu(1,context);
              })
          )
        ]
    );

    List<Widget> columnContents = <Widget>[
      Row(
          children:[
            Expanded(
                flex: 1,
                child: getDateButton(context,"From: ",loggingRange.date1,((String value)
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
                  loggingRange.date1,
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
                child: getDateButton(context,"To: ",loggingRange.date2,((String value)
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
                  loggingRange.date2,
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
              children:createRows()
          )
      ),

    ];

    if(Platform.isIOS){
      columnContents.add(cupertinoToolbar);
    }
    return new Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: columnContents,
    );
  }
  Widget build2(BuildContext context) {
	this.cupertinoToolbar = Row (
			children:[
          new CupertinoButton(
          child:Text("Import..."),
          onPressed:((){
            _handleCupertinoMenu(0,context);
          })
          ),
          new CupertinoButton(
            child:Text("Export..."),
            onPressed:((){
            _handleCupertinoMenu(1,context);
            })
          )
        ]
       );
        

    zeState = this;

    List<Widget> columnContents = <Widget>[
      Row(
          children:[
            Expanded(
                flex: 1,
                child: getDateButton(context,"From: ",loggingRange.date1,((String value)
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
                  loggingRange.date1,
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
                child: getDateButton(context,"To: ",loggingRange.date2,((String value)
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
                  loggingRange.date2,
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

    ];

    if(Platform.isIOS){
      columnContents.add(cupertinoToolbar);
    }
    return new Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: columnContents,
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
    return GestureDetector(
      child:Container(
        margin: EdgeInsets.symmetric(vertical:4.0),
        child:new Row(
          children:[
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.only(right:5.0),
                  child:Text(content.title,
                      style:mainTextStyle,
                      /*
                      style: Theme
                      .of(context)
                      .primaryTextTheme
                      .title*/
                  )
              ),
            ),



            Expanded(
              flex: 4,
              child: Container(
                  //margin: EdgeInsets.only(left:5.0),
                  child:Text(content.category,
                      style: mainTextStyle,
                      /*
                      style: Theme
                      .of(context)
                      .textTheme
                      .subtitle
                      */
                  )
              ),
            ),
            Expanded(
              flex: 3,
            child:Text(content.stramount(),
                style:mainTextStyle
                ,
                /*
                style: Theme
                        .of(context)
                        .textTheme
                        .subtitle,
                      */
                      textAlign: TextAlign.right
                          ),
            ),
          ]
      )
      )
        ,
      onTapUp: ((details) async {
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

    String friendlyDate;

    List<Logitem> hits = [];
    //get the Logitems matching this.range, ordered by date DESC
    if(Logitem.database != null)
      {

        hits = await Logitem.getRange(
            loggingRange.isoFrom(), loggingRange.isoTo());


      }
    String dateLabel = "";
    if (hits.length > 0) {
      dateLabel = hits[0].thedate;
      friendlyDate = Datademunger.fromISOtoUS(dateLabel);
      panelBody.add(dateMark("Date: $friendlyDate"));
      panelBody.add(dataRow(hits[0]));
    }

    for(int i=1;i<hits.length;i++)
    {

      if(hits[i].thedate != dateLabel)
        {
          //flush it
          dateLabel = hits[i].thedate;
          friendlyDate = Datademunger.fromISOtoUS(dateLabel);

          panelBody.add(dateMark("Date: $friendlyDate"));
        }
      panelBody.add(dataRow(hits[i]));
    }
    gottenRows = panelBody;
    return panelBody;
  }

  void refresh() {
    loadLogs();
    /*
    fetchRows().then((goods) {
      setState(() {});
    });
    */
  }

  List<Widget> createRows() {
    List<Widget> panelBody = [];

    String friendlyDate;
    String dateLabel = "";
    if (logged.length > 0) {
      dateLabel = logged[0].thedate;
      friendlyDate = Datademunger.fromISOtoUS(dateLabel);
      panelBody.add(dateMark("Date: $friendlyDate"));
      panelBody.add(dataRow(logged[0]));
    }

    for(int i=1;i<logged.length;i++)
    {

      if(logged[i].thedate != dateLabel)
      {
        //flush it
        dateLabel = logged[i].thedate;
        friendlyDate = Datademunger.fromISOtoUS(dateLabel);

        panelBody.add(dateMark("Date: $friendlyDate"));
      }
      panelBody.add(dataRow(logged[i]));
    }
    return panelBody;
  }
}



