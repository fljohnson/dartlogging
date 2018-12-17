import 'dart:async';
import 'dart:io';

import 'package:basketnerds/basepage.dart';
import 'package:basketnerds/logitem.dart';
import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

_LoggingPageState zeState;

Logitem chosen;


DatePair loggingRange = new DatePair("09/01/2018","09/30/2018");
class LoggingPage extends PageWidget {

  LoggingPage({Key key}) :
        super(key:key)
  {

    var ahora = DateTime.now();
    var date1=Datademunger.fromISOtoUS(monthStart(ahora));
    var date2=Datademunger.fromISOtoUS(monthEnd(ahora));
    loggingRange.setDates(date1, date2);
  }

  @override
  List<String> popupChoices() {
    return ["Import...","Export..."];
  }

  @override
  bool handlePopupChoice(int seleccion, BuildContext context){

    bool rv = true;
    switch(seleccion)
    {
      case 0:
        Future<String> result = Logitem.getFileToOpen();
        result.then((value) {
          if(value != null && value != "")
          {

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
          }
        });
        break;
      case 1 :
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
        rv = false;
      }
    }
    return rv;
  }

  @override
  fabClicked(BuildContext context) async {
    Logitem feedback;
    //left it to ItemPage to do differentiation
    feedback = await Navigator.of(context).push(
        MaterialPageRoute(builder: ItemPage(itemtype:Logitem.LITYPE_LOGGING).build)
    );

    //("/item");

    if(feedback != null)
    {
      chosen = feedback;
      //this looks ridiculous to those used to declarative languages
      //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
      chosen.save(entrytype:Logitem.LITYPE_LOGGING).then((value) {
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
        Future<String> result = Logitem.getFileToWrite(bc:context);
        result.then((value) async {
          if (value != null)
          {
            /*
          value contains the "path" portion of a localFileURL to be created
          doExport() will write to this file directly
          */
            //doAlert(context,"Target URL is $value");
            //await Logitem.doExport(value, loggingRange.isoFrom(), loggingRange.isoTo());
            if(Logitem.lastError != null  && Logitem.lastError != "")
            {
              doAlert(context,"result of getFileToWrite():${Logitem.lastError}.");
            }
            else
            {
              await Logitem.doExport(value, loggingRange.isoFrom(), loggingRange.isoTo());
              if(Logitem.lastError != null && Logitem.lastError != "")
                {
                  doAlert(context,"FAILED at doExport():${Logitem.lastError}.");
                }
              /*
			we now send that path to the native code, which will rebuild the localFileURL,
			and then try to run the Save to External "dialog". The crackpot theory is that now that the local file exists, creating the picker won't crash.
			*/

              /*
              Logitem.exportToExternal(loggingRange.isoFrom(),loggingRange.isoTo(),localUrl:value).then((String outbound){
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
              */


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
    //doAlert(context,"Got hits ${hits.length}");
    setState((){
      logged.clear();
      logged.addAll(hits);
      //print("Got hits ${hits.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    this.cupertinoToolbar = Row (
        children:[
          Spacer(
              flex:1
          ),

          Expanded(
            flex:2,
            child:CupertinoButton(
                child:Text("Import"),
                onPressed:((){
                  _handleCupertinoMenu(0,context);
                })
            ),
          ),
          Expanded(
              flex:2,
              child: CupertinoButton(
                  child:Text("Export"),
                  onPressed:((){
                    _handleCupertinoMenu(1,context);
                  })
              )
          ),
          Spacer(
              flex:1
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
                  loadLogs();
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
                  loadLogs();
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
        //moved differentiation to ItemPage
        feedback = await Navigator.of(context).push(
            MaterialPageRoute(builder:ItemPage().build)
        );

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



class ItemPage extends StatelessWidget {
  final String itemtype; //make a package symbol outta this, willya?

  ItemPage({Key key,this.itemtype = Logitem.LITYPE_LOGGING}):super(key:key);

  @override
  Widget build(BuildContext context) {
    String content = "(new)";
    if(chosen !=  null)
    {
      content = chosen.title;
    }

    if(!Platform.isIOS)
    {
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
    else
    {
      return CupertinoPageScaffold(
          navigationBar: new CupertinoNavigationBar(
              automaticallyImplyLeading: true,
              middle:new Text(content),
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
}
//will rebuild this bit later
class CupertinoItemPage extends StatelessWidget {
  final String itemtype = Logitem.LITYPE_LOGGING; //make a package symbol outta this, willya?

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
    return Container (
        height:50.0,width:50.0,color: Colors.amber);

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
    if(widget.itemtype == Logitem.LITYPE_PLANNING)
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
                        Datademunger.fromISOtoUS(chosen.thedate),
                        ((String value){
                          if(isISODate(value)) {
                            chosen.thedate = value;
                          }
                          else {
                            chosen.thedate = Datademunger.fromUStoISO(value);
                          }
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
                      Datademunger.fromISOtoUS(chosen.thedate),
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
