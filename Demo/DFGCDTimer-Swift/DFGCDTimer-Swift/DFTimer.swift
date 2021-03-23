//
//  DFTimer.swift
//  DFGCDTimer-Swift
//
//  Created by raymond on 2021/3/23.
//

import Foundation
import UIKit

class DFTimer: NSObject {
    
    public enum DFTimerState {
        case register;
        case excuting;
        case pause;
        case cancel;
    }
    
    private var timer:DispatchSourceTimer?
    private var queue:DispatchQueue? = DispatchQueue.init(label: "com.DevilFinger.DFTimer")
    //DispatchQueue.global(qos: .default) //DispatchQueue.main
    private let after:Double
    private let repeats:Int
    private let interval:Double
    private let leeway:DispatchTimeInterval
    private var handler:((DFTimer) -> Void)?
    private var current = 0
    private var state:DFTimerState = .register
    public var identifier:String?
    
    
    public var observer:((DFTimer,DFTimerState) -> Void)?
    
    private var isAddObserver = false
    private var backgroundTask:UIBackgroundTaskIdentifier! = nil
    private var _isBackgroundMode = false
    public var isBackgroundMode:Bool{
        get{
            return _isBackgroundMode
        }
        set{
            
            let oldValue = _isBackgroundMode
            _isBackgroundMode = newValue
            if oldValue != newValue{
                
                if newValue{
                    _addEnterBackgroundObserver()
                }else{
                    _removeEnterBackgroundObserver()
                }
            }
            
        }
    }
    
    public class func once(after:Double, handler:((DFTimer) -> Void)?) -> Self{
        
        return self.init(queue: nil, after: after, repeats: 0, interval: .infinity, leeway: .nanoseconds(0), handler: handler)
    }
    
    public class func once(queue:DispatchQueue?,after:Double, handler:((DFTimer) -> Void)?) -> Self{
        
        return self.init(queue: queue, after: after, repeats: 0, interval: .infinity, leeway: .nanoseconds(0), handler: handler)
    }
    
    
    public class func every(interval:Double,handler: ((DFTimer) -> Void)?) -> Self{
        return self.init(queue: nil, after: 0, repeats: 0, interval: interval, leeway: .nanoseconds(0), handler: handler)
    }
    
    public class func every(interval:Double, repeatTimes:Int, handler: ((DFTimer) -> Void)?) -> Self{
        return self.init(queue: nil, after: 0, repeats: repeatTimes, interval: interval, leeway: .nanoseconds(0), handler: handler)
    }
    
    public class func every(queue:DispatchQueue?,after:Double,interval:Double, repeatTimes:Int, handler: ((DFTimer) -> Void)?) -> Self{
        
        return self.init(queue: queue, after: after, repeats: repeatTimes, interval: interval, leeway: .nanoseconds(0), handler: handler)
        
    }
    
    
    required init(queue:DispatchQueue?, after:Double, repeats:Int, interval:Double,leeway:DispatchTimeInterval,handler:((DFTimer) -> Void)?){
        
        if queue != nil{
            self.queue = queue
        }
        
        self.after = after
        self.repeats = repeats
        self.interval = interval
        self.leeway = leeway
        self.handler = handler
        super.init()
        
        self.timer = _create()
    }
    
    private func _create() -> DispatchSourceTimer{
        
        let t = DispatchSource.makeTimerSource(flags: [], queue: queue)
        t.schedule(deadline: .now() + after, repeating: interval, leeway: leeway)
        
        let handler:(()->Void)? = { [weak self] in
            
            if let weakSelf = self{
                if let h = self?.handler{
                    h(weakSelf)
                }
                
                if weakSelf.repeats > 0 {
                    weakSelf.current += 1
                    if weakSelf.current == weakSelf.repeats{
                        weakSelf.current = 0
                        weakSelf.cancel()
                    }
                    
                }
                
            }
        }
        
        t.setEventHandler(handler: handler)
        self.state = .register
        return t
    }
    
    private func _release(){
        guard let t = timer else {
            return
        }
        t.setEventHandler(handler: nil)
        t.cancel()
        if t.isCancelled{
            self.timer = nil
        }
    }
    
    
    public func fire(){
        if let t = timer{
            if self.state == .register{
                t.resume()
            }
        }else{
            timer = _create()
            timer?.resume()
        }
        self.state = .excuting
        _observerCallBack()
    }
    
    public func pause() {
        _release()
        self.state = .pause
        _observerCallBack()
    }
    
    public func cancel() {
        _release()
        self.state = .cancel
        _observerCallBack()
    }
    
    
    private func _observerCallBack(){
        if let ob = observer{
            ob(self, state)
        }
        
    }
    
    
    @objc private func _didEnterBackground(notification:Notification){
        
        let application = UIApplication.shared
        if self.backgroundTask != nil {
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }

        self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
            () -> Void in
            //如果没有调用endBackgroundTask，时间耗尽时应用程序将被终止
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        })
    }
    
    
    private func _addEnterBackgroundObserver(){
        isAddObserver = true
        if #available(iOS 13.0, *) {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self._didEnterBackground(notification:)), name: UIScene.didEnterBackgroundNotification, object: nil)
        } else {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self._didEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    private func _removeEnterBackgroundObserver(){
        if isAddObserver{
            if #available(iOS 13.0, *) {
                NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            }
            isAddObserver = false
        }
    }
    
    
}
