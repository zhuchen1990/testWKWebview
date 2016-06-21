# MyTest
This is a project that test the ThirdPlatform  APIs

* WKWebView
* KingFisher
* Chart


##WKWebView
###引言
说到WKWebView，自我感觉的确很强大，不仅加载速度提升了，与js交互功能也越来强大了，这里就来写写自己在使用过程中的一些心得

###使用
使用过UIWebView的朋友对WkWebView的API应该也会比较熟悉，两者方法名很相似，苹果方面并没有改变太多，所以用起来也比较顺手,本人使用的是swift，下面代码也以swift为主。	
####初始化
```
let conf = WKWebViewConfiguration()
        wkWebView = WKWebView(frame: self.view.frame,configuration: conf)
        wkWebView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.baidu.com")!))
         wkWebView.UIDelegate = self
        wkWebView.navigationDelegate = self
        self.view.addSubview(wkWebView)
     
```
注意的有以下几点	
1. 这里设置了WKWebView两个重要的代理UIDelegate和navigationDelegate，前者处理网页上一些弹出框的显示样式，后者处理网页加载时的逻辑，页面导航等。	
2. WKWebView都有一个配置策略，WKWebViewConfiguration关系网页的js交互功能，后面将详细介绍

####UIDelegate
```

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
```
这几个方法不是必须实现的，如果实现了这些方法，表明网页如果调用一些弹出框的时候如：alert，confirm，prompt会以系统原生的样式进行显示。

####WKNavigationDelegate
1.开始加载页面内容时就会回调此代理方法，与UIWebView的didStartLoad功能相当。	

```
func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
```
2.加载完成的回调	

```
func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.title = webView.title
    }
```
3.如果我们需要处理在重定向时		

```
func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
  print(__FUNCTION__)
}
```
4.我们终止页面加载	

```
func webViewWebContentProcessDidTerminate(webView: WKWebView) {
    print(__FUNCTION__)
}
```
5.决定是否允许导航响应，如果不允许就不会跳转到该链接的页面。

	
```
func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
    print(__FUNCTION__)
    decisionHandler(.Allow)
}
```	

6.如果我们的请求要求授权、证书等，我们需要处理下面的代理方法，以提供相应的授权处理等		

```
func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    print(__FUNCTION__)
    completionHandler(.PerformDefaultHandling, nil)
}
```
####网页与原生之前交互功能
在webview的初始化方法的configuration中注入js交互对象，设置接口名称，和WKScriptMessageHandler的代理，这样就能实现网页和原生应用之间的交互功能

```
conf.userContentController.addScriptMessageHandler(self, name: "MyInterface")
```
####WKScriptMessageHandler 代理		
这里是实现响应事件的重要方法，交互逻辑主要通过该协议中方法实现。	
看看WKScriptMessageHandler，在js端通过window.webkit.messageHandlers.{InjectedName}.postMessage()方法来发送消息到native。我们需要遵守此协议，然后实现其代理方法，就可以收到消息，并做相应处理。postMessage()中可以传递字典类型的参数。

```
private typealias wkScriptMessageHandler = ViewController

extension wkScriptMessageHandler : WKScriptMessageHandler{
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        print(message.name)
        print(message.body.description)
        if message.name == "MyInterface" {
            //TODO:
    }
}

```
####网页加载前后可注入js代码用来改变网页布局或其他功能

```
let script = WKUserScript(source: scriptContent, injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
conf.userContentController.addUserScript(script)
```
* 可选择在网页加载前或加载后开始加载js代码

###缓存清理		
长时间使用网页，缓存数据肯定是会有的，所以清理网页缓存也是常用的方法，缓存分为两种MemoryCache和DiskCache，一种存在手机内存中，一种存在app的沙盒文件中，ios9前wk没有提供清理缓存的系统方法，所以只能进行手动清理，即找到目标文件夹删除，所以可以两种方式都要考虑到		


```
 func cleanCaches() -> Void {
        
        if #available(iOS 9.0, *) {
        ／／ios9.0之后清理缓存方法很简单
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{})
        }else{
            //清理DiskCache,至于文件夹位置，可以去沙盒亲自看看    
            if let docPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first{
                if let bundleId = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as? String{
      		 let webkitFolderInCaches = docPath + "/Caches/" + bundleId + "/Webkit"
                    do{       
                        try NSFileManager.defaultManager().removeItemAtPath(webkitFolderInCaches)
                        
                    }catch(let error){
                        
                        print(error)
                    }	
                    
		//清理memoryCache  	
		 NSURLCache.sharedURLCache().removeAllCachedResponses()
                }
            }
        }
        	
    }

```

####计算网页diskCache的大小方法		
```
extension String{
    func caculateFileSize() -> UInt64 {
        var size : UInt64 = 0
        let manager = NSFileManager.defaultManager()
        let exist = manager.fileExistsAtPath(self)
        
        guard exist else{
            return size
        }
        //遍历该文件夹下所有文件包括子文件夹名称
        if let enumerater = manager.enumeratorAtPath(self){
            for subPath in enumerater {
                let fullPath = self + "/" + (subPath as! String)		
                //判断文件是否为文件还是文件夹 false为文件，true为文件夹
                var isDoc : ObjCBool = false
                if manager.fileExistsAtPath(fullPath, isDirectory: &isDoc) {
                    if !isDoc {
                        do{
                            if let attr : NSDictionary = try manager.attributesOfItemAtPath(fullPath) {
                                size += attr.fileSize()
                            }
                            
                        }catch(let error){
                            print(error)
                        }
                    }
                }
                
            }
        }
        return size / (1024 * 1024)
    }
}
```
我是给string加了一个扩展方法，找到缓存文件夹路径之后通过该方法返回size，至于NSFileManager的操作我也是借鉴了别人[精心整理的方法][id]，建议大家也可以去看看。		
[id]:http://www.hangge.com/blog/cache/detail_527.html


###先写到这吧，后面再更新....

