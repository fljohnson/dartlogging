import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<Map<String,String>> categories =[
  {"Living expenses":"housing,telecommunications, utilities, insurance"},
  {"Groceries":null},
  {"Household":"hardware, cleaning supplies, furnishings"},
  {"Transportation":"tolls, fuel, fares, parking"},
  {"Medical":"office visits,prescriptions"},
  {"Personal care":"clothing,haircuts,toiletries"},
  {"Entertainment":"includes food out"},
  {"Debts":null},
  {"Savings":null},
];

List<RegExp> patterns = [
  new RegExp(r"\d\d\d\d-\d\d?-\d\d?"),
  new RegExp(r"\d\d?[-/]\d\d?[-/]\d\d\d\d"),
  new RegExp(r"\d\d?[-/]\d\d?[-/]\d\d"),
];
class Datademunger {
	static String isoifyDate(String input)
	{

    for(int i=0;i<patterns.length;i++)
    {
      String suspect=patterns[i].stringMatch(input);
      if(suspect != null )
      {
        return _solver(i,suspect);
      }
    }
	  throw FormatException("Could not interpret date '$input'.");
	}

	static String _solver(int i, String toParse)
  {
    switch(i){
      case 0:
        return _straightISO(toParse);
      case 1:
        return _slashesToISO(toParse);
      case 2:
        return _shortdateToISO(toParse);
      default:
        throw FormatException("Could not interpret date '$toParse'.");
    }
  }

  static String _straightISO(String toParse)
  {
    List<String> dateparts = toParse.split("-");
    while(dateparts[1].length <2)
    {
      dateparts[1] = "0" + dateparts[1];
    }
    while(dateparts[2].length <2)
    {
      dateparts[2] = "0" + dateparts[2];
    }
    return dateparts[0]+"-"+dateparts[1]+"-"+dateparts[2];
  }

  static String _shortdateToISO(String toParse) {
    List<String> dateparts = toParse.split(new RegExp(r"[-/]"));
    int yr = int.parse(dateparts[2]);
    var now = DateTime.now();
    int century = (now.year/100).floor();
    //if the two-digit year is < 50, use the current century, otherwise, use the preceding one
    //this originated from the "Y2K" issue that came to popular attention in the late '90s
    if(yr >50)
    {
      century = century - 1;
    }
    dateparts[2] = "$century" + dateparts[2];
    return _slashesToISO(dateparts.join("/"));

  }

  static String _slashesToISO(String toParse)
  {
    List<String> dateparts = toParse.split(new RegExp(r"[-/]"));
    int da;
    int mo;
    int yr = int.parse(dateparts[2]);

    if(Platform.localeName=="en_US") //that one returns "en_US" here in the States
      {
      mo = int.parse(dateparts[0]);
      da = int.parse(dateparts[1]);
    }
    else
      {
        mo = int.parse(dateparts[1]);
        da = int.parse(dateparts[0]);
      }
    if(yr < 2015)
    {
      //how the blazes did we get yy/mm/20dd ?! (FLJ, 11/19/2018)
      String proto ="20"+toParse.replaceFirst("/20","");
      return proto.replaceAll("/", "-"); //
    }
      DateTime sensible = new DateTime(yr,mo,da);
      if(sensible.year != yr || sensible.month != mo) //we got a nonsensical date
      {
        throw FormatException("couldn't interpret date \"$toParse\"");
      }

      var result = sensible.toIso8601String().split("T");
      return result[0];
  }


//yyyy-mm-dd to mm/dd/yyyy
  static String fromISOtoUS(String inDate)
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

  //mm/dd/yyyy to yyyy-mm-dd
  static String fromUStoISO(String inDate)
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

  static String getISOOffset({int dmonths = 0 , int ddays = 0, String fromISODate}) {
	  if(fromISODate == null)
    {
      var base = DateTime.now();
      fromISODate = base.toIso8601String().split("T")[0];
    }
    var ymd =fromISODate.split("-");
    var yr=int.parse(ymd[0]);
    var mo=int.parse(ymd[1])+dmonths;
    var da=int.parse(ymd[2])+ddays;
    var sanity=DateTime(yr,mo,da);
    return sanity.toIso8601String().split("T")[0];
  }

  static String toCurrency(num amt, {String symbol=""}) {
	  var whole = amt.floor();
	  var fraction = ((amt - whole)*100).round().toString();
	  while(fraction.length <2)
    {
      fraction = "0"+fraction;
    }
	  return symbol+"$whole.$fraction";
  }
}

class DatePair {
  String _date1;
  String _date2;

  String get date1 => _date1;
  String get date2 => _date2;

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
    String comparedate1;
    String comparedate2;
    if(patterns[0].hasMatch(date1))
    {
      comparedate1 = date1;
      date1 = Datademunger.fromISOtoUS(date1);
    }
    else
    {
      comparedate1 =Datademunger.fromUStoISO(date1);
    }
    if(patterns[0].hasMatch(date2))
    {
      comparedate2=date2;
      date2 = Datademunger.fromISOtoUS(date2);
    }
    else
    {
      comparedate2=Datademunger.fromUStoISO(date2);
    }

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
    String comparedate1=Datademunger.fromUStoISO(_date1);
    String comparedate2=Datademunger.fromUStoISO(_date2);
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
    String comparedate1=Datademunger.fromUStoISO(_date1);
    String comparedate2=Datademunger.fromUStoISO(_date2);
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

void doAlert(BuildContext context,String what) {
  showDialog(
      context:context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Money Logs ran into trouble"),
          content: SingleChildScrollView(
              child: Text(what)
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('DISMISS'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
  );
}

Future<bool> askAboutGeneral(BuildContext bc, String d1,String d2) async {
  String what = "Also export the General Allocations for $d1 to $d2?";
  bool rv = await showDialog<bool>(
      context:bc,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("The Money Logs"),
          content: SingleChildScrollView(
              child: Text(what)
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.pop(context,true);
              },
            ),
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.pop(context,false);
              },
            )
          ],
        );
      }
  );
  return rv;
}

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

bool isISODate(String inDate)
{
  return patterns[0].hasMatch(inDate);
}
