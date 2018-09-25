//
//  AERecordingController.swift
//  ShortVideo
//
//  Created by Allen on 2018/9/12.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit
import AVFoundation

enum GPUFilter: Int {
    case GPUinitialFilter = 0            //原图
    case GPUImageSepiaFilter = 1         //怀旧
    case GPUImageColorInvertFilter = 2   //底片
    case GPUImageDilationFilter = 3      //黑白
    case GPUImageEmbossFilter = 4        //浮雕
    
    case GPUImagePixellateFilter = 999   //马赛克
}


class AERecordingController: UIViewController {
    
    //准备录制
    private var beginTimer: Timer!
    private var beginNumber = 0
    
    //录制时间
    private var recordTimer: Timer!
    private var recordNumber = 0
    
    //准备拍摄
    private var maskView = maskNumberView()
    
    //视频
    private var fileName = "\(Int(Date().timeIntervalSince1970)).m4v"
    private var videoCamera: GPUImageVideoCamera!
    private var movieWriter: GPUImageMovieWriter!
    private var filterImgView: GPUImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.white
        title = "录制视频"
        
        //如果在此设置 拍摄返回后重置回c奔溃
//        setupGPU()
//        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupGPU()
        setupUI()
        videoCamera.startCapture()
        beginNumber = 3
        recordNumber = 0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if beginTimer != nil {
            beginTimer.invalidate()
            beginTimer = nil
        }
        if recordTimer != nil {
            recordTimer.invalidate()
            recordTimer = nil
        }
        topView.isHidden = false
        bottomView.isHidden = false
        progressBackView.isHidden = true
        finishBtn.isHidden = true
        fileName = "\(Int(Date().timeIntervalSince1970)).m4v"
        movieWriter.finishRecording()
        videoCamera.stopCapture()
        maskView.number = "3"
        finishBtn.isEnabled = false
    }
    
    
    
    //MARK: 录制设置
    private func setRecording() {
        progressBackView.isHidden = false
        finishBtn.isHidden = false
        movieWriter.startRecording()
        recordTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target:self,
                                           selector:#selector(recordMethod),
                                           userInfo:nil,
                                           repeats:true)
    }
    
    //MARK: 最少录制3秒 最多120秒
    @objc private func recordMethod() {
        recordNumber += 1
        if recordNumber == 3 {
            finishBtn.isEnabled = true
        }
        if recordNumber == 121 {
            recordTimer.invalidate()
            recordTimer = nil
            finishClick()
            return
        }
        progressView.width += self.progressBackView.width / 120
    }
    
    //MARK: 结束录制
    @objc private func finishClick() {
        movieWriter.finishRecording()
        videoCamera.stopCapture()
        
        let vc = ShowLiveViewController()
        vc.path = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: 开始录制
    @objc private func beginClick() {
        maskView.show()
        beginTimer = Timer.scheduledTimer(timeInterval: 1.0,target:self,
                                          selector:#selector(beginTimingMethod),userInfo:nil,
                                          repeats:true)
        topView.isHidden = true
        bottomView.isHidden = true
    }
    
    //MARK: 计时器
    @objc private func beginTimingMethod() {
        beginNumber -= 1
        if beginNumber == 0 {
            beginTimer.invalidate()
            beginTimer = nil
            setRecording()
            maskView.close()
            return
        }
        maskView.number = "\(beginNumber)"
    }
    
    //MARK: 设置滤镜
    @objc private func filterClick() {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterView.top -= 150
            self.bottomView.isHidden = true
        }, completion: { (finish) in
            
        })
    }
    
    //MARK: 切换摄像头
    @objc private func cameraClick() {
        videoCamera.rotateCamera()
    }
    
    //MARK: 关闭
    @objc private func closeClick() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: 设置摄像仪
    private func setupGPU() {
        
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.iFrame1280x720.rawValue, cameraPosition: .back)
        videoCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        
        filterImgView = GPUImageView(frame: view.bounds)
        view.addSubview(filterImgView)
        
        let tempPath = NSTemporaryDirectory() + fileName
        let movieURL = URL(fileURLWithPath: tempPath)
        
        movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        movieWriter.encodingLiveVideo = true
        
        videoCamera.addTarget(filterImgView)
        videoCamera.addTarget(movieWriter)
        
        //设置声音
        videoCamera.audioEncodingTarget = movieWriter
    }
    
    private func setupUI() {
        topView.addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(35)
            make.left.equalTo(self.topView).offset(24)
            make.centerY.equalTo(self.topView)
        }
        
        topView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(self.topView).offset(-24)
            make.centerY.equalTo(self.topView)
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(UIScreen.main.bounds.size.height > 800 ? 44 : 20)
            make.left.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        bottomView.addSubview(beginBtn)
        beginBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalTo(self.bottomView)
            make.top.equalTo(self.bottomView)
        }
        
        bottomView.addSubview(filterBtn)
        filterBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(self.bottomView).offset(-24)
            make.centerY.equalTo(self.beginBtn)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        view.addSubview(finishBtn)
        finishBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-50)
        }
        
        progressBackView.frame = CGRect(x: 24, y: UIScreen.main.bounds.size.height > 800 ? 44 : 20, width: UIScreen.main.bounds.size.width - 48, height: 2)
        view.addSubview(progressBackView)
        progressView.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
        progressBackView.addSubview(progressView)
        
        setFilterView()
    }
    
    private func setFilterView()  {
        filterView.frame = CGRect(x: 0, y: view.bottom, width: view.width, height: 150)
        view.addSubview(filterView)
        
        filterView.cellClick = { [weak self] (tag) in
            self?.switchedFilter(tag: tag)
        }
        filterView.closeBlock = { [weak self] () in
            
            UIView.animate(withDuration: 0.25, animations: {
                self?.filterView.top += 150
            }, completion: { (finish) in
                self?.bottomView.isHidden = false
            })
        }
    }
    
    //MARK: 选择滤镜
    private func switchedFilter(tag: Int) {
        
        if tag == 0 {
            videoCamera.removeAllTargets()
            videoCamera.addTarget(filterImgView)
            videoCamera.addTarget(movieWriter)
        }else {
            let filter = ALImageFilter.filter(tag: tag)
            
            videoCamera.removeAllTargets()
            videoCamera.addTarget(filter)
            filter.addTarget(filterImgView)
            filter.addTarget(movieWriter)
        }
    }
    
    //MARK: subview
    lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cameraBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "camera"), for: .normal)
        btn.addTarget(self, action: #selector(cameraClick), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close_video"), for: .normal)
        btn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var beginBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "recording"), for: .normal)
        btn.addTarget(self, action: #selector(beginClick), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var filterBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "filter_icon"), for: .normal)
        btn.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
        
        return btn
    }()
    
    private var filterView: ALFilterView = {
        let view = ALFilterView()
        return view
    }()
    
    lazy var progressBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.isHidden = true
        
        return view
    }()
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        
        return view
    }()
    
    private var finishBtn: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.isEnabled = false
        btn.setImage(UIImage(named: "suspend_icon"), for: .normal)
        btn.addTarget(self, action: #selector(finishClick), for: .touchUpInside)
        
        return btn
    }()
    
}

