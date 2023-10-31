//
//  UIViewController.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit

extension UIViewController {
    
    func push(_ viewController: UIViewController){
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func pop(){
        self.navigationController?.popViewController(animated: false)
    }
}

