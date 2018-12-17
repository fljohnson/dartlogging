
import 'dart:io';
import 'dart:math';

import 'package:basketnerds/basepage.dart';
import 'package:basketnerds/logitem.dart';
import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class DummyPage extends PageWidget {
  final TabController tabster;
  DummyPage({Key key, this.tabster}):super(key:key);

  @override
  _DummyPageState createState() {
    return new _DummyPageState(tabctl:tabster);
  }

  @override
  bool haveFAB() {
    return false;
  }
}

class _DummyPageState extends State<DummyPage> with PageState {
  TabController tabctl;
  num moment;

  _DummyPageState({this.tabctl}){
    moment = tabctl.animation.value;
  }
  //can you smell the potential for reuse?


  Map<String,String> actualTotals = {};
  Map<String,String> plannedTotals = {};
  List<Widget> gottenRows = [];
  bool fired = false;

  @override void initState() {

    super.initState();

    if(widget.range.length==0) {
      //set the default date range
      String isoStart = Datademunger.getISOOffset(dmonths: 0);
      var arry = isoStart.split("-");
      isoStart = arry[0] + "-" + arry[1] + "-01";
      String isoEnd = Datademunger.getISOOffset(
          dmonths: 1, ddays: -1, fromISODate: isoStart);
      widget.range.add(isoStart);
      widget.range.add(isoEnd);
    }

    myRange = DatePair(widget.range[0],widget.range[1]);

    primeTotals();


	if(Platform.isIOS)
	{
		//if(widget.active[0])
		//{
			loadTotals();
		//}
	}
	else
	{
		if(moment > 0 && moment < 2 ) {
		  loadTotals();
		}
	}
    

  }


  void primeTotals()
  {
    //called for initial state
    var len = categories.length;
    for(int i=0;i<len;i++)
    {
      var categoryName = categories[i].keys.first.toString();
      actualTotals[categoryName] = "\$0.00";
      plannedTotals[categoryName] = "\$0.00";
    }
  }

  void loadTotals() async
  {
    try{

      var results = await Logitem.getNumericTotals(myRange.isoFrom(), myRange.isoTo(),entrytype: Logitem.LITYPE_LOGGING);
      var microplanned = await Logitem.getNumericTotals(myRange.isoFrom(), myRange.isoTo(),entrytype: Logitem.LITYPE_PLANNING);
      var macroplanned = await Logitem.getPlannedTotals(myRange.isoFrom(), myRange.isoTo());
      if(!Platform.isIOS)
      {
        if(moment == 0 || moment == 2 ) {
          return;
        }
      }
      setState(() {
        var len = results.length;
        for (int i = 0; i < len; i++) {
          var categoryName = categories[i].keys.first;
          actualTotals[categoryName] =
              Datademunger.toCurrency(results[categoryName],symbol:"\$"); //Logitem.toDollarString(results[categoryName]);
          //print("Comparing for $categoryName ${microplanned[categoryName]} vs ${macroplanned[categoryName]}");
          num winner = max(
              microplanned[categoryName], macroplanned[categoryName]);
          plannedTotals[categoryName] = Datademunger.toCurrency(winner,symbol:"\$"); //Logitem.toDollarString(winner);
        }
      });
    }
    catch(ecch)
  {
    doAlert(context,"Blew up in loadTotals:"+ecch.toString());
  }

  }
  Future<bool> getTotals(BuildContext context) async
  {
    bool rv = false;
    //just in case this page is ever drawn first
    /*
    if(Logitem.database == null)
    {
      await Logitem.createSampleData();
    }
    */
    List<Widget> rows = [];

    List<Map<String,String>> stats = await Logitem.getTotals(myRange.isoFrom(),myRange.isoTo());
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

  List<Widget> drawTable()
  {
    List<Widget> rows = [];
    var len = categories.length;
    for(int i=0;i<len;i++)
    {
      String categoryName = categories[i].keys.first;
      rows.add(
        Container(
          margin:EdgeInsets.symmetric(vertical: 2.0),
          child:Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                    child:Text(categoryName,style: Theme
                        .of(context)
                        .textTheme
                        .title
                    )
                ),
              ),
              Expanded(
                flex: 2,
                child:Text(plannedTotals[categoryName],style: Theme
                    .of(context)
                    .textTheme
                    .title,
                    textAlign: TextAlign.right
                ),
              ),
              Expanded(
                flex: 2,
                child:Text(actualTotals[categoryName],style: Theme
                    .of(context)
                    .textTheme
                    .title,
                    textAlign: TextAlign.right
                ),
              ),
            ],

          )
        )


      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> totalstable = drawTable();
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
                    child: getDateButton(context,"From: ",myRange.date1,((String value)
                    {
                      widget.range[0] = value;
                      myRange.setDate1(value);
                      loadTotals();
                      /*
                      getTotals(context).then((goods) {
                        setState(() {});
                      }
                      );
                      */
                    })),


                  )
                  ,
                  Expanded(
                      flex: 3,
                      child: new Text(
                        myRange.date1,
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
                    child: getDateButton(context, "To: ",myRange.date2,((String value)
                    {
                      widget.range[1] = value;
                      myRange.setDate2(value);
                      loadTotals();
                      /*
                      getTotals(context).then((goods) {
                        setState(() {});
                      }
                      );
                      */
                    })),

                  )
                  ,
                  Expanded(
                      flex: 3,
                      child: new Text(
                        myRange.date2,
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
                  Spacer(
                    flex:3,
                  ),
                  Expanded(
                    flex:2,
                    child: Text("Planned",
                    	style:columnHeaderStyle,
                        textAlign: TextAlign.right),
                  ),
                  Expanded(
                    flex:2,
                    child: Text("Actual",
                        style:columnHeaderStyle,
                        textAlign: TextAlign.right),
                  ),
                ]
            ),
            Expanded(
                child: ListView(
                    children:totalstable
                )
            ),

          ],
        )
    );
  }
}
