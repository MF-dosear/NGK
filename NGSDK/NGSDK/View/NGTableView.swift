//
//  NGTableView.swift
//  NGSDK
//
//  Created by Paul on 2023/2/21.
//

import UIKit

class NGTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var list: [Member]?
    
    typealias NGTableResult = (_ params: Member?) -> Void
    var block:NGTableResult!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    func createUI(){
        
        delegate = self;
        dataSource = self;
        
        backgroundColor = UIColor(white: 1, alpha: 0.9)
        register(NGTableViewCell.classForCoder(), forCellReuseIdentifier: "NGTableViewCellID")
        
        list = Member.seleteds()
    }
    
    /// MARK： 代理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:NGTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NGTableViewCellID", for: indexPath) as! NGTableViewCell
        let member = list?[indexPath.row]
        cell.label.text = member?.username
        cell.btn.tag = 100 + indexPath.row
        cell.block = { [weak self] (index) in
            
            self?.deleted(index)
        }
        return cell
    }
    
    private func deleted(_ index: Int) {
        
        let member = list?[index - 100]
        let username = member?.username ?? ""
        let alert = UIAlertController(title: "温馨提示", message: "是否删除账号：\(username)", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "确定", style: .default) { action in
            
            member?.delete()
            
            self.list = Member.seleteds()
            self.reloadData()
        }
        let action2 = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        NGTool.currentvc().present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if block != nil {
            block(list?[indexPath.row])
        }
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}
