//
//  FlutterTaskListViewController.swift
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

class FlutterProjectListViewController: FlutterBaseViewController {
    
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
                
                weakSelf.beginTime = start.timeIntervalSince1970*1000;
                weakSelf.endTime = end.timeIntervalSince1970*1000;
                
                let headers:[String: String]? = NetworkManager.shared.headers ;
                let TaskLogURL = NetworkManager.TaskLogURL;
                let baseURL = NetworkManager.baseURL;
                let urlStr:String? = baseURL+TaskLogURL;
                let parameters : Dictionary?  = ["finish" : "false","offset" : 0, "limit" : 10,"beginTime" : weakSelf.beginTime,"endTime" : weakSelf.endTime] as [String : Any];
                
                if let urlStr = urlStr, let headers = headers,let parameters = parameters {
                    weakSelf.mEventSink?(["name":"showCalendar","beginTime" : weakSelf.beginTime,"endTime" : weakSelf.endTime] )
                    weakSelf.mEventSink?(["name":"getURL","urlStr":urlStr,"headers":headers,"params":parameters] )
                }
                
            }
            controller.modalPresentationStyle = .overFullScreen;
            self.present(controller, animated: false, completion: nil);
        }
    }
    
    
    //MARK: - flutter delegate
    //注册 messageChannel，用于接收flutter的数据
    override func setMessageChannel(channelName:String) -> Void {
        let messageChannel = FlutterMethodChannel.init(name: channelName, binaryMessenger:  self);
        messageChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if ("navBack" == call.method) {
                self.navigationController?.popViewController(animated: true);
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
        if str == "showCalendar"{
            
        }
        events("我来自native222")
        return nil
    }
    
}