//MARK: 遮罩
class maskNumberView: UIView {
    
    public func show() -> Void {
        alpha = 1
        UIApplication.shared.delegate?.window??.addSubview(self)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    public func close() -> Void {
        alpha = 0
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    public var number: String? {
        didSet {
            numberLabel.text = number ?? ""
        }
    }
    
    private var numberLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        numberLabel = UILabel()
        numberLabel.text = "3"
        numberLabel.textColor = UIColor.white
        numberLabel.font = UIFont.systemFont(ofSize: 28)
        
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//eturn new GPUImageContrastFilter(2.0f);                                            //对比度
//case GAMMA:
//return new GPUImageGammaFilter(2.0f);                                               //伽马线
//case INVERT:
//return new GPUImageColorInvertFilter();                                             //反色
//case PIXELATION:
//return new GPUImagePixelationFilter();                                              //像素
//case HUE:
//return new GPUImageHueFilter(90.0f);                                                //色度
//case BRIGHTNESS:
//return new GPUImageBrightnessFilter(1.5f);                                          //亮度
//case GRAYSCALE:
//return new GPUImageGrayscaleFilter();                                               //灰度
//case SEPIA:
//return new GPUImageSepiaFilter();                                                   //褐色（怀旧）
//case SHARPEN:
//GPUImageSharpenFilter sharpness = new GPUImageSharpenFilter();                      //锐化
//sharpness.setSharpness(2.0f);
//return sharpness;
//case SOBEL_EDGE_DETECTION:
//return new GPUImageSobelEdgeDetection();
//case THREE_X_THREE_CONVOLUTION:
//GPUImage3x3ConvolutionFilter convolution = new GPUImage3x3ConvolutionFilter();      //3x3卷积，高亮大色块变黑，加亮边缘、线条等
//convolution.setConvolutionKernel(new float[] {
//-1.0f, 0.0f, 1.0f,
//-2.0f, 0.0f, 2.0f,
//-1.0f, 0.0f, 1.0f
//});
//return convolution;
//case EMBOSS:
//return new GPUImageEmbossFilter();                                                  //浮雕效果，带有点3d的感觉
//case POSTERIZE:
//return new GPUImagePosterizeFilter();                                               //色调分离，形成噪点效果
//case FILTER_GROUP:
//List<GPUImageFilter> filters = new LinkedList<GPUImageFilter>();
//filters.add(new GPUImageContrastFilter());
//filters.add(new GPUImageDirectionalSobelEdgeDetectionFilter());
//filters.add(new GPUImageGrayscaleFilter());
//return new GPUImageFilterGroup(filters);
//case SATURATION:
//return new GPUImageSaturationFilter(1.0f);                                          //饱和度
//case EXPOSURE:
//return new GPUImageExposureFilter(0.0f);                                            //曝光
//case HIGHLIGHT_SHADOW:
//return new GPUImageHighlightShadowFilter(0.0f, 1.0f);         //提亮阴影
//case MONOCHROME:
//return new GPUImageMonochromeFilter(1.0f, new float[]{0.6f, 0.45f, 0.3f, 1.0f});   ////单色
//case OPACITY:
//return new GPUImageOpacityFilter(1.0f);                                             //不透明度
//case RGB:
//return new GPUImageRGBFilter(1.0f, 1.0f, 1.0f);                 //RGB
//case WHITE_BALANCE:
//return new GPUImageWhiteBalanceFilter(5000.0f, 0.0f);            //白平横
//case VIGNETTE:
//PointF centerPoint = new PointF();
//centerPoint.x = 0.5f;
//centerPoint.y = 0.5f;
//return new GPUImageVignetteFilter(centerPoint, new float[] {0.0f, 0.0f, 0.0f}, 0.3f, 0.75f);   //晕影，形成黑色圆形边缘，突出中间图像的效果
//case TONE_CURVE:
//GPUImageToneCurveFilter toneCurveFilter = new GPUImageToneCurveFilter();            //色调曲线
//toneCurveFilter.setFromCurveFileInputStream(
//context.getResources().openRawResource(R.raw.tone_cuver_sample));
//return toneCurveFilter;
//case BLEND_DIFFERENCE:
//return createBlendFilter(context, GPUImageDifferenceBlendFilter.class);             //差异混合,通常用于创建更多变动的颜色
//case BLEND_SOURCE_OVER:
//return createBlendFilter(context, GPUImageSourceOverBlendFilter.class);             //源混合
//case BLEND_COLOR_BURN:
//return createBlendFilter(context, GPUImageColorBurnBlendFilter.class);              //色彩加深混合
//case BLEND_COLOR_DODGE:
//return createBlendFilter(context, GPUImageColorDodgeBlendFilter.class);             //色彩减淡混合
//case BLEND_DARKEN:
//return createBlendFilter(context, GPUImageDarkenBlendFilter.class);                 //加深混合,通常用于重叠类型
//case BLEND_DISSOLVE:
//return createBlendFilter(context, GPUImageDissolveBlendFilter.class);               //溶解
//case BLEND_EXCLUSION:
//return createBlendFilter(context, GPUImageExclusionBlendFilter.class);              //排除混合
//case BLEND_HARD_LIGHT:
//return createBlendFilter(context, GPUImageHardLightBlendFilter.class);              //强光混合,通常用于创建阴影效果
//case BLEND_LIGHTEN:
//return createBlendFilter(context, GPUImageLightenBlendFilter.class);                //减淡混合,通常用于重叠类型
//case BLEND_ADD:
//return createBlendFilter(context, GPUImageAddBlendFilter.class);                    //通常用于创建两个图像之间的动画变亮模糊效果
//case BLEND_DIVIDE:
//return createBlendFilter(context, GPUImageDivideBlendFilter.class);                 //通常用于创建两个图像之间的动画变暗模糊效果
//case BLEND_MULTIPLY:
//return createBlendFilter(context, GPUImageMultiplyBlendFilter.class);               //通常用于创建阴影和深度效果
//case BLEND_OVERLAY:
//return createBlendFilter(context, GPUImageOverlayBlendFilter.class);                //叠加,通常用于创建阴影效果
//case BLEND_SCREEN:
//return createBlendFilter(context, GPUImageScreenBlendFilter.class);                 //屏幕包裹,通常用于创建亮点和镜头眩光
//case BLEND_ALPHA:
//return createBlendFilter(context, GPUImageAlphaBlendFilter.class);                  //透明混合,通常用于在背景上应用前景的透明度
//case BLEND_COLOR:
//return createBlendFilter(context, GPUImageColorBlendFilter.class);                  //颜色混合
//case BLEND_HUE:
//return createBlendFilter(context, GPUImageHueBlendFilter.class);                    //色调混合
//case BLEND_SATURATION:
//return createBlendFilter(context, GPUImageSaturationBlendFilter.class);             //饱和度混合
//case BLEND_LUMINOSITY:
//return createBlendFilter(context, GPUImageLuminosityBlendFilter.class);             //光度混合
//case BLEND_LINEAR_BURN:
//return createBlendFilter(context, GPUImageLinearBurnBlendFilter.class);             //线性混合
//case BLEND_SOFT_LIGHT:
//return createBlendFilter(context, GPUImageSoftLightBlendFilter.class);              //柔光混合
//case BLEND_SUBTRACT:
//return createBlendFilter(context, GPUImageSubtractBlendFilter.class);               //差值混合,通常用于创建两个图像之间的动画变暗模糊效果
//case BLEND_CHROMA_KEY:
//return createBlendFilter(context, GPUImageChromaKeyBlendFilter.class);              //色度键混合
//case BLEND_NORMAL:
//return createBlendFilter(context, GPUImageNormalBlendFilter.class);                 //正常
//
//case LOOKUP_AMATORKA:
//GPUImageLookupFilter amatorka = new GPUImageLookupFilter();                         //lookup 色彩调整
//amatorka.setBitmap(BitmapFactory.decodeResource(context.getResources(), R.drawable.lookup_amatorka));
//return amatorka;
//case GAUSSIAN_BLUR:
//return new GPUImageGaussianBlurFilter();                                            //高斯模糊
//case CROSSHATCH:
//return new GPUImageCrosshatchFilter();                                              //交叉线阴影，形成黑白网状画面
//case BOX_BLUR:
//return new GPUImageBoxBlurFilter();                                                 //盒状模糊
//case CGA_COLORSPACE:
//return new GPUImageCGAColorspaceFilter();                                           //CGA色彩滤镜，形成黑、浅蓝、紫色块的画面
//case DILATION:
//return new GPUImageDilationFilter();                                                //扩展边缘模糊，变黑白
//case KUWAHARA:
//return new GPUImageKuwaharaFilter();                                                //桑原(Kuwahara)滤波,水粉画的模糊效果；处理时间比较长，慎用
//case RGB_DILATION:
//return new GPUImageRGBDilationFilter();                                             //RGB扩展边缘模糊，有色彩
//case SKETCH:
//return new GPUImageSketchFilter();                                                   //素描
//case TOON:
//return new GPUImageToonFilter();                                                     //卡通效果（黑色粗线描边）
//case SMOOTH_TOON:
//return new GPUImageSmoothToonFilter();                                               //相比上面的效果更细腻，上面是粗旷的画风
//
//case BULGE_DISTORTION:
//return new GPUImageBulgeDistortionFilter();                                         //凸起失真，鱼眼效果
//case GLASS_SPHERE:
//return new GPUImageGlassSphereFilter();                                             //水晶球效果
//case HAZE:
//return new GPUImageHazeFilter();                                                    //朦胧加暗
//case LAPLACIAN:
//return new GPUImageLaplacianFilter();
//case NON_MAXIMUM_SUPPRESSION:
//return new GPUImageNonMaximumSuppressionFilter();                                   //非最大抑制，只显示亮度最高的像素，其他为黑
//case SPHERE_REFRACTION:
//return new GPUImageSphereRefractionFilter();                                        //球形折射，图形倒立
//case SWIRL:
//return new GPUImageSwirlFilter();                                                   //漩涡，中间形成卷曲的画面
//case WEAK_PIXEL_INCLUSION:
//return new GPUImageWeakPixelInclusionFilter();                                      //像素融合
//case FALSE_COLOR:
//return new GPUImageFalseColorFilter();                                              //色彩替换（替换亮部和暗部色彩）G
//case COLOR_BALANCE:
//return new GPUImageColorBalanceFilter();                                            //色彩平衡
//case LEVELS_FILTER_MIN:
//GPUImageLevelsFilter levelsFilter = new GPUImageLevelsFilter();                     //色阶
//levelsFilter.setMin(0.0f, 3.0f, 1.0f);
//return levelsFilter;
//case HALFTONE:
//return new GPUImageHalftoneFilter();                                                //点染,图像黑白化，由黑点构成原图的大致图形
//
//case BILATERAL_BLUR:
//return new GPUImageBilateralFilter();                                               //双边模糊
//
//case TRANSFORM2D:
//return new GPUImageTransformFilter();                                               //形状变化
