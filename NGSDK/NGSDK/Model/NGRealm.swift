//
//  NGRealm.swift
//  NGSDK
//
//  Created by Paul on 2023/2/22.
//

import Foundation

class Member{
    
    var username: String?
    var password: String?
    
    static private let key_member_list_cache = "key_member_list_cache"
    
    init(username: String? = nil, password: String? = nil) {
        self.username = username
        self.password = password
    }
    
    func insert(){
        
        let params = [
            "username" : self.username ?? "",
            "password" : self.password ?? ""
        ]
        
        guard var list:[[String:String]] = UserDefaults.standard.object(forKey: Member.key_member_list_cache) as? [[String:String]] else {
            
            // 存储
            let list_cache = [params]
            UserDefaults.standard.set(list_cache, forKey: Member.key_member_list_cache)
            UserDefaults.standard.synchronize()
            return
        }
        
        list.removeAll { dict in
            return self.username == dict["username"]
        }
        
        list.insert(params, at: 0)
        
        UserDefaults.standard.set(list, forKey: Member.key_member_list_cache)
        UserDefaults.standard.synchronize()
    }
    
    func delete(){
        
        guard var list:[[String:String]] = UserDefaults.standard.object(forKey: Member.key_member_list_cache) as? [[String:String]] else {
            
            return
        }
        
        list.removeAll { dict in
            return self.username == dict["username"]
        }
        
        UserDefaults.standard.set(list, forKey: Member.key_member_list_cache)
        UserDefaults.standard.synchronize()
    }

    class func first() -> Member?{
        
        guard let list:[[String:String]] = UserDefaults.standard.object(forKey: Member.key_member_list_cache) as? [[String:String]] else {
            
            return nil
        }
        
        let dict = list.first!
        return Member(username: dict["username"], password: dict["password"])
    }
    
    class func seleteds() -> [Member]?{
        
        guard let list:[[String:String]] = UserDefaults.standard.object(forKey: Member.key_member_list_cache) as? [[String:String]] else {
            
            return nil
        }
        return list.map { dict in
            return Member(username: dict["username"], password: dict["password"])
        }
    }
    
    class func seleted(_ username: String) -> Member?{
        guard let list:[[String:String]] = UserDefaults.standard.object(forKey: Member.key_member_list_cache) as? [[String:String]] else {
            
            return nil
        }
        
        let params = list.first { dict in
            return dict["username"] == username
        }
        return Member(username: params?["username"], password: params?["password"])
    }
}
