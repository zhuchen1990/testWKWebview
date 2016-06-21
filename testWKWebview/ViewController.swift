//
//  ViewController.swift
//  testWKWebview
//
//  Created by 朱晨 on 16/6/7.
//  Copyright © 2016年 朱晨. All rights reserved.
//

import UIKit
import WebKit
class ViewController: UIViewController {
    var scriptContent : String!
    var wkWebView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addCustomItem()
        
        
        
        let conf = WKWebViewConfiguration()
        conf.userContentController.addScriptMessageHandler(self, name: "MyInterface")
//        print(NSTemporaryDirectory())
        let projectPath = NSBundle.mainBundle().bundlePath
        print(projectPath)
        let path = projectPath.stringByAppendingString("/test.js")
        
        do{
        scriptContent = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        }catch(let  error){
            print(error)
        }

        let script = WKUserScript(source: scriptContent, injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
        conf.userContentController.addUserScript(script)
        wkWebView = WKWebView(frame: self.view.frame,configuration: conf)
        wkWebView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.baidu.com")!))
        self.view.addSubview(wkWebView)
        wkWebView.UIDelegate = self
        wkWebView.navigationDelegate = self
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.setToolbarHidden(false, animated: false)
        let backButton = UIBarButtonItem(title: "back", style: .Done, target: self, action: #selector(self.goBack(_:)))
        let forwardButton = UIBarButtonItem(title: "forward", style: .Done, target: self, action: #selector(self.goForward(_:)))
        self.toolbarItems = [backButton,forwardButton]

        self.navigationController?.toolbar.barStyle = .Black
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func addCustomItem() -> Void {
        let rightItem = UIBarButtonItem(title: "Mine", style: .Plain, target: self, action: #selector(self.skipToMine(_:)))
        self.navigationItem.rightBarButtonItem  = rightItem
    }
    
    func skipToMine(sender:UIBarButtonItem)  {
        let mineVC = MineTableViewController(style: .Grouped)
        self.navigationController?.pushViewController(mineVC, animated: true)
    }
    
    func goBack(sender : UIBarButtonItem){
        wkWebView.goBack()
    }
    func goForward(sender : UIBarButtonItem){
        wkWebView.goForward()
    }

}

extension ViewController : WKNavigationDelegate{

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.title = webView.title
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.Allow)
    }
    
    

}


extension ViewController : WKUIDelegate{
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let av = UIAlertController(title: "alert", message: message, preferredStyle: .Alert)
        let ac = UIAlertAction(title: "sure", style: .Default) { (action) in
            completionHandler()
        }
        av.addAction(ac)
        self.presentViewController(av, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        
        let av = UIAlertController(title: "confirm", message: message, preferredStyle: .Alert)
        let ac = UIAlertAction(title: "sure", style: .Default) { (action) in
            completionHandler(true)
        }
        let cancel = UIAlertAction(title: "cancel", style: .Cancel, handler: {(action) in
            completionHandler(false)
        })
        av.addAction(ac)
        av.addAction(cancel)
        self.presentViewController(av, animated: true, completion: nil)

    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let av = UIAlertController(title: "prompt", message: prompt, preferredStyle: .Alert)
        let ac = UIAlertAction(title: "sure", style: .Default) { (action) in
            let content = av.textFields?.first?.text
            completionHandler(content)
        }
        let cancel = UIAlertAction(title: "cancel", style: .Cancel, handler: {(action) in
            completionHandler(nil)
        })
        av.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = defaultText
        }
        
        av.addAction(ac)
        av.addAction(cancel)
        self.presentViewController(av, animated: true, completion: nil)
    }
}

private typealias wkScriptMessageHandler = ViewController

extension wkScriptMessageHandler : WKScriptMessageHandler{
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        print(message.name)
        print(message.body.description)
        if message.name == "MyInterface" {
            if let dic = message.body as? NSDictionary, className = dic["className"]?.description,
                functionName = dic["functionName"]?.description
            {
                if let cls = NSClassFromString((NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName")?.description)! + "." + className) as? NSObject.Type {
                    let obj = cls.init()
                    let functionSel = Selector(functionName)
                    if obj.respondsToSelector(functionSel) {
                        obj.performSelector(functionSel, withObject: dic["para"]?.description)
                    }else{
                        print("方法未找到")
                    }
                    
                }else{
                    print("类未找到")
                }
                
            }
        }
    }
}
