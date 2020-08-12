//
//  AEFilterImageView.swift
//  BPlus
//
//  Created by 张其锋 on 2020/1/14.
//  Copyright © 2020 bplus. All rights reserved.
//

import UIKit
import GPUImage

class AEFilterImageView: UIView {
    
    public var showImage: UIImage? {
        get {
            return self.imgView.image
        }
    }
    /// 需要改变的img  原始图片
    public var img: UIImage? {
        didSet {
            self.imgView.image = img
        }
    }
    
    public var filter: FilterItem = .original {
        didSet {
            
            if let img = cachedImages["\(filter)"] as? UIImage {
                self.imgView.image = img
                return
            }
            
            guard let orImg = img else { return }
            let pictureInput = PictureInput(image: orImg) //.fixOrientation()
            let pictureOutput = PictureOutput()
            pictureOutput.imageAvailableCallback = { image in
                self.cachedImages.updateValue(image, forKey: "\(self.filter)")
                self.imgView.image = image
            }
            switch filter {
            case .original:
                pictureInput --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .natural:
                let ex = ExposureAdjustment()
                ex.exposure = 0.3
                let sa = SaturationAdjustment()
                sa.saturation = 1.13
                let hi = HighlightsAndShadows()
                hi.shadows = 0.18
                pictureInput --> ex --> sa --> hi --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .grapefruit:
                let rgb = RGBAdjustment()
                rgb.green = 0.97
                let ex = ExposureAdjustment()
                ex.exposure = 0.28
                let sa = SaturationAdjustment()
                sa.saturation = 0.85
                let hi = HighlightsAndShadows()
                hi.shadows = 0.3
                pictureInput --> rgb --> ex --> sa --> hi --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .forest:
                let wh = WhiteBalance()
                wh.temperature = 4730
                let ex = ExposureAdjustment()
                ex.exposure = 0.28
                let sa = SaturationAdjustment()
                sa.saturation = 1.12
                let ha = Haze()
                ha.distance = 0.07
                pictureInput --> wh --> ex --> sa --> ha --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .film:
                let ga = GammaAdjustment()
                ga.gamma = 0.7
                let wh = WhiteBalance()
                wh.temperature = 4600
                let ex = ExposureAdjustment()
                ex.exposure = 0.22
                let hi = HighlightsAndShadows()
                hi.shadows = 0.07
                pictureInput --> ga --> wh --> ex --> hi --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .magazine:
                let ga = GammaAdjustment()
                ga.gamma = 0.7
                let wh = WhiteBalance()
                wh.temperature = 4700
                let ex = ExposureAdjustment()
                ex.exposure = 0.18
                let ha = Haze()
                ha.distance = 0.17
                let sa = SaturationAdjustment()
                sa.saturation = 0.98
                pictureInput --> ga --> wh --> ex --> ha --> sa --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .food:
                let ex = ExposureAdjustment()
                ex.exposure = 0.27
                let sa = SaturationAdjustment()
                sa.saturation = 1.6
                let rgb = RGBAdjustment()
                rgb.blue = 0.95
                let br = BrightnessAdjustment()
                br.brightness = 0.035
                pictureInput --> ex --> sa --> rgb --> br --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .solar:
                let ga = GammaAdjustment()
                ga.gamma = 0.65
                let wh = WhiteBalance()
                wh.temperature = 4950
                let br = BrightnessAdjustment()
                br.brightness = 0.06
                let rgb = RGBAdjustment()
                rgb.blue = 0.94
                pictureInput --> ga --> wh --> br --> rgb --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .juice:
                let rgb = RGBAdjustment()
                rgb.green = 0.9
                rgb.blue = 0.9
                let ga = GammaAdjustment()
                ga.gamma = 0.6
                let ex = ExposureAdjustment()
                ex.exposure = 0.04
                let br = BrightnessAdjustment()
                br.brightness = 0.02
                pictureInput --> rgb --> ga --> ex --> br --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .cold:
                let wh = WhiteBalance()
                wh.temperature = 4800
                let ga = GammaAdjustment()
                ga.gamma = 0.85
                let ex = ExposureAdjustment()
                ex.exposure = 0.2
                pictureInput --> wh --> ga --> ex --> pictureOutput
                pictureInput.processImage(synchronously: true)
            case .clean:
                let wh = WhiteBalance()
                wh.temperature = 4700
                let ga = GammaAdjustment()
                ga.gamma = 0.6
                let ex = ExposureAdjustment()
                ex.exposure = 0.1
                let ha = Haze()
                ha.distance = 0.1998
                let sa = SaturationAdjustment()
                sa.saturation = 0.86
                let br = BrightnessAdjustment()
                br.brightness = 0.05
                pictureInput --> wh --> ga --> ex --> ha --> sa --> br --> pictureOutput
                pictureInput.processImage(synchronously: true)
                
            }
        }
    }
     
    // 根据滤镜生成的图片  防止重复选择 key=滤镜名 value=Image
    private var cachedImages: [String: UIImage?] = [:]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.maximumZoomScale = 3.0
    }
    
    private lazy var scrollView: UIScrollView = {
        //frame: UIScreen.main.bounds
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scroll.backgroundColor = UIColor.black
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .black
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    
}

extension AEFilterImageView {
    
    private func setupUI() {
        imgView.frame = bounds
        scrollView.frame = bounds
        scrollView.addSubview(imgView)
        addSubview(scrollView)
    }
    
}

extension AEFilterImageView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.recenterImage()
    }

    private func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        
        let imageViewSize = imgView.frame.size
        
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        let verticalSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.width) / 2.0 :0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
}
