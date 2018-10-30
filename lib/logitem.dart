import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'pseudoresources.dart';

class Logitem {

  static List<Logitem> sampleData = [];
  static Database database;
  static String path;

  static String toDollarString(num amount) {
    List<String> parts = ("$amount").split(".");
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
  
  static num toNumber(String textAmount)
  {
    List<String> parts = textAmount.split(".");
    num cents = 0;
    num dollars = 0;
    if(parts.length > 1)
    {
      cents = (int.parse((parts[1]+"00").substring(0,2))/100);
    }
    dollars = 100*(int.parse("0"+parts[0])+cents);
    num toto = dollars.round()/100; //THAT's how to round to a cent

    return toto;

  }

  static Future<bool> blankDB() async {
    bool rv = false;
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "demo.db");
    await deleteDatabase(path);
    rv = true;
    return rv;
  }

  static Future<bool> initDB() async {
    bool rv = false;
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE Logitem (id INTEGER PRIMARY KEY, what TEXT, category, TEXT, thedate TEXT, amount REAL, details TEXT)"
          );
          //and some indexing stuff
          //index on date
          await db.execute(
              "CREATE INDEX whens_IDX_logitem on Logitem(thedate)"
          );

          //index on category
          await db.execute(
              "CREATE INDEX whys_IDX_logitem on Logitem(category)"
          );
        });
    rv=true;
    return rv;
  }

  static Future<void> createSampleData() async {
    await blankDB();
    await initDB();
    Logitem proto;
    proto = new Logitem(
      name:"Trader Joe's run",
      amt: 55.82,
      category: "Groceries",
      date:"2018-09-28"
    );
    await proto.save();
    proto = new Logitem(
        name:"Rent",
        amt: 826.85,
        category: "Living expenses",
        date:"2018-10-03"
    );
    await proto.save();
    proto = new Logitem(
        name:"Adding to farecard",
        amt: 10,
        category: "Transportation",
        date:"2018-10-04"
    );
    await proto.save();
    proto = new Logitem(
        name:"Lunch at tavern",
        amt: 34.70,
        category: "Entertainment",
        date:"2018-10-04",
        details:"Don't panic. This is only a test. Repeat, this is only a test "
    );
    await proto.save();
    proto = new Logitem(
        name:"Chinese takeout",
        amt: 28.05,
        category: "Entertainment",
        date:"2018-10-07"
    );
    await proto.save();
  }
  static Future<List<Logitem>> getRange(String isoFrom, String isoTo) async {
    List<Logitem> rv = [];

    List<Map> raw = await database.rawQuery('SELECT * FROM Logitem where thedate >= ? and thedate <= ?',
        [isoFrom,isoTo]);

    for(int i=raw.length-1;i>=0 ;i--)
      {
        rv.add(Logitem.fromMap(raw[i]));
      }
    return rv;

  }

  static Future<List<Map<String, String>>> getTotals(String isoFrom, String isoTo) async {
    List<Map<String,String>> rv = [];
    for(int i=0;i<categories.length;i++)
      {
        String category = categories[i].keys.first;
        num total=0.0;

        List<Map> raw = await database.rawQuery('SELECT sum(amount) FROM Logitem where category = ? and thedate >= ? and thedate <= ?',
            [category,isoFrom,isoTo]);

        total = raw[0].values.first;
        if(total == null) {
          rv.add({category:"\$0.00"});
        }
        else {
          String strval = toDollarString(total);
          rv.add({category: strval});
        }
      }
      return rv;
  }

  int _id = -1;
  String thedate;
  String title;
  num amount;
  String category;
  String details;

  Logitem({@required String name,
    @required String date,
    @required num amt,
    @required String category,
    String details })
  {
    this.thedate = date;
    this.title = name;
    this.amount = amt;
    this.category = category;
    this.details = details;
  }

  String stramount() {
    List<String> parts = ("$amount").split(".");
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

  Logitem.fromMap(Map<String,dynamic> incoming)
  {
    this._id = incoming["id"];
    this.thedate = incoming["thedate"];
    this.title = incoming["what"];
    this.amount = incoming["amount"];
    this.category = incoming["category"];
    this.details = incoming["details"];
  }

  Future<bool> revert() async {
    bool rv = false;
    List<Map<String,dynamic>> raw = await database.rawQuery('SELECT * FROM Logitem where id = ?',
        [this._id]);

    var incoming = raw.first;
    this.thedate = incoming["thedate"];
    this.title = incoming["what"];
    this.amount = incoming["amount"];
    this.category = incoming["category"];
    this.details = incoming["details"];


    rv = true;
    return rv;
  }

  Future<bool> save() async {
    bool rv = false;
    if(_id == -1)
    {
      //insert. Doing it as a transaction for safety. rawInsert returns the last ID value to result
      await database.transaction((txn) async {
        if(details == null || details.isEmpty)
        {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate) VALUES(?,?,?,?)',
          [title,amount,category,thedate]);
        }
        else
        {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate,details) VALUES(?,?,?,?,?)',
              [title,amount,category,thedate,details]);
        }
      });
    }
    else
    {
      //do an update. rawUpdate returns a count of records changed
      if(details == null || details.isEmpty)
      {
        await database.rawUpdate(
            'UPDATE Logitem SET what = ?, amount = ?,category = ?,thedate =? ,details = NULL WHERE id = ?',
            [title,amount,category,thedate,_id]);
      }
      else
      {
        await database.rawUpdate(
            'UPDATE Logitem SET what = ?, amount = ?,category = ?,thedate =? ,details = ? WHERE id = ?',
            [title,amount,category,thedate,details,_id]);
      }
    }


    rv = true;
    return rv;
  }
}