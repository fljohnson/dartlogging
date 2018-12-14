import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'pseudoresources.dart';
import 'package:csv/csv.dart';
/*
Find out how Dart handles errors returned by await-ed async functions
*/
class Logitem {

  static MethodChannel platform;

  static List<Logitem> sampleData = [];

  static Database database;
  static String path;
  //static Directory docsdir;
 // static String docsdir2;
  static List<String> categoryNames = [];
  static String lastError;

  static bool semaphore = false;

  static String toDollarString(num amount) {
    List<String> parts = ("$amount").split(".");
    if (parts.length == 1) {
      parts.add("00");
    }
    else {
      num better = num.parse("0."+parts[1])*100;
      parts[1] = (better.round()).toString();
      while (parts[1].length < 2) {
        parts[1] += "0";
      }
    }

    return "\$${parts[0]}.${parts[1]}";
  }

  static num toNumber(String textAmount) {
    List<String> parts = textAmount.split(".");
    num cents = 0;
    num dollars = 0;
    if (parts.length > 1) {
      cents = (int.parse((parts[1] + "00").substring(0, 2)) / 100);
    }
    dollars = 100 * (int.parse("0" + parts[0]) + cents);
    num toto = dollars.round() / 100; //THAT's how to round to a cent

    return toto;
  }

  static Future<bool> blankDB() async {
    bool rv = false;
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "moneylogs.db");
    //await deleteDatabase(path); //remove before going live
    //throw PathException("intentional bombout");
    rv = true;
    return rv;
  }

  static Future<String> getExtDir(String lastfolder) async
  {
    String rv = "(no data)";
    try {
      final String result = await platform.invokeMethod(
          "getExternalDir", lastfolder);
      rv = result;
    } on PlatformException catch(ecch) {
      rv = ecch.message;
    }
    return rv;
  }

