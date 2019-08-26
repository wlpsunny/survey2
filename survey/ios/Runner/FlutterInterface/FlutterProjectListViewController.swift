//
//  FlutterProjectListViewController.swift
//  Runner
//
//  Created by sensoro on 2019/7/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import UIKit
import Foundation
import CityBase
import UIComponents
import Flutter


var documentInteractoinController : UIDocumentInteractionController!
class FlutterProjectListViewController: FlutterBaseViewController,UIDocumentInteractionControllerDelegate {
    
    var eventSink: FlutterEventSink?;
    var beginTime          : TimeInterval = 0.0
    var endTime            : TimeInterval = 0.0
    var dateTime           : String = ""
    var pageModel : FlutterPageModel? = nil;
    
    var dataList = [NSDictionary]();
    
    func setModel(model:FlutterPageModel){
        setInitialRoute(model.routeName)
        pageModel = model
        //        self.loadContent(isComplete: self.isComplete, isHeader: true ,isShowLoading: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let time: TimeInterval = 1.0
        
        setMessageChannel(channelName:pageModel!.methodChannel);
        setEventChannel(channelName: pageModel!.eventChannel);
        
        //把数据发给flutter
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.loadLocalProjectList();
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(openFileAndSave), name: NSNotification.Name(rawValue:"flutter_open_file"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func  viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏首页的导航栏 true 有动画
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    var islightContent = false {
        
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if !islightContent {
            return UIStatusBarStyle.default
        }
        return UIStatusBarStyle.default
    }
    
    //读取本地flutter数据
    func loadLocalProjectList() -> Void{
        let userDefaults = UserDefaults.standard;
        if let str = userDefaults.object(forKey: "projectListStr") {
            self.mEventSink?(["name":"sendProjectList","projectListStr":str] )
        }
    }
    
    func showCalendar() -> Void{
        if let controller = FlutterComponentManager.getController(controllerID: "calendar") as? CalendarViewController {
            if self.beginTime != 0 && self.endTime != 0 {
                controller.firstDate = Date(timeIntervalSince1970: self.beginTime);
                controller.endDate = Date(timeIntervalSince1970: self.endTime);
            }
            
            controller.completion = { [weak self] (start,end) in
                guard let weakSelf = self else {return;}
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                //                weakSelf.dateTime.text = formatter.string(from: start) + " ~ " + formatter.string(from: end);
                
                weakSelf.beginTime = start.timeIntervalSince1970;
                weakSelf.endTime = end.timeIntervalSince1970;
                
                var beginTime = start.timeIntervalSince1970*1000
                var endTime = end.timeIntervalSince1970*1000;
                
                let headers:[String: String]? = NetworkManager.shared.headers ;
                let TaskLogURL = NetworkManager.TaskLogURL;
                let baseURL = NetworkManager.baseURL;
                let urlStr:String? = baseURL+TaskLogURL;
                let parameters : Dictionary?  = ["finish" : "false","offset" : 0, "limit" : 10,"beginTime" :  beginTime,"endTime" :  endTime] as [String : Any];
                
                if let urlStr = urlStr, let headers = headers,let parameters = parameters {
                    weakSelf.mEventSink?(["name":"showCalendar","beginTime" :  beginTime,"endTime" :  endTime] )
                    weakSelf.mEventSink?(["name":"getURL","urlStr":urlStr,"headers":headers,"params":parameters] )
                }
                
            }
            controller.modalPresentationStyle = .overFullScreen;
            self.present(controller, animated: false, completion: nil);
        }
    }
    
    @objc func openFileAndSave(nofi : Notification){
        let urlstr = nofi.userInfo!["url"] as! NSString;
        var url : NSURL? = NSURL(string: urlstr as String);
        var data : Data?
        do{
            data = try Data(contentsOf: url as! URL);
            if let newStr = String(data: data!, encoding: String.Encoding.utf8){
                let str = newStr.replacingOccurrences(of: ",", with: ",");
                //外部打开的文件做本地存储
                let userDefaults = UserDefaults.standard;
                userDefaults.set(str, forKey: "projectList")
                //把数据发给flutter
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.mEventSink?(["name":"sendProjectList","projectListStr":str] )
                    //code
                    print("1 秒后输出")
                }
                
                
                //写入userdefault
            }
        }catch{
            return;
        }
    }
    
//    func openFileAndSave(url:NSURL) -> Void{
    
//        let dataFile:NSString = url.strin
//
//        NSString *dataFile = [NSString stringWithContentsOfURL:[NSURL URLWithString:filePath] encoding:NSUTF8StringEncoding error:nil];
//        NSArray *dataarr = [dataFile componentsSeparatedByString:@";"];
//        if(dataarr.count>0){
//            NSString *str = dataarr[0];
//            str = [str stringByReplacingOccurrencesOfString:@"," withString:@";"];
//            [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"histroySurveysiteProjectname"];
//
//        }
        
        
//    }
    
    
    //MARK: - flutter delegate
    //注册 messageChannel，用于接收flutter的数据
    override func setMessageChannel(channelName:String) -> Void {
        let messageChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger:  self);
        messageChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if ("navBack" == call.method) {
                self.navigationController?.popViewController(animated: true);
            }
            else if ("showCalendar" == call.method) {
                if let arguments:NSDictionary = call.arguments as! NSDictionary{
                    self.beginTime = arguments["beginTime"] as! TimeInterval;
                    self.endTime = arguments["endTime"] as! TimeInterval;
                }
                self.showCalendar();
            }
                
            else if ("outputDocument" == call.method) {
                if let arguments:NSDictionary = call.arguments as! NSDictionary{
                    
                    if  let json = arguments["json"] as? NSDictionary{
                        let VC:DocumentManagerViewController = DocumentManagerViewController.init();
                        VC.outputTxt( (json as NSDictionary) as! [AnyHashable : Any] );
                    }
                }
//                self.showCalendar();
            }
            else {
                result(FlutterMethodNotImplemented);
            }
        });
    }
    
    //setEventChannel 后需要重写该方法来向flutter发送消息
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mEventSink = events
        let str:String = arguments as! String
        if str == "getList"{
            
        }
        
        if str == "getList"{
            
        }
        
        events("我来自native222")
        return nil
    }
    
    
    func openDocumentInteractionController(fileURL : URL) {
        let url = Bundle.main.url(forResource: "SNSBack", withExtension: "png")
        
        documentInteractoinController = UIDocumentInteractionController.init(url: fileURL)
        documentInteractoinController.delegate = self
        let didShow : Bool = documentInteractoinController.presentOptionsMenu(from: self.view.bounds,
                                                                              in: self.view,
                                                                              animated: true)
        
        if didShow {
            
            print("SUCCESS")
            
        } else {
            print("NO APPS")
        }
        
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        
    }
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    public func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    public func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}



