//
//  NGTableViewCell.swift
//  NGSDK
//
//  Created by Paul on 2023/2/21.
//

import UIKit

class NGTableViewCell: UITableViewCell {
    
    typealias NGTableResult = (_ index: Int) -> Void
    var block:NGTableResult!
    
    let btn = UIButton(type: .custom)
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "")
        
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI(){
        
        backgroundColor = .clear
        selectionStyle = .none
        
        let imgView = UIImageView(image: UIImage.image("icon_用户"))
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.width.height.equalTo(24)
            make.centerY.equalTo(contentView.snp.centerY);
        }
        
        btn.setImage(UIImage.image("icon_关闭"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.right.equalTo(-8)
            make.width.equalTo(32)
        }
        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        contentView.addSubview(label)
        let lf = 8
        label.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(lf)
            make.right.equalTo(btn.snp.left).offset(-lf)
            make.height.equalTo(21)
            make.centerY.equalToSuperview()
        }
        
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
    }
    
    // 其他手机号登录
    @objc private func btnAction(_ btn: UIButton){
        
        block(btn.tag)
    }
    
    
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}
