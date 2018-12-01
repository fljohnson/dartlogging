import 'dart:async';
import 'dart:io';

import 'package:basketnerds/basepage.dart';
import 'package:basketnerds/logitem.dart';
import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Map <String,String> canister;


TextStyle dialogStyle(BuildContext context) {
  return Theme.of(context).textTheme.display2;
}


TextStyle rowStyle(BuildContext context) {
  return Theme.of(context).textTheme.title;

}

TextStyle largeTextFieldStyle(BuildContext context) {
  return Theme.of(context).textTheme.display2;
}
class PlanningPage extends PageWidget {
  DatePair myRange;

  bool ignited;

  PlanningPage({Key key}):super(key:key){
    //set the default date range
    String isoStart = Datademunger.getISOOffset(dmonths:1);
    var arry = isoStart.split("-");
    isoStart=arry[0]+"-"+arry[1]+"-01";
    String isoEnd = Datademunger.getISOOffset(dmonths:1,ddays:-1,fromISODate:isoStart);

    myRange = DatePair(isoStart,isoEnd);

  }


  @override
  _PlanningPageState createState() {
    toUpdate =  _PlanningPageState();
    return toUpdate;
  }

  @override
  fabClicked(BuildContext context) async {
    Logitem feedback;
    if(!Platform.isIOS) {
      feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder: PlanItemPage(defaultDate:myRange.isoFrom()).build)
      );
    }
    else {
      //TODO: sort out the iOS stuff per above
      /*
      feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder: CupertinoItemPage().build)
      );
      */
    }
    //("/item");

    if(feedback != null)
    {
      var chosen = feedback;
      //this looks ridiculous to those used to declarative languages
      //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
      chosen.save(entrytype:"planning").then((value) {
        if(value)
          {
            if(toUpdate == null)
            {
              print("FAIL! state is missing");
            }
            else
            {
              (toUpdate as _PlanningPageState).loadCategoryData();
            }
          }
          else
          {
            print("FAIL at save:${Logitem.lastError}");
          }

      });
    }
  }




  Widget upperlistHeader() {
    return Row(
        children:[
          Spacer(flex:1),
          Expanded(
              flex:1,
              child: Text("Specific items")
          )
          ,
          Expanded(
            flex: 1,
            child:Text("Gross allocation"),
          )

        ]
    );
  }
  Widget upperlistFooter() {
    return Row(
        children:[
          Expanded(
            flex:1,
            child: Text("Totals"),
          ),
          Expanded(
            flex:1,
            child: Text("\$1234.00"),
          ),
          Expanded(
            flex:1,
            child: Text("\$5678.90"),
          ),
        ]
    );
  }




}



class _PlanningPageState extends State<PlanningPage>{

  Map<String,String> categoryData = {};
  Map<String,String> categoryMicros = {};
  List<Logitem> lirows = [];




  @override void initState() {
    primeCategoryData();
    loadCategoryData();
    super.initState();

  }

  primeCategoryData()
  {
    //called for initial state
    var len = categories.length;
    for(int i=0;i<len;i++)
    {
      var categoryName = categories[i].keys.first.toString();
      categoryData[categoryName] = "\$0.00";
      categoryMicros[categoryName] = "\$0.00";
    }
  }


