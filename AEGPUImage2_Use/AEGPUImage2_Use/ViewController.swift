//
//  ViewController.swift
//  AEGPUImage2_Use
//
//  Created by 锋 on 2020/8/12.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showImg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 400)
        showImg.image = UIImage(named: "001")
        view.addSubview(showImg)
        
        let btn = UIButton(frame: CGRect(x: 16, y: 440, width: 100, height: 50))
        btn.backgroundColor = .red
        btn.setTitle("选滤镜", for: .normal)
        btn.addTarget(self, action: #selector(didClick), for: .touchUpInside)
        view.addSubview(btn)
    }

    private lazy var showImg = UIImageView()
    
    @objc private func didClick() {
        AEPublishFilterController.instanceInsert(imgs: [UIImage(named: "001")!], vc: self) { [weak self] (imgs) in
            self?.showImg.image = imgs[0]
        }
    }

}

