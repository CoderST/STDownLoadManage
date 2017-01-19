//
//  STFileTool.swift
//  Downlisten
//
//  Created by xiudou on 2017/1/13.
//  Copyright © 2017年 CoderST. All rights reserved.
//  文件管理

import UIKit
import Foundation
class STFileTool: NSObject {
    /// 获取缓存路径
    class func getFileCachePath(url : URL)->String {
        let fileName = url.lastPathComponent
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as NSString
        let cacehStringPath = cachePath.appendingPathComponent(fileName)
        return cacehStringPath
    }
    /// 获取临时路径
    class func getFileTempPath(url : URL)->String {
        let tempPath = NSTemporaryDirectory() as NSString
        let fileName = url.lastPathComponent
        let tempStringPath = tempPath.appendingPathComponent(fileName)
        return tempStringPath
    }
    /// 文件是否存在
    class func fiexFile(path : String?) ->Bool{
        guard let savePath = path else { return false}
        
        return FileManager.default.fileExists(atPath: savePath)
        
    }
    /// 根据路径获得文件大小
    class func getFileSizeWithPath(_ filePath : String?)-> Int{
        guard let filePath = filePath else { return 0 }
        guard FileManager.default.fileExists(atPath: filePath) == true else { return 0 }
        do {
           let fileDict = try FileManager.default.attributesOfItem(atPath: filePath)
            /*
             [__C.FileAttributeKey(_rawValue: NSFileType): NSFileTypeDirectory, __C.FileAttributeKey(_rawValue: NSFilePosixPermissions): 493, __C.FileAttributeKey(_rawValue: NSFileSystemNumber): 16777220, __C.FileAttributeKey(_rawValue: NSFileReferenceCount): 4, __C.FileAttributeKey(_rawValue: NSFileGroupOwnerAccountName): staff, __C.FileAttributeKey(_rawValue: NSFileSystemFileNumber): 70769606, __C.FileAttributeKey(_rawValue: NSFileGroupOwnerAccountID): 20, __C.FileAttributeKey(_rawValue: NSFileModificationDate): 2017-01-10 12:19:58 +0000, __C.FileAttributeKey(_rawValue: NSFileCreationDate): 2017-01-10 05:53:31 +0000, __C.FileAttributeKey(_rawValue: NSFileSize): 136, __C.FileAttributeKey(_rawValue: NSFileExtensionHidden): 0, __C.FileAttributeKey(_rawValue: NSFileOwnerAccountID): 503]
             */
            guard let fileSize = fileDict[FileAttributeKey.size] as? Int else { return 0 }
            return fileSize
        } catch  {
            print(error)
            return 0
        }
    }
    /// 移动文件
    class func moveFile(fromPath : String, toPath : String){
        
        guard getFileSizeWithPath(fromPath) > 0 else { return }
        do {
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
        } catch  {
            print("移动文件失败",error)
        }
    }
    /// 删除文件
    class func removeFileAtPath(filePath : String?){
        guard let filePath = filePath else {
            print("路径不存在")
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
            print("删除成功")
        } catch  {
            print("删除失败")
        }
    }
}