  loadCategoryData() async{
    num amt =0.0;
    var len = categories.length;
    var theSet = await Logitem.getPlannedTotals(widget.myRange.isoFrom(),widget.myRange.isoTo());
    var muTotals = await Logitem.getTotals(widget.myRange.isoFrom(),widget.myRange.isoTo(),entrytype:"planning");
    var theRange = await Logitem.getRange(widget.myRange.isoFrom(),widget.myRange.isoTo(), entrytype: "planning");
    setState(() {
      for(int i=0;i < muTotals.length;i++)
      {
        categoryMicros[muTotals[i].keys.first] = muTotals[i].values.first;
      }

      for (int i = 0; i < len; i++) {
        amt = 0.0;
        var categoryName = categories[i].keys.first.toString();
        if (theSet.containsKey(categoryName)) {
          amt = theSet[categoryName];
        }

        categoryData[categoryName] =
            Datademunger.toCurrency(amt, symbol: "\$");
        print("Fire two $i: $categoryName ${theSet[categoryName]}");

      }

      var eventlen = theRange.length;
      lirows.clear();
      for(int i=0;i<eventlen;i++)
      {
        lirows.add(theRange[i]);
      }

    });




    /* known to work
    for(int i=1;i<15;i++)
      {
        items.add(
          Row(
            children:[
              Expanded(
                flex:1,
                child:Text("Thing $i"),
              ),
              Expanded(
                  flex:1,
                  child:Text("Fine $i"),
              ),
              Expanded(
                  flex:1,
                  child:Text("Gross $i"),
              )
            ]
          )

            );
      }
      */
    /*
    return Row(
        children:[
          ListView(children: items)
        ]
    );
    */
  }


  List<Widget> upperlistView(BuildContext context) {
    List<Widget> items = [];

    var len = categories.length;

    for(int i=0;i<len;i++)
    {
      String categoryName = categories[i].keys.first;
      String amt = categoryData[categoryName];
      if(amt == null)
      {
        amt = "flub in $categoryName";
      }
      String specificTotal = categoryMicros[categoryName];

      items.add(
        FlatButton(
          padding: EdgeInsets.symmetric(vertical:4.0),
          onPressed: (){
            //it's already asynchronous
            newGross(categoryName,amt,widget.myRange.isoFrom());
          },
          child:Row(
              children:[
                Expanded(
                  flex:1,
                  child:Text(categoryName,style:rowStyle(context)),
                ),
                Expanded(
                  flex:1,
                  child:Text(specificTotal,style:rowStyle(context)),
                ),
                Expanded(
                  flex:1,
                  //child:Text(Datademunger.toCurrency(amt,symbol:"\$")),
                  child:Text(amt,style:rowStyle(context)),
                )

              ]
          )
        )
          
      );
    }
    return items;
  }
  
  void askCupertinoDate(BuildContext context,String originalDate, void actOnDate(String value) )
  {
    String rv = originalDate;
    List<String> datelets = originalDate.split("/");
    DateTime currentDate = new DateTime(int.parse(datelets[2]),int.parse(datelets[0]), int.parse(datelets[1]));
    DateTime minDate = new DateTime(currentDate.year,currentDate.month-2,1);
    DateTime maxDate = new DateTime(currentDate.year,currentDate.month+2,-1);


/*
//Todo: Rework this per https://docs.flutter.io/flutter/cupertino/CupertinoDatePicker-class.html
need a bottom sheet, a row containing cancel and done buttons, and a row containing the Picker
  CupertinoDatePicker.showDatePicker(
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
  */
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
      rv=Datademunger.fromISOtoUS("${value.year}-${value.month}-${value.day}");
    }

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
            //got away with putting all this here by dint of a non-awaited Future
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

    Widget upperlist = Expanded(flex:25,child:Row(
      children: <Widget>[
        Expanded(flex: 1,child:
        Container(
            width: 200.0,
            height:190.0,
            child:Column(
              children:[
                Expanded(
                  flex:1,
                  child: widget.upperlistHeader(),
                )
                ,
                Expanded(
                  flex:4,
                  child: Row(
                    children:[
                      Expanded(
                        flex:1,
                        child: ListView(children:upperlistView(context))
                      )
                     //
                    ]
                  )
                ),
                Expanded(
                  flex:1,
                  child: widget.upperlistFooter(),
                )


              ]
            ),
            color:Colors.blueGrey.shade100
        )
        )
      ],
    )
    );

    Widget lowerlist = Expanded(flex: 25,child:Row (
        children:[Expanded(flex:1,child:
        Container(
            width: 200.0,
            height:190.0,
            color:Colors.orangeAccent.shade100,
          child: Column(
            children: <Widget>[
              Expanded(
                flex:1,
                child: lowerlistHeader(),
              )
              ,
              Expanded(
                flex:4,
                child: lowerlistView(),
              ),
            ],

          ),

        )
        )
    ]
    )
    )
    ;




