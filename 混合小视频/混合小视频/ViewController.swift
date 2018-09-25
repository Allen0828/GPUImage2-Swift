//
//  ViewController.swift
//  混合小视频
//
//  Created by Allen on 2018/9/13.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 50))
        button.setTitle("老子要开播", for: .normal)
        button.backgroundColor = UIColor.red
        
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(test11), for: .touchUpInside)
        
    }
    
    @objc func test11() {
        navigationController?.pushViewController(AEListViewController(), animated: true)
    }
    

    
    
    @objc private func test() -> Void {
        
    }

    func save() {

    }

}


