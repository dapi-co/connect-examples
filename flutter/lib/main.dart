import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Webview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //create the url with query parameters
  String generateConnectInitializationUrl(){
    var baseUrl = "connect.dapi.co";
    var config = {
      "appKey": "c1606405091dc6f0f0b9ab34dec5f9c404042bcef7ceafa4c2527074947cb5d0",
      "environment": "sandbox",
      "redirectUri": "https://google.com",
      "isMobile" : "true",
      "isWebview": "true"
    };

    return Uri.https(baseUrl, '', config).toString();
    
  }


  // Parse the URL to determine if it's a special Connect redirect or a request
  // Handle connect redirects and open traditional pages directly in the user's
  // preferred browser.
  NavigationDecision myNavigationDelegate(NavigationRequest navigationRequest){
    var connectActionType = "dapiconnect";
    var uri = Uri.parse(navigationRequest.url);
    if(uri.scheme == connectActionType){
      var action = uri.host;
      var data = parsedUriData(uri);

      if(action == 'connected'){
        //TODO: Close webview after receiving the access_code and continue with app flow

        //Successfully linked the user bank. Now exchange this access_code with access_token
        //to fetch user related bank information.
        print("Access Code: ${data['access_code']}");

      } else if (action == 'exit'){

        //TODO: Close webview
      } else if (action == 'event') {

        // The event action is fired as the user moves through the Dapi Connect
        print("Event Name: ${data['event_name']}");

      } else if (action == 'error'){

        // The error action is fired wheneever an error happened
        // either wrong configuration params or wrong username/password
        print("Error Type: ${data['error_type']}");
        print("Error Message: ${data['error_message']}");
      }
      return NavigationDecision.prevent;
    } else if (uri.scheme == 'https' || uri.scheme == 'http'){
      return NavigationDecision.navigate;
    }

  }

  //parse query parameters into a Dictionary
  HashMap<String, String> parsedUriData(Uri uri){
    var data = HashMap<String, String>();
    for(var key in uri.queryParameters.keys){
      data[key] = uri.queryParameters[key];
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {

    // Generate the Connect initialization URL based off of the configuration options.
    String connectUrl = generateConnectInitializationUrl();
    
    print("Connection URl: ${connectUrl}");

    return Scaffold(
      body: WebView(
          key: UniqueKey(),
          initialUrl: connectUrl,
          javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: myNavigationDelegate,
      ),
    );
  }
}