    List<Widget> daters = [
      Row(
          children:[
            Expanded(
                flex: 1,
                child: _getDateButton("From: ",widget.myRange.date1,((String value)
                {
                  widget.myRange.setDate1(value);
                  this.loadCategoryData();
                })
                )
            )
            ,
            Expanded(
                flex: 3,
                child: new Text(
                  widget.myRange.date1,
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
                child: _getDateButton("To: ",widget.myRange.date2,((String value)
                {
                  widget.myRange.setDate2(value);
                  this.loadCategoryData();
                })
                )
            )
            ,
            Expanded(
                flex: 3,
                child: new Text(
                  widget.myRange.date2,
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1,
                )
            )
          ]
      ),
      upperlist,
      Spacer(
      ),
      lowerlist
    ];

    //now add to daters
    return Column(
      children:daters
    );
  }


  Widget lowerlistHeader()
  {
    return Row(
        children:[
          Spacer(
            flex:1,
          ),
          Expanded(
            flex:1,
            child: Text("Category"),
          ),
          Expanded(
            flex:1,
            child: Text("Planned date"),
          ),
        ]
    );
  }


  Widget lowerlistView()
  {

      List<Widget> items = [];

      var len = lirows.length;
      for(int i=0;i<len;i++)
      {
        items.add(

            FlatButton(
              padding: EdgeInsets.symmetric(vertical:4.0),
              onPressed: (){
                //it's already asynchronous
                editSpecific(lirows[i]);
              },
              child:Row(
                  children:[
                    Expanded(
                      flex:1,
                      child:Text(lirows[i].title),
                    ),
                    Expanded(
                      flex:1,
                      child:Text(lirows[i].category),
                    ),
                    Expanded(
                      flex:1,
                      child:Text(lirows[i].stramount()),
                    )
                  ]
              )

            )


        );
      }
      /*
      known to work
      for(int i=1;i<15;i++)
      {

        items.add(
            Row(
                children:[
                  Expanded(
                    flex:1,
                    child:Text("Imstamt $i"),
                  ),
                  Expanded(
                    flex:1,
                    child:Text("Category $i"),
                  ),
                  Expanded(
                    flex:1,
                    child:Text("Date $i"),
                  )
                ]
            )

        );
      }
      */
      /*
    return Row(
        children:[
          ListView(children: items)
        ]
    );
    */
      return ListView(
          children:items
      );
    }

  void newGross(String categoryName, String amt,String date) async {

/*
    Navigator.of(context).push(new MaterialPageRoute(
      builder: new ChooseCredentialsPage().build,
      settings: new RouteSettings(name:"signup/choose_credentials")
    ));
    */

/*
    canister = {
      "category":categoryName,
      "amountString":amt,
      "isoDate":date
    };
    */

    if(amt =="\$0.00")
    {
      //calculate 1 month before and after myRange.isoStartDate
      String isoEarliest = Datademunger.getISOOffset(dmonths:-1,fromISODate: date);
      String isoLatest = Datademunger.getISOOffset(dmonths:1,fromISODate: date);
      print("checking for $categoryName between $isoEarliest and $isoLatest");
      //search for existing items in that range,
      List<List<String>> preexisting = await Logitem.getGrossPlanEntries(category:categoryName,
      from:isoEarliest,to:isoLatest);
      //if any, crank out a SimpleDialog
      if(preexisting.length>0)
      {
        List<Widget> opciones = [];
        for(int i=0;i<preexisting.length;i++)
        {
          String line =preexisting[i][0]+":"+preexisting[i][1];
          opciones.add(
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, preexisting[i]); },
                child:  Text(line),
              )
          );
          print("Already have for $categoryName ${preexisting[i]}");

        }
        opciones.add(
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, [date,amt]); },
              child:  Text("Or make a new one"),
            )
        );
        //run that dialog

        var aha = await showDialog<List<String>>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text('These $categoryName allocations exist and can be edited'),
                children: opciones,
              );
            }
        );
        if(aha == null)
        {
          print("Backed out");
          return;
        }
        print("edit for $aha");
        date = aha[0];
        amt = aha[1];
      }



          // end of
    }
    if(!Platform.isIOS) {

      String feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder:(context) => GrossallocPage(category:categoryName, isoDate:date,strAmount:amt))
      );
      loadCategoryData();
    }
    else {
      /*
      feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder: CupertinoItemPage().build)
      );
      */
    }
    //("/item");

    /*
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
    */

  }

  void editSpecific(Logitem toedit) async {
    Logitem feedback;
    if(!Platform.isIOS) {
      print("Starting $toedit");
      feedback = await Navigator.of(context).push(
          MaterialPageRoute(builder:(context) => PlanItemPage(incoming:toedit))
      );
    }


    if(feedback != null)
    {
      print("Got back ${feedback.title}");
      var chosen = feedback;
      //this looks ridiculous to those used to declarative languages
      //I think "declarative" is a superset to which "imperative" (good ol' C) and some O-O (C++, Java) belong
      chosen.save(entrytype:"planning").then((value) {
        if(value)
        {
          loadCategoryData();
        }
        else
        {
          print("FAIL at save:${Logitem.lastError}");
        }

      });
    }
  }

}


