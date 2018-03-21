//
//  String+Extension.swift
//  LawChatForLawyer
//
//  Created by Juice on 2017/12/15.
//  Copyright © 2017年 就问律师. All rights reserved.
//

import Foundation

extension String {
  public  func lv_subString(startIndex start: UInt, endIndex: UInt) -> String? {
        
        let startIdx = start
        if startIdx > self.count - 1 {
            return nil
        }
        
        let end = start + endIndex
        if startIdx > end || end > self.count - 1 {
            return nil
        }
        
        let stringStartIndex = index(startIndex, offsetBy: Int(startIdx))
        let stringEndIndex = index(startIndex, offsetBy: Int(end))
        
        return String(self[stringStartIndex...stringEndIndex])
    }
}