static Future<String> exportToExternal({String localUrl}) async {
    lastError = null;
    if(platform == null) //shouldn't be an issue, but..
    {
      platform = const MethodChannel('com.fouracessoftware.basketnerds/filesys');
    }
    String rv;
    try {
      final String result = await platform.invokeMethod(
        "exportToExternal",[localUrl]);
      rv = result;
    }
    on PlatformException catch(ecch) {
      lastError = ecch.message;
    }
    return rv;
  }
  
  static Future<String> getFileToOpen({bool write:false}) async {
    lastError = null;
    if(platform == null) //shouldn't be an issue, but..
    {
      platform = const MethodChannel('com.fouracessoftware.basketnerds/filesys');
    }

    String rv;
    try {
      final String result = await platform.invokeMethod(
        "getFileToOpen",[write]);
      if(result !=null)
      {
        if(write)
        {

          if(result == "" )
          {
            lastError = "Directory is not writable";
            return rv;
          }
          rv = result;
          //todo: degoof "name .csv" AND name (n).csv";
          //print("got filename $rv");
          if(result.endsWith(" .csv"))
          {
            rv = result.replaceAll(" .csv",".csv");
            await File(result).rename(rv);
          }
        }
        else
        {
          rv = result;
        }

      }

      //rv = result;
    }
    on PlatformException catch(ecch) {
      lastError = ecch.message;
    }

    return rv;
  }

  static Future<String> getFileToWrite() async {
    return getFileToOpen(write:true);
  }
  static Future<bool> initDB() async {
    bool rv = false;

    for(int i=0;i<categories.length;i++)
    {
      //print("adding ${categories[i].keys.first} at position $i");
      categoryNames.add(categories[i].keys.first);
    }
    platform = const MethodChannel('com.fouracessoftware.basketnerds/filesys');

   // docsdir2 = await getExtDir("My Documents");
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table

            await db.execute(
                "CREATE TABLE Logitem (id INTEGER PRIMARY KEY, what TEXT, category, TEXT, thedate TEXT, amount REAL, details TEXT,entryType TEXT DEFAULT 'logging')"
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

            //possible time-saving alteration
            await db.execute(
                "CREATE INDEX etype_IDX_logitem on Logitem(entryType)"
            );

            //okay, now that new table
            await db.execute(
                "CREATE TABLE Planitem (id INTEGER PRIMARY KEY, category TEXT, thedate TEXT, amount REAL)"
            );
            //and some indexing stuff
            //index on date
            await db.execute(
                "CREATE INDEX whens_IDX_planitem on Planitem(thedate)"
            );

            //index on category
            await db.execute(
                "CREATE INDEX whys_IDX_planitem on Planitem(category)"
            );


        },
      /*  onUpgrade: (Database db, int oldversion,int newversion) async {
        for(int i=oldversion;i<newversion;i++)
        {
          if(i == 1) //v1 to v2
          {

            await db.execute(
              "ALTER TABLE Logitem ADD entryType TEXT DEFAULT 'logging'"
            );
            //possible time-saving alteration
            await db.execute(
                "CREATE INDEX etype_IDX_logitem on Logitem(entryType)"
            );

            //okay, now that new table
            await db.execute(
                "CREATE TABLE Planitem (id INTEGER PRIMARY KEY, category TEXT, thedate TEXT, amount REAL)"
            );
            //and some indexing stuff
            //index on date
            await db.execute(
                "CREATE INDEX whens_IDX_planitem on Planitem(thedate)"
            );

            //index on category
            await db.execute(
                "CREATE INDEX whys_IDX_planitem on Planitem(category)"
            );
          }
          if(i == 2) //v2 to v3
          {
            //fix planitem goof
            await db.execute(
                "DROP TABLE Planitem"
            );
            await db.execute(
                "CREATE TABLE Planitem (id INTEGER PRIMARY KEY, category TEXT, thedate TEXT, amount REAL)"
            );
            //and some indexing stuff
            //index on date
            await db.execute(
                "CREATE INDEX whens_IDX_planitem on Planitem(thedate)"
            );

            //index on category
            await db.execute(
                "CREATE INDEX whys_IDX_planitem on Planitem(category)"
            );
          }
        }
      }*/
    );
    rv = true;
    return rv;
  }

  static Future<void> createSampleData() async {
    //docsdir = await getExternalStorageDirectory();
    if(categoryNames.length == 0) {
      await blankDB();
      await initDB();
    }
    else {
      if(database == null)
        {
          print("fired twice at blanks");
        }
    }
    /*
    Logitem proto;
    proto = new Logitem(
        name: "Trader Joe's run",
        amt: 55.82,
        category: "Groceries",
        date: "2018-09-28"
    );
    await proto.save();
    proto = new Logitem(
        name: "Rent",
        amt: 826.85,
        category: "Living expenses",
        date: "2018-10-03"
    );
    await proto.save();
    proto = new Logitem(
        name: "Adding to farecard",
        amt: 10,
        category: "Transportation",
        date: "2018-10-04"
    );
    await proto.save();
    proto = new Logitem(
        name: "Lunch at tavern",
        amt: 34.70,
        category: "Entertainment",
        date: "2018-10-04",
        details: "Don't panic. This is only a test. Repeat, this is only a test "
    );
    await proto.save();
    proto = new Logitem(
        name: "Chinese takeout",
        amt: 28.05,
        category: "Entertainment",
        date: "2018-10-07"
    );
    await proto.save();
    */
  }

  static Future<List<Logitem>> getRange(String isoFrom, String isoTo,{String entrytype = "logging"}) async {
    if(database == null)
    {
      print("In getRange $entrytype");
      await createSampleData();
    }
    List<Logitem> rv = [];

    List<Map> raw = await database.rawQuery(
       'SELECT * FROM Logitem where entryType = ? AND thedate >= ? and thedate <= ? ORDER BY thedate DESC',
        [entrytype,isoFrom, isoTo]);
    /*
    'SELECT * FROM Logitem where thedate >= ? and thedate <= ? ORDER BY thedate DESC',
    [isoFrom, isoTo]);
    */
    for (int i = 0;i< raw.length ;i++) {
      //print("hit id # ${raw[i]['id']} ${raw[i]['thedate']}");
      rv.add(Logitem.fromMap(raw[i]));
    }
    return rv;
  }

  static Future<List<Map<String, String>>> getTotals(String isoFrom,
      String isoTo,{String entrytype = "logging"}) async {
    List<Map<String, String>> rv = [];

    for (int i = 0; i < categories.length; i++) {
      String category = categories[i].keys.first;
      num total = 0.0;
      //lastError += "Sought: \"$category\"";
      List<Map> raw = await database.rawQuery(
          'SELECT sum(amount) FROM Logitem where entryType = ?  and category = ? and thedate >= ? and thedate <= ?',
          [entrytype,category, isoFrom, isoTo]);

      total = raw[0].values.first;
      if (total == null) {
        rv.add({category: "\$0.00"});
      }
      else {
        String strval = toDollarString(total);
        rv.add({category: strval});
      }
    }
    return rv;
  }
  static Future<Map<String, num>> getNumericTotals(String isoFrom,
      String isoTo,{String entrytype = "logging"}) async {
    Map<String, num> rv = {};

    lastError="";
    try {

      for (int i = 0; i < categories.length; i++) {
        String category = categories[i].keys.first;
        num total = 0.0;

        //lastError += "Sought: \"$category\"";
        List<Map> raw = await database.rawQuery(
            'SELECT sum(amount) FROM Logitem where entryType = ?  and category = ? and thedate >= ? and thedate <= ?',
            [entrytype,category, isoFrom, isoTo]);

        total = raw[0].values.first;
        if (total == null) {
          rv[category] = 0.0;
        }
        else {
          if(!rv.containsKey(category))
          {
            rv[category] = 0.0;
          }
          rv[category] += total;
        }
      }
    }
    catch(ecch) {
      lastError=ecch.toString();
      print("Falta: $lastError");
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
    String details }) {
    this.thedate = date;
    this.title = name;
    this.amount = amt;
    this.category = category;
    this.details = details;
  }

  String stramount() {
    /* D_R_Y
    List<String> parts = ("$amount").split(".");
    if (parts.length == 1) {
      parts.add("00");
    }
    else {
      while (parts[1].length < 2) {
        parts[1] += "0";
      }
    }

    return "\$${parts[0]}.${parts[1]}";
    */
    return toDollarString(amount);
  }

  Logitem.fromMap(Map<String, dynamic> incoming)
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
    List<Map<String, dynamic>> raw = await database.rawQuery(
        'SELECT * FROM Logitem where id = ?',
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

  Future<bool> save({String entrytype = "logging"}) async {
    bool rv = false;
    if (_id == -1) {
      //insert. Doing it as a transaction for safety. rawInsert returns the last ID value to result
      await database.transaction((txn) async {
        if (details == null || details.isEmpty) {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate,entryType) VALUES(?,?,?,?,?)',
              [title, amount, category, thedate,entrytype]);
        }
        else {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate,details,entryType) VALUES(?,?,?,?,?,?)',
              [title, amount, category, thedate, details,entrytype]);
        }
      });
    }
    else {
      //do an update. rawUpdate returns a count of records changed
      if (details == null || details.isEmpty) {
        await database.rawUpdate(
            'UPDATE Logitem SET what = ?, amount = ?,category = ?,thedate =? ,details = NULL WHERE id = ?',
            [title, amount, category, thedate, _id]);
      }
      else {
        await database.rawUpdate(
            'UPDATE Logitem SET what = ?, amount = ?,category = ?,thedate =? ,details = ? WHERE id = ?',
            [title, amount, category, thedate, details, _id]);
      }
    }


    rv = true;
    return rv;
  }

  static Future<void> doExport(String filename, String isoFrom, String isoTo) async {
	  lastError = null;
    //Future<List<List<dynamic>>> toWrite = _getCSVExportable(isoFrom, isoTo);
    List<List<dynamic>> rows = await _getCSVExportable(isoFrom, isoTo);
    //toWrite.then((rows) {
      if(rows != null) {
        //we need a file dialog here

        /*
		  final csvCodec = new CsvCodec();

		  final stream = new Stream.fromIterable(rows);
		  final csvRowStream = stream.transform(csvCodec.encoder);
		  */
		  try {
			final outstring = const ListToCsvConverter().convert(rows);

			//final oot = new File(join(docsdir.path,filename));
			final oot = new File(filename);
			oot.writeAsStringSync(outstring, flush:true);
			}
		catch(e) {
			lastError = e.toString();
			print("failed $lastError");
		}
      }
   // });
  }

  static Future<List<List<dynamic>>> _getCSVExportable(String from,  String to) async {

    final res = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    if(res != PermissionStatus.authorized)
    {
      print("bailing due to permission $res");
      return null;
    }
    List<Logitem> rawGoods = await getRange(from, to);
    List<List<dynamic>> rv = [
      ["ID","Date","What","Amount","Category","Details"]
    ];
   // print("about to write ${rawGoods.length} records");
    for(Logitem row in rawGoods)
    {
      if(row.details == null){
          rv.add([
            row._id, row.thedate, row.title, row.amount, row.category
          ]);
        }
        else {
        rv.add([
          row._id, row.thedate, row.title, row.amount, row.category, row.details
        ]);
      }
    }
    return rv;
  }

