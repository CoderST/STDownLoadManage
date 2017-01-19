//
//  String+Extension.swift
//  Downlisten
//
//  Created by xiudou on 2017/1/18.
//  Copyright © 2017年 CoderST. All rights reserved.
//

import UIKit

extension String{

    // 字符串 -> MD5字符串
    func md5() -> String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        // 32位   CC_MD5_DIGEST_LENGTH -> 16位
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        // 作用: 把c语言的字符串 -> md5 c字符串
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
}
