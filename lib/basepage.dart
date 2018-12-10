import 'dart:io';

//import 'package:basketnerds/logitem.dart';
import 'package:basketnerds/pseudoresources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

TextStyle mainTextStyle = TextStyle(
    color:Colors.black,
  fontSize: 18.0,
  fontStyle: FontStyle.normal
);

TextStyle columnHeaderStyle = TextStyle (
  color:Colors.black,
  fontSize: 16.0,
  fontStyle: FontStyle.normal,
  fontWeight:FontWeight.bold,
  decoration:TextDecoration.none
);
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

  String cuperTemp;
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
  async
  {
    /*known good - keep this */
    //String rv = originalDate;
    List<String> datelets = originalDate.split("/");
    DateTime currentDate = new DateTime(int.parse(datelets[2]),int.parse(datelets[0]), int.parse(datelets[1]));
   // DateTime minDate = new DateTime(currentDate.year,currentDate.month-2,1);
   // DateTime maxDate = new DateTime(currentDate.year,currentDate.month+2,-1);


    var newDate = await showCupertinoDialog(context:context,builder:(context){
/*
minimumDate and maximumDate have no effect in CupertinoDatePickerMode.date - they only seem to work
for CupertinoDatePickerMode.dateAndTime, if the internal docs are any indicator
 */

      return CupertinoAlertDialog(
        content:Container(
          height: 250.0,
          child:CupertinoDatePicker(
            mode:CupertinoDatePickerMode.date,
            minimumYear: currentDate.year-1,
            maximumYear: currentDate.year+1,
            initialDateTime: currentDate,
            onDateTimeChanged: (value){
              String mo="${value.month}";
              String da="${value.day}";
              while(mo.length<2)
              {
                mo = "0"+mo;
              }
              while(da.length<2)
              {
                da = "0"+da;
              }
              this.cuperTemp = "${value.year}-$mo-$da";
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child:Text("OK"),
            isDefaultAction: true,
            isDestructiveAction: true,
            onPressed: (){
              Navigator.of(context).pop(this.cuperTemp);
            },

          )
      ,
          CupertinoDialogAction(
      child:Text("Cancel"),
      onPressed: (){
      Navigator.of(context).pop();
      },
      )
        ],
      );
    });

    if(newDate != null)
    {
      actOnDate(newDate);
    }
/*
//this came in from an add-on when the stock CupertinoDatePicker disappeared around Flutter v8.2
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
