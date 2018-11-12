import 'dart:io';

List<Map<String,String>> categories =[
  {"Living expenses":"housing,telecommunications, utilities"},
  {"Groceries":null},
  {"Household":"hardware, cleaning supplies, furnishings"},
  {"Transportation":"tolls, fuel, fares, parking"},
  {"Entertainment":"includes food out"},
  {"Debts":null}
];

List<RegExp> patterns = [
  new RegExp(r"\d\d\d\d-\d\d?-\d\d?"),
  new RegExp(r"\d\d?[-/]\d\d?[-/]\d\d\d\d"),
];
class Datademunger {
	static String isoifyDate(String input)
	{

    for(int i=patterns.length -1;i>=0;i--)
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
      DateTime sensible = new DateTime(yr,mo,da);
      if(sensible.year != yr || sensible.month != mo) //we got a nonsensical date
      {
        throw FormatException("couldn't interpret date \"$toParse\"");
      }
      var result = sensible.toIso8601String().split("T");
      return result[0];
  }
}
