//
//  NGNavigationController.swift
//  NGSDK
//
//  Created by Paul on 2023/2/14.
//

import UIKit
import SnapKit

enum NGNvcMode {
    case normal
    case pay
}

class NGNavigationController: UINavigationController {
    
    private var mode = NGNvcMode.normal
    
    init(rootViewController: UIViewController, mode: NGNvcMode = .normal) {
        super.init(rootViewController: rootViewController)
        
        self.mode = mode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isHidden = true
        
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if mode == .normal {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation == .portrait || orientation == .portraitUpsideDown {
                view.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(background_horizontal)
                    make.right.equalToSuperview().offset(-background_horizontal)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(background_height)
                }
            } else {
                
                view.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.height.equalTo(background_height)
                    make.width.equalTo(background_width)
                }
            }
        } else if (mode == .pay){
            view.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(background_horizontal)
                make.right.equalToSuperview().offset(-background_horizontal)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }
        }
        
        view.layer.cornerRadius = 3
    }
    
    func presentByCurrentvc(){
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        NGTool.currentvc().present(self, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}


