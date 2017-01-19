//
//  STDownLoader.swift
//  Downlisten
//
//  Created by xiudou on 2017/1/13.
//  Copyright © 2017年 CoderST. All rights reserved.
//  下载器
//  OC typedef void (^ZWProgressHUDCompletionBlock)();  => SWIFT typealias ZWProgressHUDCompletionBlock=()->Void

import UIKit
enum downLoadStatus {
    case Pause      // 暂停
    case Loading    // 下载中
    case Success    // 成功
    case Failed     // 失败
}

typealias DownLoadTotalSizeBlock = (_ totalSize : Int)->Void
typealias ProgressBlock = (_ progress : Float)->Void
typealias SuccessFilePathBlock = (_ filePath : String)->Void
typealias FailedBlock = ()->()
typealias StateChangeBlock = (_ state : downLoadStatus)->Void

class STDownLoader: NSObject {

    
    // MARK:- 变量
    /// temp路径文件的大小
    fileprivate var tempFileSize : Int = 0
    /// 文件总大小
    fileprivate var totleFileSize : Int = 0
    /// 当前任务
    fileprivate var dataTask : URLSessionDataTask?
    /// 下载完的路径
    fileprivate var downLoadedPath : String = ""
    /// 正在下载的路径
    fileprivate var downLoadingPath : String = ""
    /// 输出OutputStream
    fileprivate var currentStream  : OutputStream?
    /// 下载总大小
    var downLoadTotalSizeBlock : DownLoadTotalSizeBlock?
    /// 下载进度
    var progressBlock : ProgressBlock?
    /// 下载成功路径
    var successFilePathBlock : SuccessFilePathBlock?
    /// 下载失败
    var failedBlock : FailedBlock?
    /// 状态改变
    var stateChangeBlock : StateChangeBlock?
    
    /// 状态
    var state : downLoadStatus = .Pause{
        didSet{
            if stateChangeBlock != nil{
                stateChangeBlock!(state)
            }
            
            if state == .Success && successFilePathBlock != nil{
                successFilePathBlock!(downLoadedPath)
            }
            
            if state == .Failed && failedBlock != nil{
                failedBlock!()
            }
        }
    }

    /// 当前进度值
    var progress : Float = 0{
        
        didSet{
            if progressBlock != nil{
                progressBlock!(Float(progress))
            }
        }
    }

    // MARK:- 懒加载
    /// 下载会话
    fileprivate lazy var session : URLSession = {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
}

// MARK:- 对外接口
extension STDownLoader {
    func downLoader(url : URL, downLoadTotalSize : @escaping DownLoadTotalSizeBlock, progress : @escaping ProgressBlock, successFilePath : @escaping SuccessFilePathBlock, failed : @escaping FailedBlock){
        // 1 赋值闭包
        downLoadTotalSizeBlock = downLoadTotalSize
        progressBlock = progress
        successFilePathBlock = successFilePath
        failedBlock = failed
        
        // 2 开始下载
        downLoader(url: url)
    }
}

// MARK:- 下载动作:开始下载,暂停下载,继续下载,取消下载
extension STDownLoader {

    fileprivate func downLoadWithUrl(url : URL, offset : Int){
        var request = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 0)
//        var request = URLRequest(url: url)
        // 通过控制range, 控制请求资源字节区间
        request.setValue(String(format: "bytes=%lld-",offset), forHTTPHeaderField: "Range")
        dataTask = session.dataTask(with: request)
        resumeCurrentTask()
    }
    
    
    
