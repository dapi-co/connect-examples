//
//  ViewController.swift
//  ios-sample-webview
//
//  Created by dapi on 9/25/19.
//  Copyright © 2019 dapi. All rights reserved.
//

import UIKit
import WebKit

class ConnectController: UIViewController, WKNavigationDelegate {
    
     let dapiWebView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // load the connect url
        let linkUrl = generateConnectInitializationURL()
        let url = URL(string: linkUrl)
        let request = URLRequest(url: url!)

        dapiWebView.navigationDelegate = self
        dapiWebView.allowsBackForwardNavigationGestures = false

        dapiWebView.frame = view.frame
        dapiWebView.scrollView.bounces = false
        self.view.addSubview(dapiWebView)
        dapiWebView.load(request)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }


    // getUrlParams -> parse query parameters into a Dictionary
    func getUrlParams(url: URL) -> Dictionary<String, String> {
        var paramsDictionary = [String: String]()
        let queryItems = URLComponents(string: (url.absoluteString))?.queryItems
        queryItems?.forEach { paramsDictionary[$0.name] = $0.value }
        return paramsDictionary
    }

    // generateLinkInitializationURL -> create the url with query parameters
    func generateConnectInitializationURL() -> String {
        let config = [
            "appKey": "9768810699237332cdd9a4791d26f921790ffa72c44733675644580f556cd345",
            "environment": "sandbox",
            "redirectUri": "https://google.com",
            "isMobile": "true",
            "isWebview": "true",
        ]


        var components = URLComponents()
        components.scheme = "https"
        components.host = "connect.dapi.co"
        components.path = ""
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }
        return components.string!
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        
        let connectActionType = "dapiconnect";
        let actionScheme = navigationAction.request.url?.scheme;
        let actionType = navigationAction.request.url?.host;
        let queryParams = getUrlParams(url: navigationAction.request.url!)
        
        if (actionScheme == connectActionType) {
            switch actionType {
                
            case "connected"?:
               
                // Take this access_code and exchange it for an access_token
                print("Access Code: \(queryParams["access_code"])");
                _ = self.navigationController?.popViewController(animated: true)
                break
                
            case "exit"?:
                // Close the webview
                _ = self.navigationController?.popViewController(animated: true);
                break

            case "event"?:
                 // The event action is fired as the user moves through connect
                print("Event name: \(queryParams["event_name"])");
                break
            case "error"?:
                 // The error action is fired whenever an error occured in connect
                print("Error Type: \(queryParams["error_type"])");
                 print("Error Message: \(queryParams["error_message"])");
            default:
                print("Connect action detected: \(actionType)")
                break
            }

            decisionHandler(.cancel)
        } else if (navigationAction.navigationType == WKNavigationType.linkActivated &&
            (actionScheme == "http" || actionScheme == "https")) {
            // Handle http:// and https:// links inside of dapi,
            // and open them in a new Safari page. This is necessary for redirects
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        }
        else {
            print("Unrecognized URL scheme detected that is neither HTTP, HTTPS, or related to connect: \(navigationAction.request.url?.absoluteString)");
            decisionHandler(.allow)
        }
    }

}