class GrossallocPage extends StatelessWidget {
  String category;
  String isoDate;
  String strAmount;
  RealGrossPage actualPage;

  GrossallocPage({Key key,@required this.category,@required this.isoDate,@required this.strAmount}):super(key:key);

  @override
  Widget build(BuildContext context) {

    actualPage = RealGrossPage(category:category,isoDate:isoDate,strAmount:strAmount);
    return new Scaffold (
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
            title: new Text(category),
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
                  //there was a ton going on here, so it's now in an async function
                  this.returnFromSavePlanned(context);
                },
              ),
            ]

        ),
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
            child: actualPage
        )
    );
  }

  void returnFromSavePlanned(BuildContext context) async {
    print("sending $category $isoDate, ${actualPage.strAmount}");
    Future<String> proto = Logitem.saveCategoryPlan(category:category,isoDate:isoDate,amount:actualPage.strAmount);
    proto.then((result) {
      /*
                    if(!Logitem.lastError.isNullOrEmpty())
                    {
                      alert(Logitem.lastError); //see main.dart for correct implementation
                    }
                    else
                    {
                     */
      if (result.startsWith("OK")) {
        Navigator.of(context).pop(category);
      }
    });
  }

}
/*
class RealGrossPage extends StatefulWidget {
  @override
  _RealGrossPageState createState() => new _RealGrossPageState();
}

class _RealGrossPageState extends State<RealGrossPage> {
  */
class RealGrossPage extends StatelessWidget {


  TextEditingController amtController;

  TextInputFormatter formatCurrency;

  String strAmount;
  String category;
  String isoDate;

  RealGrossPage({Key key,@required this.category,@required this.isoDate,@required this.strAmount}){
    formatCurrency = OneDecimalPoint();
    amtController= TextEditingController(text:strAmount.replaceAll("\$",""));
  }
  /*
  @override
  void initState() {
    formatCurrency = OneDecimalPoint();
    amtController= TextEditingController(text:canister["amountString"].replaceAll("\$",""));
    super.initState();
  }
  */
/*
  @override
  void dispose() {
    if(amtController != null)
    {
      amtController.dispose();
    }

    super.dispose();
  }
  */

  @override
  Widget build(BuildContext context)
  {





    return Column (
        children: <Widget>[
          Text("Date: "+ Datademunger.fromISOtoUS(this.isoDate),style:dialogStyle(context))
          ,
          Text(
            "Amount",
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .display1,
          )

        ,
          Container(
              width:200.0,
              alignment: Alignment.center,
              child: new TextField(
                controller: amtController,
                textAlign: TextAlign.center,
                inputFormatters: [formatCurrency],
                style: largeTextFieldStyle(context),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: ((String value){
                  strAmount = value;
                }),
              ),


              )
    ,
              Spacer()


              /*new Text(
                "Amount",
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .display1,
              )*/




        ]
    );
  }

}


