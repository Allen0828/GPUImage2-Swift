//
//  AEEditVideoController.swift
//  ShortVideo
//
//  Created by Allen on 2018/9/11.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit

class AEEditVideoController: UIViewController {
    
    var videoPath: URL!
    var playerView: GPUImageView!
    var movie: GPUImageMovie!
    var theAudioPlayer: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()


        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        title = "编辑视频"
        
        playerView = GPUImageView(frame: view.frame)
        view.addSubview(playerView)
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        playerMovie(url: videoPath)
        
        bottomView.cellClick = { (tag) in
            
            print("\(tag) +++++")
        }
    }

    deinit {
        print("编辑视频 --- deinit")
    }
    
    
    private var bottomView: ALFilterView = {
        let view = ALFilterView()
        return view
    }()
    
    private func playerMovie(url: URL) {
        playerView.setInputRotation(GPUImageRotationMode.rotateRight, at: 0)
        movie = GPUImageMovie(url: url)
        movie.shouldRepeat = true       //是否循环播放
        movie.runBenchmark = false      //显示打印进度
        movie.playAtActualSpeed = true  //显示原速度
        
        movie.addTarget(playerView)
        movie.startProcessing()
        
        if theAudioPlayer != nil {
            theAudioPlayer?.pause()
            theAudioPlayer?.seek(to: CMTime.init())
            theAudioPlayer = nil
        }
        theAudioPlayer = AVPlayer(url: videoPath)
        
        theAudioPlayer?.play()

    }

    
}




