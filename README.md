# DFTimer-Swift

DFTimer is based upon GCD - Grand Central Dispatch. It is small lightweight alternative to NSTimer with Swift.

## Requirements
This component requires iOS 8.0+.

## Installation
Copy the file `DFTimer.swift` to your project

## Usage
create a no repeat Timer use `.once`, just as the follow

### Create No Repeat Timer
```
//create a timer which fires a single time after 1 seconds.
self.timerEx = DFTimer.once(after: 1, handler: { (timer) in
    printXY("once \(timer)")
 })
        
//create a timer in specify queue which fires a single time after 1 seconds.
self.timerEx = DFTimer.once(queue: DispatchQueue.main, after: 1, handler: { (timer) in
   printXY("once \(timer)")
})
```

### Create Repeat Timer
```       
// create a Repeat timer which fires every 2 seconds
self.timerEx = DFTimer.every(interval: 2, handler: { (timer) in
    printXY("every \(timer)")
 })
 
 //create a Repeat timer which fires every 1 seconds. 
 //it will auto stop when fire 5 times
self.timerEx = DFTimer.every(interval: 1, repeatTimes: 5, handler: { (timer) in
     printXY("every \(timer)")
})

// create a Repeat timer in specify queue. it will begin after 1 second . 
// and then fire every 2 seconds and repeat 3 times.
self.timerEx = DFTimer.every(queue: DispatchQueue.main, after: 1, interval: 2, repeatTimes: 3, handler: { (timer) in
    printXY("every \(timer)")
 })
 
 ```
 ### Others
 
 ```
 //Whether it is a background task, after it is turned on, even if the APP exits to the background, the task will continue to be executed
 self.timerEx?.isBackgroundMode = true
 
 //Timer status monitoring. You can monitor the current status of the timer. Such as execution, suspension, cancellation
self.timerEx?.observer = {(timer:DFTimer, state:DFTimer.DFTimerState) -> Void in
  printXY("observer : \(timer) \(state)")
}

//Start or resume the timer
self.timerEx?.fire()
        
//Pause the timer
self.timerEx?.pause()
        
//Cancel timer
self.timerEx?.cancel()

 ```

 