class OneDecimalPoint extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    var first=newValue.text.indexOf(".");
    var last = newValue.text.lastIndexOf(".");
    if(first == last)
    {
      return newValue;
    }
    var phase1=newValue.text.replaceFirst(".","|");
    var phase2=phase1.replaceAll(".", "");

    TextEditingValue rv = newValue.copyWith(
      text: phase2.replaceFirst("|",".")
    );
    return rv;
  }

}


class PlanItemPage extends StatelessWidget{
  Logitem incoming;
  String defaultDate;

  PlanItemPage({Key key,this.incoming,this.defaultDate}): super(key:key);
  @override
  Widget build(BuildContext context) {
    String content = "(new)";
    if(incoming !=  null)
    {
      content = incoming.title;
    }

    if(incoming == null)
    {
      /*
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
*/

      incoming = new Logitem(
          name:"",
          amt: 0,
          category: "",
          date:defaultDate
      );
    }

    print("building full page");
    var zeForm = PlanitemPageform(incoming);
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
                  Navigator.of(context).pop(zeForm.chosen);
                },
              ),
            ]

        ),
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
            child: zeForm
        )
    );
  }
}

class PlanitemPageform extends StatefulWidget {
  Logitem chosen;
  PlanitemPageform(Logitem incoming,{Key key}):super(key:key) {
    //super(key:key);
    this.chosen = incoming;
    if(chosen == null)
    {
      print("Pageform got a null");
    }
    else
    {
      print("Pageform got $chosen");
    }
  }

  @override
  _ItemPageformState createState() {
    return _ItemPageformState();
  }

}

class _ItemPageformState extends State<PlanitemPageform> with PageState {

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

      for(int i=0;i<categories.length;i++) {
        categoryName.add(categories[i].keys.first);
        categoryNote.add(categories[i].values.first);
      }


      _controllerAmount = TextEditingController(text:widget.chosen.stramount());
      _controllerTitle = TextEditingController(text:widget.chosen.title);
      if(widget.chosen.details == null ||widget.chosen.details.isEmpty)
      {
        _controllerDetails = TextEditingController();
      }
      else
      {
        _controllerDetails = TextEditingController(text:widget.chosen.details);
      }

      if(widget.chosen == null)
      {
        print("Pageform initState got a null");
      }
      else
      {
        print("Pageform initState got ${widget.chosen}");
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
        widget.chosen.category = currentsel;
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
                widget.chosen.category = value;

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
        widget.chosen.category = currentsel;
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
                widget.chosen.category = value;
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

//I think this belongs in a class common to all of the Full-Screen Dialogs
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

      if(widget.chosen == null)
      {
        print("Pageform build got a null");
      }
      else
      {
        print("Pageform build got ${widget.chosen}");
      }
      String itemNamePrompt = "What it will be";

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
                          Datademunger.fromISOtoUS(widget.chosen.thedate),
                          ((String value){
                            widget.chosen.thedate=Datademunger.fromUStoISO(value);
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
                        Datademunger.fromISOtoUS(widget.chosen.thedate),
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
                inText:widget.chosen.title,
                hint:itemNamePrompt,
                changeHandler:(String newValue) {
                  widget.chosen.title = newValue;
                }
            ),
            saneTextField(
                controller:_controllerAmount,
                key:_keyAmt,
                inText:widget.chosen.stramount(),
                hint:"How much",
                type:"currency",
                changeHandler:(String newValue) {
                  //var auldSel = _controllerAmount.selection;
                  num goodNumber = Logitem.toNumber(newValue.replaceAll("\$", ""));
                  //_controllerAmount.text = Logitem.toDollarString(goodNumber);
                  widget.chosen.amount = goodNumber;
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


                      Platform.isIOS ? menumakerCupertino(context,widget.chosen.category) :
                      Expanded(flex:12,child:menumakerAndroid(widget.chosen.category))
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
                inText:widget.chosen.details,
                hint:"Details",
                type:"longedit",
                changeHandler:(String newValue) {
                  widget.chosen.details = newValue;
                }
            )

          ]
      );
    }



}