static Future<int> doIOSImport(String fileContents) async {
int rv = 0;
    lastError = "";
    /*
    final res = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    if(res != PermissionStatus.authorized)
    {
      return rv;
    }
    */

    //problem 1: grab the file contents
    List<String> readin;

    try {
      //final input = new File(filetoread);
      //readin = await input.readAsString();
      //readin = input.readAsLinesSync();
      readin = fileContents.split("\n");
      //throw FormatException("got ${readin.length} records");
      await _doCSVImport(readin);
      if(lastError == "")
      {
      	rv = 1; //consider setting this to number of rows actually inserted
      }
      else
      {
      	rv = -1;
      }
    }
    catch(ecch)
    {
     // if(lastError.length == 0) {
        lastError = ecch.message;
     // }
      rv = -1;
    }
    return rv;
}
  static Future<int> doImport(String filetoread) async {
    int rv = 0;
    lastError = "";
    final res = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    if(res != PermissionStatus.authorized)
    {
      return rv;
    }

    //problem 1: grab the file contents
    List<String> readin;

    try {
      final input = new File(filetoread);
      //readin = await input.readAsString();
      readin = input.readAsLinesSync();
      await _doCSVImport(readin);
      rv = 1; //consider setting this to number of rows actually inserted
    }
    catch(ecch)
    {
      if(lastError.length == 0) {
        lastError = ecch.message;
      }
      rv = -1;
    }
    return rv;
  }



  static Future<void> _doCSVImport(List<String> incsv) async
  {
    List<String> criticalColumns = ["Date","What","Amount","Category"];
    List<String> columns = ["Date","What","Amount","Category","Details"];
    Map<String,int> indices = Map();
    //List<List<dynamic>> raw = CsvToListConverter().convert(incsv);
    List<List<dynamic>> raw = [];
    for(int j=0;j<incsv.length;j++)
    {
      raw.add(CsvToListConverter().convert(incsv[j])[0]);
    }
    //now, process raw
    //1. Is there a header row?
    int toGo = criticalColumns.length;
    for(int i=raw[0].length-1;i>=0;i--)
    {
      int index = columns.indexOf(raw[0][i]);
      if(index > -1)
      {
        if(!indices.containsKey(raw[0][i]))
        {
          indices[raw[0][i]] = i;
        }
      }
      if(criticalColumns.indexOf(raw[0][i]) > -1)
      {
        toGo--;
      }
    }
    if(toGo > 0)
    {
      lastError = 'One of more of columns "Date","What","Amount","Category" is missing from the chosen file';
      return; //As Seth Meyers would say, "Ya burnt!"
    }
    //2. loop through the data rows, and those found admissible go in.
    int z=raw.length;
    String possDate;
    String possWhat;
    num possAmount;
    String possCategory;
    String possDetails;
    for(int i=1;i<z;i++)
    {
        try {
          possDate = Datademunger.isoifyDate(raw[i][indices["Date"]]);
          possWhat = raw[i][indices["What"]];
          possAmount = raw[i][indices["Amount"]];
          possCategory = raw[i][indices["Category"]];
        }
        catch (e) {
          //hopefully, it was an Array out-ouf-bounds exception ; this may cover TypeError
          lastError = e.toString();
          if(lastError.indexOf("type") >-1 && lastError.indexOf("'num'") > -1 )
          {
            lastError = "Problem encountered on line $i:Expected a numeric amount";
            throw FormatException(lastError);
          }
          lastError = "Problem encountered on line $i:"+lastError;
          //really need to alert the user to screwed-up input, and therefore bail like Mr. Organa

            throw e;
        }

        //this one's optional
        try {
          possDetails = raw[i][indices["Details"]];
        }
        catch(e) {

        }

        //forgot to ask if the category exists
        //is there even a category value?
        if(possCategory == null || possCategory.length ==0)
        {
          lastError = "Problem encountered on line $i: Category field is blank";
          throw FormatException(lastError);
        }
        String upcase =possCategory.toUpperCase();
        possCategory = upcase.substring(0,1) + possCategory.toLowerCase().substring(1);
        //is the incoming category value among those known to the app?
        print("|$possCategory| vs ${categoryNames.length}");
        if(categoryNames.indexOf(possCategory) == -1)
        {
          lastError = "Problem encountered on line $i: unknown category \"$possCategory\"";
          throw FormatException(lastError);
        }

        //if we're here, it's safe to check for preexistence
        List<Map> presence = await database.rawQuery(
            'SELECT * FROM Logitem where category = ? and thedate = ? and amount = ? and what = ?',
            [possCategory, possDate, possAmount,possWhat]);

        if(presence.length == 0)
        {
          await _insertFromCSV(possWhat,possAmount,possCategory,possDate,possDetails);
        }




    }
  }

  static Future<void> _insertFromCSV(String title,num amount, String category,String thedate,String details) async
  {
    //insert. Doing it as a transaction for safety. rawInsert returns the last ID value to result
    await database.transaction((txn) async {
      try {
        if (details == null || details.isEmpty) {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate,entryType) VALUES(?,?,?,?,"logging")',
              [title, amount, category, thedate]);
        }
        else {
          await txn.rawInsert(
              'INSERT INTO Logitem(what,amount,category,thedate,details) VALUES(?,?,?,?,?)',
              [title, amount, category, thedate, details]);
        }
      }
      catch(ecch)
      {
        lastError = ecch.toString();
        print("DOH! $lastError");
      }
    });
  }

  static Future<Map<String,num>> getPlannedTotals(String isoFrom, String isoTo) async {
    lastError="";
    if(database == null)
    {
      print("in getPlannedTotals");
      await createSampleData();
    }
    Map<String,num> rv = Map<String,num>();
    //initialize, to guard against where there never was a Planitem entry for a given category
    for(int i=0;i<categories.length;i++)
    {
      rv[categories[i].keys.first] = 0.0;
    }
    try {
      List<Map> raw = await database.rawQuery(
          'SELECT category,amount FROM Planitem where thedate >= ? and thedate <= ?',
          [isoFrom, isoTo]);

      for (int i = raw.length - 1; i >= 0; i--) {
        rv[raw[i].values.first] = 0.0;
      }
      for (int i = raw.length - 1; i >= 0; i--) {
        rv[raw[i].values.first] += raw[i].values.last;
       /// print("PEEK in getPlannedTotals $isoFrom-$isoTo :$rv");
      }
    }
    catch(ohcrap)
    {
      lastError=ohcrap.toString();
      print("MISS in getPlannedTotals $isoFrom-$isoTo :$lastError");
    }

    return rv;
  }

  static Future<String> saveCategoryPlan({String category, String isoDate, String amount}) async {
    int result;
    String rv = "";
    List<String> parts = amount.replaceAll("\$", "").split(".");
    num numAmount =  int.parse(parts[0]);
    if(parts.length > 1)
    {
      numAmount += (.01 * int.parse(parts[1].substring(0,2)) );
    }
    await database.transaction((txn) async {
      try {
        var mess = await txn.rawQuery("SELECT * FROM Planitem where thedate = ? and category = ?", [isoDate,category]);
/* debugging
        if(mess != null) {
          print("BOOM! $mess");
        }
        else
        {
          print("BOOM! got null result");
        }
        */

        if(mess.length == 0)
        {
          await txn.rawInsert("INSERT INTO Planitem (category,thedate,amount) VALUES(?,?,?)",[category,isoDate,numAmount]);
          rv="OK";
        }
        else
        {
          int gottenId = mess[0]["id"];
          //print("intent: set $gottenId to $numAmount");
          result = await txn.rawUpdate("UPDATE Planitem SET amount = ? WHERE id = ?",[numAmount,gottenId]);
          if(result == 1)
          {
            rv = "OK $result $gottenId $numAmount";
          }
          else
          {
            rv = "DB UHOH regarding Planitem";
          }
        }

      }
      catch(falta)
      {
        lastError = falta.toString();
        //print("FAIL! $lastError");
      }


    });

    return rv;
  }

  static Future<List<List<String>>> getGrossPlanEntries({String category, String from, String to}) async {
    lastError = "";
    List<List<String>> rv = [];
    await database.transaction((txn) async {
      var mess = await txn.rawQuery(
          'SELECT thedate,amount FROM Planitem where thedate >= ? and thedate <= ? and category = ?',
          [from, to,category]);
      for(int i=0;i<mess.length;i++)
      {
        rv.add([mess[i]["thedate"],Datademunger.toCurrency(mess[i]["amount"],symbol:"\$")]);
      }
    });

    return rv;
  }
}

List<VoidCallback> finishedDB = [];

void smashDB() async {
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
