import 'dart:io';

//import 'package:basketnerds/logitem.dart';
import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PageWidget extends StatefulWidget {
  /*
  State<PageWidget> toUpdate;
  DatePair myRange;
  */

  final List<String> range = [];
  PageWidget({Key key}) : super(key:key);

  @override
  State<PageWidget> createState() {
    return null;
  }

  fabClicked(BuildContext context) async {
    return null;
  }


}

abstract class PageState {
  State<PageWidget> toUpdate;
  DatePair myRange;
  //it needed to be common to all pages
  Widget getDateButton(BuildContext context,String label,String initialDate,actOnDate(String value)) {

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

  void askCupertinoDate(BuildContext context,String originalDate, void actOnDate(String value) )
  {
    /*known good - keep this
    String rv = originalDate;
    List<String> datelets = originalDate.split("/");
    DateTime currentDate = new DateTime(int.parse(datelets[2]),int.parse(datelets[0]), int.parse(datelets[1]));
    DateTime minDate = new DateTime(currentDate.year,currentDate.month-2,1);
    DateTime maxDate = new DateTime(currentDate.year,currentDate.month+2,-1);
*/

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
}