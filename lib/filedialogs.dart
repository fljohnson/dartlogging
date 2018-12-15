import 'package:basketnerds/basepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

String chosenFilename;
class SaveAsDlg extends StatelessWidget{
  final String ext;


  SaveAsDlg({this.ext});



  
  @override
  Widget build(BuildContext context) {
  
	return CupertinoPageScaffold(
          navigationBar: new CupertinoNavigationBar(
              automaticallyImplyLeading: true,
              middle:new Text("Export to CSV"),
              trailing: CupertinoButton(
                  child:Text("Save"),
                  onPressed: (){
                    Navigator.of(context).pop(chosenFilename);
                  }
              ),
              backgroundColor: CupertinoColors.white
          )
          ,
          child: RealSaveDlg(progen:context,fex:ext)
      );
      
    
  }
  
}


class RealSaveDlg extends StatelessWidget {
  
  final BuildContext progen;
  final String fex;
  final Future<Directory> _appDocumentsDirectory = getApplicationDocumentsDirectory();

  final List<String> docspath = [null];
  RealSaveDlg({Key key,this.progen, this.fex}):super(key:key);

  Widget _listing(Directory dir) {
    List<Widget> fb = [];
    var goods = dir.listSync(); //yeah, dirty
    for(int i=0;i<goods.length;i++)
    {
      var travers = goods[i].path.split("/");
      if(fex != null && fex != "") {
        if (!travers.last.endsWith(".$fex")) {
          continue;
        }
      }
      fb.add(
        GestureDetector(
          child:Container(
              margin: EdgeInsets.symmetric(vertical:4.0),
              child:Row(children: [Text(travers.last, style:rowTextStyle)],
                mainAxisAlignment: MainAxisAlignment.center,),
          ),



          onTapUp: (details) {
            this.confirm(goods[i].path).then((bool ok) {
              if(ok)
              {
                chosenFilename = goods[i].path;
              }
            });


          },
        )

      );
    }
    return ListView(
      children: fb,
    );
  }
  
  Widget _buildDirectory(
      BuildContext context, AsyncSnapshot<Directory> snapshot) {
    Widget text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = new Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        docspath[0] = snapshot.data.path;
        text = _listing(snapshot.data);
      } else {
        text = const Text('path unavailable');
      }
    }
    return new Padding(padding: const EdgeInsets.all(16.0), child: text);
  }
  
  @override
  Widget build(BuildContext context) {
  
  return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new CupertinoTextField(onChanged: (newValue){
              chosenFilename = ("${docspath[0]}/$newValue").trim();
              if(fex != null && fex != "") {
                if (!newValue.endsWith(".$fex")) {
                  chosenFilename = "$chosenFilename.$fex";
                }
              }
            },
            placeholder: "Filename(.csv)"
            ),
            new Expanded(
              child: new FutureBuilder<Directory>(
                  future: _appDocumentsDirectory, builder: _buildDirectory),
            ),
            
          ],
        ),
      )
    ;
  
  }

  Future<bool> confirm(String path) async {
    //return await ConfirmDialog("Overwrite $path?")
    return true;
  }
}
