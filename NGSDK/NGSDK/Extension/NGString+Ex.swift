//
//  String.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import Foundation

extension String {
    
    func isNumber() -> Bool{
        let scan = Scanner(string: self)
        var val = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    mutating func encode_url() -> String{
        
//        var output = ""
//        for index in self.indices {
//            let thisChar = self[index]
//            if thisChar == " " {
//                output.append("+")
//            } else if thisChar == "." || thisChar == "-" || thisChar == "_" || thisChar == "~" ||
//                        (thisChar >= "a" && thisChar <= "z") ||
//                        (thisChar >= "A" && thisChar <= "Z") ||
//                        (thisChar >= "0" && thisChar <= "9"){
//                output = output + "\(thisChar)"
//            } else {
//                output = output + ("\(thisChar)".addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? "") //afURLQueryAllowed
//            }
//        }
        let text = self.replacingOccurrences(of: " ", with: "+")
        let custom = CharacterSet(charactersIn: "!*'();:@&=$,/?%#[]").inverted //!*'();:@&=$,/?%#[]
        let output = text.addingPercentEncoding(withAllowedCharacters: custom) ?? ""
        return output
    }
    
    func encode() -> String{
        let set = NSCharacterSet(charactersIn: "!*'\"();:@&=+$,/?%#[]% ").inverted
        guard let text = self.addingPercentEncoding(withAllowedCharacters: set) else { return "" }
        return text
    }
    
    func dictionaryValue() -> [String: Any]?{
        let dict = try? JSONSerialization.jsonObject(with: self.data(using: .utf8) ?? Data(), options: .fragmentsAllowed)
        return dict as? [String : Any]
    }
}