    // 开始下载
    fileprivate func downLoader(url : URL){
        
        // 1 是否是同一个url
        if url == dataTask?.originalRequest?.url{
            // 如果是暂停状态
            if state == .Pause{
                resumeCurrentTask()
                return
            }
        }
        cancelCurrentTask()
        // 2 本地是否有已经下载的视频(完成下载)
        downLoadedPath = STFileTool.getFileCachePath(url: url)
        downLoadingPath = STFileTool.getFileTempPath(url: url)
        // 2.1 已经完成的路径没有这个文件
        guard STFileTool.fiexFile(path: downLoadedPath) == false else {
            state = .Success
            successFilePathBlock!("已下载")
            return
        }
        // 2.2 临时路径
        guard STFileTool.fiexFile(path: downLoadingPath) else {
           downLoadWithUrl(url: url, offset: 0)
            state = .Loading
            return
        }
        
        // 2.3 获取临时文件大小
        tempFileSize = STFileTool.getFileSizeWithPath(downLoadingPath)
        // 2.4 从临时文件大小位置开始下载
        downLoadWithUrl(url: url, offset: tempFileSize)
        
    }
    // 暂停下载
     func pauseCurrentTask() {
        if state == .Loading{
            
            dataTask?.suspend()
            state = .Pause
        }
    }
    // 继续下载
     func resumeCurrentTask() {
        if dataTask != nil && state == .Pause{
            
            dataTask!.resume()
            state = .Loading
        }
    }
    // 取消下载
     func cancelCurrentTask() {
        dataTask?.cancel()
        dataTask = nil
//        session.invalidateAndCancel()
        state = .Pause
    }
    
    
}

// MARK:- URLSessionDataDelegate
extension STDownLoader : URLSessionDataDelegate {
      func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void){
        // 1 获取文件总大小
        if let httpResponse = response as? HTTPURLResponse{
            if let totleSzieString = httpResponse.allHeaderFields["Content-Length"] as? String{
                if let totleSizeT = Int(totleSzieString){
                    totleFileSize = totleSizeT
                }
            }
            // 1.1 Content-Range数据比Content-Length更精确(但是Content-Range有可能有不存在的情况)
            if let totleRangeSize = httpResponse.allHeaderFields["Content-Range"]{
                if let totleRangeString = totleRangeSize as? NSString{
                    if let totleRangeLaseString = totleRangeString.components(separatedBy: "/").last{
                        totleFileSize = Int(totleRangeLaseString)!
                    }
                }
            }

        }
        
        // 2 传递总大小
        if downLoadTotalSizeBlock != nil{
            downLoadTotalSizeBlock!(totleFileSize)
        }
        
        // 3 比较本地文件大小
        // 3.1 临时大小 == 总大小
        if tempFileSize == totleFileSize {
            // 3.1.1 移动数据
            STFileTool.moveFile(fromPath: downLoadingPath, toPath: downLoadedPath)
            // 3.1.2 更改状态
            state = .Success
            // 3.1.3 取消本次请求
            completionHandler(.cancel)
            return
        }
        
        // 3.2 临时文件 > 总大小
        if tempFileSize > tempFileSize {
            // 3.2.1 删除缓存文件
            STFileTool.removeFileAtPath(filePath: downLoadingPath)
            // 3.2.2 取消本次请求
            completionHandler(.cancel)
            // 3.2.3 重新开启请求
            downLoader(url: response.url!)
            return
        }
        
        
        // 4 创建通道
        let stream = OutputStream(toFileAtPath: downLoadingPath, append: true)
        // 4.1 保存通道
        currentStream = stream
        // 5 打开通道
        stream?.open()
        // 6 允许接受数据
        completionHandler(.allow)
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        
        tempFileSize = data.count + tempFileSize
        progress = Float(Float(tempFileSize) / Float(totleFileSize))
        let data = data as NSData
        currentStream?.write(data.bytes.assumingMemoryBound(to: UInt8.self), maxLength: data.length)
        
        /*
         错误写法 ,数据能下载完成,但是播放不了
         //        let buffer = [UInt8](repeating:0, count:data.count)
         //        currentStream?.write(buffer, maxLength: data.count)

         */
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        // 1 没有错误
        if error == nil {
            // 1.1 移动文件
            STFileTool.moveFile(fromPath: downLoadingPath, toPath: downLoadedPath)
            // 1.2 改变状态
            state = .Success
            // success
            successFilePathBlock!("下载成功")
            session.invalidateAndCancel()
            return
        }
        
        // 2 有错误
        // 2.1 取消,断网
        if (error as! NSError).code == -999 {
            state = .Pause
            if stateChangeBlock != nil{
                
                stateChangeBlock!(state)
            }
        }else{
            // 2.2 更改状态
            state = .Failed
            failedBlock!()
        }
        
        // 3 关闭通道
        currentStream?.close()
        currentStream = nil
    }

}
