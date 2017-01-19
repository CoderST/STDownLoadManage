//
//  STDownLoaderManage.swift
//  Downlisten
//
//  Created by xiudou on 2017/1/18.
//  Copyright © 2017年 CoderST. All rights reserved.
//  下载器管理者

import UIKit

class STDownLoaderManage: NSObject {

    // 创建单粒
    static let shareInstance = STDownLoaderManage()
    
    /// 所有下载器
    fileprivate lazy var downLoaderInfor : [String : STDownLoader] = [String : STDownLoader]()
}

// MARK:- 对外接口
extension STDownLoaderManage {
    func downLoader(url : URL, downLoadTotalSizeBlock : @escaping DownLoadTotalSizeBlock, progress : @escaping ProgressBlock, successFile : @escaping SuccessFilePathBlock, failed : @escaping FailedBlock){
        // 1 uil -> MD5
        let md5 = url.absoluteString.md5()
        // 2 根据MD5查找
         var downLoad = downLoaderInfor[md5]
        // 3 如果没有找到下载器
        if downLoad == nil {
            downLoad = STDownLoader()
            downLoaderInfor[md5] = downLoad!
        }
        
        
        downLoad!.downLoader(url: url, downLoadTotalSize: downLoadTotalSizeBlock, progress: progress, successFilePath: { (successFilePath) in
            // 下载成功
            // 1 删除下载器
            self.downLoaderInfor.removeValue(forKey: md5)
            // 2 回调成功信息
            successFile(successFilePath)
        }, failed: failed)
    }
    
    // 暂停下载
    func pauseWithURL(url : URL){
        let md5 = url.absoluteString.md5()
        let downLoad = downLoaderInfor[md5]
        downLoad?.pauseCurrentTask()
    }
    
    // 继续下载
    func resumeWithURL(url : URL){
        let md5 = url.absoluteString.md5()
        let downLoad = downLoaderInfor[md5]
        downLoad?.resumeCurrentTask()
    }
    
    // 取消下载
    func cancelWithURL(url : URL){
        let md5 = url.absoluteString.md5()
        let downLoad = downLoaderInfor[md5]
        downLoad?.cancelCurrentTask()
    }
    
    // 暂停所有
    func pauseAllDownLoad(){
        let values = [STDownLoader](downLoaderInfor.values)
        for downLoad in values {
            downLoad.pauseCurrentTask()
        }
    }
    
    // 全部开始
    func startAllDownLoad(){
        let values = [STDownLoader](downLoaderInfor.values)
        for downLoad in values {
            downLoad.resumeCurrentTask()
        }

    }
}
