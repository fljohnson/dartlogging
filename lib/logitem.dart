import 'package:meta/meta.dart';
import 'pseudoresources.dart';

class Logitem {

  static List<Logitem> sampleData = [];

  static void createSampleData() {
    sampleData.add(new Logitem(
      name:"Trader Joe's run",
      amt: 55.82,
      category: "Groceries",
      date:"2018-09-28"
    ));
    sampleData.add(new Logitem(
        name:"Rent",
        amt: 826.85,
        category: "Living expenses",
        date:"2018-10-03"
    ));
    sampleData.add(new Logitem(
        name:"Adding to farecard",
        amt: 10,
        category: "Transportation",
        date:"2018-10-04"
    ));
    sampleData.add(new Logitem(
        name:"Lunch at tavern",
        amt: 34.70,
        category: "Entertainment",
        date:"2018-10-04"
    ));
    sampleData.add(new Logitem(
        name:"Chinese takeout",
        amt: 28.05,
        category: "Entertainment",
        date:"2018-10-07"
    ));
  }
  static List<Logitem> getRange(String isoFrom, String isoTo) {
    List<Logitem> rv = [];
    for(int i=sampleData.length-1;i>=0 ;i--)
      {
        rv.add(sampleData[i]);
      }
    return rv;

  }

  static List<Map<String,String>> getTotals(String isoFrom, String isoTo) {
    List<Map<String,String>> rv = [];
    for(int i=0;i<categories.length;i++)
      {
        String category = categories[i].keys.first;
        num total=0.0;
        for(int j=0;j<sampleData.length;j++)
          {
            if(sampleData[j].category == category)
              {
                total += sampleData[j].amount;
              }

          }

        rv.add({category:"\$$total"});
      }
      return rv;
  }

  String thedate;
  String title;
  num amount;
  String category;
  String details;

  Logitem({@required String name,
    @required String date,
    @required num amt,
    @required String category,
    String details = null})
  {
    this.thedate = date;
    this.title = name;
    this.amount = amt;
    this.category = category;
    this.details = details;
  }

  String stramount() {
    List<String> parts = ("${amount}").split(".");
    if(parts.length == 1)
      {
        parts.add("00");
      }
      else
        {
          while(parts[1].length<2)
            {
              parts[1] += "0";
            }
        }

    return "\$${parts[0]}.${parts[1]}";
  }
}