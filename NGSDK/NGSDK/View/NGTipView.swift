//
//  NGTipView.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit

class NGTipView: UIView {
    
    private let width: CGFloat = 50
    
    private let imgView = UIImageView()
    
    private var star: CGPoint = CGPointZero
    
    override init(frame: CGRect) {
        
        var x:CGFloat = 0
        if UIApplication.shared.statusBarOrientation == .landscapeRight {
            x = UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
            if x != 0 {
                x = x - 20
            }
        }
        super.init(frame: CGRectMake(x, 120, width, width))
        
        backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        
        imgView.frame = self.bounds
        imgView.image = UIImage.image("icon_logo")
        imgView.contentMode = .scaleAspectFit
        addSubview(imgView)
        
        layer.cornerRadius = width / 2
        layer.borderColor = UIColor.init(white: 1, alpha: 0.3).cgColor
        layer.borderWidth = 2
        
        /// 添加拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_ :)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
        
        /// 添加点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_ :)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 拖拽手势
    @objc func panAction(_ pan: UIPanGestureRecognizer){
        if pan.state == .began{
            pan.setTranslation(CGPointZero, in: self)
            star = pan.translation(in: self)
        } else if pan.state == .changed {
            
            let point = pan.translation(in: self)
            
            var dx:CGFloat = 0
            var dy:CGFloat = 0
            
            dx = point.x - star.x
            dy = point.y - star.y
            
            center = CGPoint(x: dx + center.x, y: dy + center.y)
            pan.setTranslation(CGPointZero, in: self)
            
        } else if pan.state == .ended {
            // 贴边效果
            keepBounds()
        }
    }
    
    /// 贴边效果
    private func keepBounds(){
        
        let sp:CGFloat = 10
        isUserInteractionEnabled = false
        
        let orientation = UIApplication.shared.statusBarOrientation
        let bounds = UIScreen.main.bounds
        
        var left:CGFloat = 0
        var right: CGFloat = 0
        
        if orientation == .landscapeRight {
            left = UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
            if left != 0 {
                left = left - sp
            }
        } else if orientation == .landscapeLeft {
            right = UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0
            if right != 0 {
                right = right - sp
            }
        }
        
        // y轴
        let center_x = bounds.width / 2
        var center_y:CGFloat = 0
        let radius = width / 2
        if center.y < radius {
            center_y = radius
        } else if center.y > bounds.height - radius {
            center_y = bounds.height - radius
        } else {
            center_y = center.y
        }
        
        // x轴
        if center.x < center_x {
            // 左
            UIView.animate(withDuration: 0.5) {
                let center_x = sp + left
                self.center = CGPoint(x: center_x, y: center_y)
            } completion: { flag in
                
                if flag {
                    self.isUserInteractionEnabled = true
                }
            }
        } else {
            // 右
            UIView.animate(withDuration: 0.5) {
                let center_x = bounds.width - sp - right
                self.center = CGPoint(x: center_x, y: center_y)
            } completion: { flag in
                if flag {
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    /// 点击手势
    @objc func tapAction(_ tap: UITapGestureRecognizer){
        let vc = NGItemsVC()
        vc.frame = self.frame
        NGTool.currentvc().present(vc, animated: true)
    }
    
    /// 展示
    func show(){
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}
