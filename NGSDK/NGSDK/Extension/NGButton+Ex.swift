//
//  UIButton.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit

extension UIButton {
    
    /// 倒计时
    func sendCode(_ time: Int, _ title: String, _ wait: String){
        
        var i = time
        isUserInteractionEnabled = false
        let queue = DispatchQueue.global()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(wallDeadline: DispatchWallTime.now(), repeating: .seconds(1), leeway: .milliseconds(0))
        timer.setEventHandler(handler: DispatchWorkItem(block: { [weak self] in
            
            if i <= 0 {
                timer.cancel()
                DispatchQueue.main.async {
                    self?.setTitle(title, for: .normal)
                    self?.isUserInteractionEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.setTitle("\(i)\(wait)", for: .normal)
                }
                i = i - 1
            }
        }))
        timer.resume()
    }
}
