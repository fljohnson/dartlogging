import 'dart:io';

import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  DatePair myRange;

  @override
  _PlanningPageState createState() {
    return _PlanningPageState();
  }

  PlanningPage(){
    //set the default date range
    String isoStart = Datademunger.getISOOffset(dmonths:1);
    var arry = isoStart.split("-");
    isoStart=arry[0]+"-"+arry[1]+"-01";
    String isoEnd = Datademunger.getISOOffset(dmonths:1,ddays:-1,fromISODate:isoStart);
    
    myRange = DatePair(isoStart,isoEnd);

  }

}

class _PlanningPageState extends State<PlanningPage>{



  @override void initState() {
    super.initState();
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
            width: 200,
            height:190,
            color:Colors.blueGrey
        )
        )
      ],
    )
    );

    Widget lowerlist = Expanded(flex: 25,child:Row (
        children:[Expanded(flex:1,child:
        Container(
            width: 200,
            height:190,
            color:Colors.orangeAccent
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
                  setState(() {});
                  /*
                  fetchRows().then((goods) {
                    setState(() {});
                  }
                  );
                  */
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
                  setState(() {});
                  /*
                  fetchRows().then((goods) {
                    setState(() {});
                  });
                  */
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

}