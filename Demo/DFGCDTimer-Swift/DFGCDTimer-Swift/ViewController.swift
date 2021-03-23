//
//  ViewController.swift
//  DFGCDTimer-Swift
//
//  Created by raymond on 2021/3/21.
//

import UIKit

func printXY(_ any:Any) {
    let date = Date()
     let timeFormatter = DateFormatter()
     timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
     let strNowTime = timeFormatter.string(from: date) as String
    print("\(strNowTime) \(any)")
}


class ViewController: UIViewController {

    
    var timerEx:DFTimer?
    
    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //单次定时器，延迟1秒执行
        self.timerEx = DFTimer.once(after: 1, handler: { (timer) in
            printXY("once \(timer)")
        })
        
        //单次定时器，在指定的队列中延迟1秒执行
        self.timerEx = DFTimer.once(queue: DispatchQueue.main, after: 1, handler: { (timer) in
            printXY("once \(timer)")
        })
        
        //循环定时器，间隔时间为2秒
        self.timerEx = DFTimer.every(interval: 2, handler: { (timer) in
            printXY("every \(timer)")
        })
        
        //循环定时器，间隔时间1秒，然后执行5次后自动销毁定时器
        self.timerEx = DFTimer.every(interval: 1, repeatTimes: 5, handler: { (timer) in
            printXY("every \(timer)")
        })
        
        //循环定时器，在主队列延迟1秒后执行，间隔时间为2秒，执行3次后自动销毁定时器
        self.timerEx = DFTimer.every(queue: DispatchQueue.main, after: 1, interval: 2, repeatTimes: 3, handler: { (timer) in
            printXY("every \(timer)")
        })
        
        //是否后台任务，开启后，就算APP退到后台，还是会继续执行任务
        self.timerEx?.isBackgroundMode = true
        
        //定时器状态监听。可以监听定时器当前的状态。如执行中、暂停、取消
        self.timerEx?.observer = {(timer:DFTimer, state:DFTimer.DFTimerState) -> Void in
            printXY("observer : \(timer) \(state)")
        }
        
        //开启或者恢复定时器
        self.timerEx?.fire()
        
        //暂停定时器
        self.timerEx?.pause()
        
        //取消定时器
        self.timerEx?.cancel()
    }

    @IBAction func pauseBtnDidClicked(_ sender: Any) {
        printXY("suspend")
        timerEx?.pause()
    }
    
    @IBAction func cancelBtnDidClicked(_ sender: Any) {
        printXY("cancel")
        timerEx?.cancel()
    }
    
    @IBAction func resumeBtnDidClicked(_ sender: Any) {
        printXY("resume")
        timerEx?.fire()
    }
    
    
}

