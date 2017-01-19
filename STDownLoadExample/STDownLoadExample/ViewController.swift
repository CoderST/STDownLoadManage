//
//  ViewController.swift
//  STDownLoadExample
//
//  Created by xiudou on 2017/1/19.
//  Copyright © 2017年 CoderST. All rights reserved.
//

import UIKit
fileprivate let cellIdentifier = "cellIdentifier"
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate let urlStringArray = ["http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg",
                                      "http://baobab.wdjcdn.com/1455782903700jy.mp4",
                                      "http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return urlStringArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyTableViewCell
        let urlString = urlStringArray[indexPath.item]
        cell.urlString = urlString
        return cell
    }
}

