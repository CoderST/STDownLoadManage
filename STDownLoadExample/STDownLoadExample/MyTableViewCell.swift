//
//  MyTableViewCell.swift
//  Downlisten
//
//  Created by xiudou on 2017/1/5.
//  Copyright © 2017年 CoderST. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    var button : UIButton!
    var progressView : UIProgressView!
    
    fileprivate lazy var downLoader : STDownLoader = STDownLoader()
    
    var urlString : String?{
        
        didSet{
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MyTableViewCell {
    
    fileprivate func setupUI() {
         button = UIButton()
        button.backgroundColor = UIColor.orange
        button.setTitle("下载", for: .normal)
        button.setTitle("暂停", for: .selected)
        button.isSelected = false
        button.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        contentView.addSubview(button)
        
        
        progressView = UIProgressView()
        progressView.progress = 0
        contentView.addSubview(progressView)
    }
    
    func btnClick(sender:UIButton){
        let url = URL(string: urlString!)
        if sender.isSelected == false {
            sender.isSelected = true
            
            STDownLoaderManage.shareInstance.downLoader(url: url!, downLoadTotalSizeBlock: { (totleSize) in
                print("size = \((totleSize))")
            }, progress: { (progress) in
                print("progress = \(progress)")
                self.progressView.progress = progress
            }, successFile: { (successFile) in
                print("成功",successFile)
            }) {
                print("失败")
            }

        }else{
            sender.isSelected = false
            STDownLoaderManage.shareInstance.pauseWithURL(url: url!)
        }
        
        
    }
    
}

extension MyTableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: contentView.frame.width - 60, y: 10, width: 50, height: contentView.frame.height - 20)
        
        progressView.frame = CGRect(x: 10, y: 20, width: 250, height: 10)
    }
}
