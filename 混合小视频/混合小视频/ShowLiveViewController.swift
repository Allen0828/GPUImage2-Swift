//
//  ShowLiveViewController.swift
//  混合小视频
//
//  Created by Allen on 2018/9/17.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit
import AVKit

class ShowLiveViewController: UIViewController {
    
    var path: URL! {
        didSet {
            setVideoImg(url: path)
        }
    }
    var item: AVPlayerItem!
    var player: AVPlayer!
    var playerView: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.white
        
        setupUI()
    }

    private func setVideoImg(url: URL) {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timeSecond = CMTimeMakeWithSeconds(0.0,600)
        var actualTime:CMTime = CMTimeMake(0,0)
        let imageRef:CGImage = try! generator.copyCGImage(at: timeSecond, actualTime: &actualTime)
        let frameImg = UIImage(cgImage: imageRef)
        
        videoImg.image = frameImg
    }
    
    private func setupUI() {
        item = AVPlayerItem(url: path)
        player = AVPlayer(playerItem: item)
        playerView = AVPlayerLayer(player: player)
        playerView.frame = view.frame
        
        view.layer.addSublayer(playerView)
        player.play()
        
        view.addSubview(updateBtn)
        updateBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(32)
            make.right.equalTo(self.view).offset(-32)
            make.height.equalTo(48)
            make.bottom.equalTo(self.view).offset(-60)
        }
        
        view.addSubview(videoImg)
        videoImg.snp.makeConstraints { (make) in
            make.height.equalTo(150)
            make.width.equalTo(80)
            make.bottom.equalTo(self.updateBtn.snp.top).offset(-80)
            make.left.equalTo(self.view).offset(32)
        }
        
        view.addSubview(back)
        back.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(44)
            make.left.equalTo(self.view).offset(24)
        }
    }
    
    
    @objc func backItem() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private lazy var videoImg: UIImageView = {
        let img = UIImageView()
        
        return img
    }()

    lazy var updateBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("上传", for: .normal)
        btn.backgroundColor = UIColor.red
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        
        return btn
    }()
    
    lazy var back: UIButton = {
        let btn = UIButton()
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(backItem), for: .touchUpInside)
        return btn
    }()
    
}
