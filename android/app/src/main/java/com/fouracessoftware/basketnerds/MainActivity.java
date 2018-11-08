package com.fouracessoftware.basketnerds;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.fouracessoftware.basketnerds/filesys";
  private static final int READ_REQUEST_CODE = 42;
  private static MethodChannel.Result shippable;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                String tosend = "";
                shippable = null;
                int calledAction = -1;
                if(call.method.contentEquals("getExternalDir")) {
                  try {
                    tosend = getExternalDir();
                    result.success(tosend);
                  } catch (Exception e) {
                    result.error("FAILED", e.getMessage(), null);
                    calledAction = 0;
                  }
                }
                if(call.method.contentEquals("getFileToOpen"))
                {

                  calledAction = 1; //assumes whatever File Picker exists to be asynchronous
                  shippable = result;
                  performFileSearch();
                }
                if(calledAction == -1)
                {
                  result.notImplemented();
                }
              }
            });

    /*
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            object : MethodCallHandler {
      override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        var tosend:String = ""
        if(call.method.equals("getExternalDir"))
        {
          try {
            tosend = getExternalDir()
            result.success(tosend)
          }
          catch(e:Exception) {
          tosend = "(no data)"
          if (e.message != null){
            tosend = e.message as String
          }

          result.error("FAILED",tosend,null)
        }

        }
        else
        {
          result.notImplemented()
        }
      }
    });
    */
  }

/*
  private fun getExternalDir(): String {
    val filesilly = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
    val rv:String = filesilly.absolutePath
    return rv
  }
  */
private String getExternalDir() {
  File filesilly = Environment.getExternalStoragePublicDirectory("My Documents");
  return filesilly.getAbsolutePath();
}


  /**
   * Fires an intent to spin up the "file chooser" UI and select an image.
   */
  public void performFileSearch() {

    // ACTION_OPEN_DOCUMENT is the intent to choose a file via the system's file
    // browser.
    Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);

    // Filter to only show results that can be "opened", such as a
    // file (as opposed to a list of contacts or timezones)
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    // Filter to show only images, using the image MIME data type.
    // If one wanted to search for ogg vorbis files, the type would be "audio/ogg".
    // To search for all documents available via installed storage providers,
    // it would be "*/*".
    //intent.setType("text/comma-separated-values");
    //cheater's move
    intent.setType(MimeTypeMap.getSingleton().getMimeTypeFromExtension("csv"));

    startActivityForResult(intent, READ_REQUEST_CODE);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode,
                               Intent resultData) {

    // The ACTION_OPEN_DOCUMENT intent was sent with the request code
    // READ_REQUEST_CODE. If the request code seen here doesn't match, it's the
    // response to some other intent, and the code below shouldn't run at all.

    if (requestCode == READ_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
      // The document selected by the user won't be returned in the intent.
      // Instead, a URI to that document will be contained in the return intent
      // provided to this method as a parameter.
      // Pull that URI using resultData.getData().
      Uri uri = null;
      if (resultData != null) {
        uri = resultData.getData();
        if(shippable != null)
        {
          String aha = getUriRealPath(this,uri);
          aha = aha.replace(" .csv",".csv");
          shippable.success(aha);
        }
      }
      return;
    }

    shippable.success(null); //user cancelled
  }

  private String getUriRealPath(Context ctx, Uri uri)
  {
    String ret = "";

    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
    {
      // Android OS above sdk version 19.
      ret = getUriRealPathAboveKitkat(ctx, uri);
    }else
    {
      // Android OS below sdk version 19
      ret = getImageRealPath(getContentResolver(), uri, null);
    }

    return ret;
  }

  private String getUriRealPathAboveKitkat(Context ctx, Uri uri)
  {
    String ret = "";

    if(ctx != null && uri != null) {
        if(isDocumentUri(ctx, uri)){

        // Get uri related document id.
        String documentId = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
          documentId = DocumentsContract.getDocumentId(uri);
        }

        // Get uri authority.
        String uriAuthority = uri.getAuthority();

        if(isExternalStoreDoc(uriAuthority))
        {
          String idArr[] = documentId.split(":");
          if(idArr.length == 2)
          {
            String type = idArr[0];
            String realDocId = idArr[1];

            if("primary".equalsIgnoreCase(type))
            {
              ret = Environment.getExternalStorageDirectory() + "/" + realDocId;
            }
          }
        }

        if(isDownloadDoc(uriAuthority))
        {
          // Build download uri.
          Uri downloadUri = Uri.parse("content://downloads/public_downloads");

          // Append download document id at uri end.
          Uri downloadUriAppendId = ContentUris.withAppendedId(downloadUri, Long.valueOf(documentId));

          ret = getImageRealPath(getContentResolver(), downloadUriAppendId, null);

        }



        }
        if(ret == null)
        {
          if(isContentUri(uri))
          {
            ret = getImageRealPath(getContentResolver(), uri, null);

          }else if(isFileUri(uri)) {
            ret = uri.getPath();
          }

        }
    }

    return ret;
  }

  /* Check whether this uri represent a document or not. */
  private boolean isDocumentUri(Context ctx, Uri uri)
  {
    boolean ret = false;
    if(ctx != null && uri != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        ret = DocumentsContract.isDocumentUri(ctx, uri);
      }
    }
    return ret;
  }


  private boolean isFileUri(Uri uri)
  {
    boolean ret = false;
    if(uri != null) {
      String uriSchema = uri.getScheme();
      if("file".equalsIgnoreCase(uriSchema))
      {
        ret = true;
      }
    }
    return ret;
  }

  /* Check whether this document is provided by DownloadsProvider. */
  private boolean isDownloadDoc(String uriAuthority)
  {
    boolean ret = false;

    if("com.android.providers.downloads.documents".equals(uriAuthority))
    {
      ret = true;
    }

    return ret;
  }


  private boolean isContentUri(Uri uri)
  {
    boolean ret = false;
    if(uri != null) {
      String uriSchema = uri.getScheme();
      if("content".equalsIgnoreCase(uriSchema))
      {
        ret = true;
      }
    }
    return ret;
  }

  /* Check whether this document is provided by ExternalStorageProvider. */
  private boolean isExternalStoreDoc(String uriAuthority)
  {
    boolean ret = false;

    if("com.android.externalstorage.documents".equals(uriAuthority))
    {
      ret = true;
    }

    return ret;
  }

  /* Return uri represented document file real local path.*/
  private String getImageRealPath(ContentResolver contentResolver, Uri uri, String whereClause)
  {
    String ret = "";

    // Query the uri with condition.
    Cursor cursor = contentResolver.query(uri, null, whereClause, null, null);

    if(cursor!=null)
    {
      boolean moveToFirst = cursor.moveToFirst();
      if(moveToFirst)
      {

        // Get columns name by uri type.
        String columnName = MediaStore.Images.Media.DATA;

        if( uri==MediaStore.Images.Media.EXTERNAL_CONTENT_URI )
        {
          columnName = MediaStore.Images.Media.DATA;
        }else if( uri==MediaStore.Audio.Media.EXTERNAL_CONTENT_URI )
        {
          columnName = MediaStore.Audio.Media.DATA;
        }else if( uri==MediaStore.Video.Media.EXTERNAL_CONTENT_URI )
        {
          columnName = MediaStore.Video.Media.DATA;
        }

        // Get column index.
        int imageColumnIndex = cursor.getColumnIndex(columnName);

        // Get column value which is the uri related file local path.
        ret = cursor.getString(imageColumnIndex);
      }
    }

    return ret;
  }
}
