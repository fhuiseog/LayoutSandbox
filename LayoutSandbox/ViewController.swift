//
//  ViewController.swift
//  LayoutSandbox
//
//  Created by John Cromie on 20/01/2016.
//  Copyright © 2016 RGB. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private var webView: WKWebView!
    private var renderView: RenderView!
    
    private var button1, button2: UIButton!
    
    var loadingStartTime: CFAbsoluteTime = 0.0
    
    var scaleFactor: CGFloat = 0.75
    
    var startingWidth: CGFloat = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.grayColor()
        
        let contentController = WKUserContentController();
        let userScript = WKUserScript(
            source: "testMe()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.view.addSubview(self.webView)
        //self.webView.hidden = true
        
        self.renderView = RenderView()
        self.renderView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.renderView)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:"onPan:")
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
        
        self.button1 = UIButton(type: .Custom)
        self.button1.setTitle("Page 1", forState: .Normal)
        self.button1.addTarget(self, action:"didPressButton1:", forControlEvents:.TouchUpInside)
        self.view.addSubview(button1)
        
        self.button2 = UIButton(type: .Custom)
        self.button2.setTitle("Page 2", forState: .Normal)
        self.button2.addTarget(self, action:"didPressButton2:", forControlEvents:.TouchUpInside)
        self.view.addSubview(button2)

        self.webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)

    }
    
    deinit {
        removeObserver(self, forKeyPath: "loading")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        
        let viewWidth = self.view.bounds.size.width / 2.0 * scaleFactor
        let viewHeight = viewWidth * 1.5
        
        self.webView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)

        self.renderView.frame = CGRect(x: self.view.bounds.size.width / 2.0, y: 0, width: viewWidth, height: viewHeight)
                
        let buttonHeight: CGFloat = 30.0
        let buttonMargin: CGFloat = 20.0
        
        self.button1.frame = CGRect(x: buttonMargin,
            y: self.view.bounds.size.height - buttonHeight - buttonMargin,
            width: buttonHeight * 4,
            height: buttonHeight)
        
        self.button2.frame = CGRect(x: buttonMargin + self.button1.frame.size.width + buttonMargin,
            y: self.view.bounds.size.height - buttonHeight - buttonMargin,
            width: buttonHeight * 4,
            height: buttonHeight)
        
    }
    
    func didPressButton1(button: UIButton!)
    {
        if let urlpath = NSBundle.mainBundle().pathForResource("Ch03_00_Storyboard", ofType: "html", inDirectory: "Pages") {
            let url: NSURL = NSURL.fileURLWithPath(urlpath)
            webView.loadRequest(NSURLRequest(URL: url))
            self.loadingStartTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func didPressButton2(button: UIButton!)
    {
        if let urlpath = NSBundle.mainBundle().pathForResource("Ch03_00_04", ofType: "html", inDirectory: "Pages") {
            let url: NSURL = NSURL.fileURLWithPath(urlpath)
            webView.loadRequest(NSURLRequest(URL: url))
            self.loadingStartTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    func onPan(recognizer:UIPanGestureRecognizer) {
        
        let translation  = recognizer.translationInView(self.view)
        
        var r = self.webView.frame
        r.size.width = self.startingWidth
        r.size.width += translation.x
        r.size.width = min(self.view.bounds.size.width / 2.0, r.size.width)
        self.webView.frame = r
        
        r.origin.x = self.view.bounds.size.width / 2.0
        self.renderView.frame = r
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let webView = object as? WKWebView else { return }
        guard let keyPath = keyPath else { return }
        guard let change = change else { return }
        switch keyPath {
        case "loading":
            if let val = change[NSKeyValueChangeNewKey] as? Bool {
                if val {
                    print("Loading...")
                    
                } else {
                    let timeElapsed = CFAbsoluteTimeGetCurrent() - self.loadingStartTime
                    print("Loaded in: \(timeElapsed)s")
                    
                    print("zoomScale: \(self.webView.scrollView.zoomScale)")
                    
                    
                    //let script = "var element = document.getElementsByTagName(\"div\")[0]; var rect = element.getBoundingClientRect(); return element;"
                    
                    let script2 = "postLayoutPositions();"
                    
                    webView.evaluateJavaScript(script2) { (result, error) in
                        if error != nil {
                            print("\n \(result)")
                        }
                    }
                }
            }
        default:break
        }
    }

}

extension ViewController : WKScriptMessageHandler
{
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            
            let s = message.body
            
            let zoomScale = self.webView.scrollView.zoomScale
            
            print("\nzoomScale: \(self.webView.scrollView.zoomScale)")
            
            var rects: [CGRect] = [CGRect]()
            
            let lines = s.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            for line in lines {
                let components = line.characters.split(",").map(String.init)
                if components.count >= 5 {
                    
                    let x = CGFloat(Float(components[1]) ?? 0.0) * zoomScale
                    let y = CGFloat(Float(components[2]) ?? 0.0) * zoomScale
                    let w = CGFloat(Float(components[3]) ?? 0.0) * zoomScale
                    let h = CGFloat(Float(components[4]) ?? 0.0) * zoomScale
                    
                    let r = CGRect(x: x, y: y, width: w, height: h)
                    
                    //print("=> \(r.origin.x),\(r.origin.y),\(r.size.width),\(r.size.height)")
                    
                    rects.append(r)
                    
//                    if rects.count > 1 {
//                        break
//                    }
                }
            }
            
            if rects.count > 0 {
                self.renderView.frames = rects
                self.renderView.setNeedsDisplay()
            }

            
        }
    }
}

extension ViewController : UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let location  = gestureRecognizer.locationInView(self.view)
        
        let dragArea = CGRect(x: CGRectGetMaxX(self.webView.frame), y: 0.0, width: 30.0, height: self.webView.frame.size.height)
        
        self.startingWidth = self.webView.frame.size.width

        return CGRectContainsPoint(dragArea, location)
    }
}


