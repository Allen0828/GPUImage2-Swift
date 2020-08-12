//
//  AEPublishFilterViewController.swift
//  BPlus
//
//  Created by 张其锋 on 2020/1/10.
//  Copyright © 2020 bplus. All rights reserved.
//

import UIKit

private enum FilterViewMode {
    case initialize,
    insert
}

class AEPublishFilterController: UIViewController {
    // 发布初始化时 所有照片添加滤镜
    // 单张图片添加滤镜
    
    static public func instanceInsert(imgs: [UIImage], vc: UIViewController, handle: (([UIImage])->Void)?) {
        let filter = AEPublishFilterController()
        let nav = UINavigationController.init(rootViewController: filter)
        filter.mode = .insert
        filter.imgs = imgs
        filter.insertHandle = handle
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            vc.present(nav, animated: true, completion: nil)
        }
    }
    
    
    static public func instance(tag: String?, _ list: [[String: Any]], isKindergaten: Bool) -> AEPublishFilterController {
        let vc = AEPublishFilterController()
        vc.isKindergaten = isKindergaten
        vc.datas = list
        return vc
    }
    
    private var mode: FilterViewMode = .initialize
    // 处理插入图片的回调
    private var insertHandle: (([UIImage])->Void)?
    
    private var isKindergaten: Bool = false
    // 选完图片去编辑页
    private var datas: [[String: Any]] = [] {
        didSet {
            let images = datas.map { $0["image"] as? UIImage }
            self.imgs = images
        }
    }
    
    // 不改变size 压缩图片
    private var imgs: [UIImage?] = [] {
        didSet {
            var viewX: CGFloat = 0
            // 必须使用 异步线程
            for item in imgs {
                if let img = item {
                    let view = AEFilterImageView(frame: CGRect(x: viewX, y: 0, width: imgScrollView.width, height: imgScrollView.height))
                    DispatchQueue.main.async {
                        let data = img.jpegData(compressionQuality: 0.7)
                        view.img = UIImage(data: data ?? Data())
                    }
                    
                    imgScrollView.addSubview(view)
                    filterImages.append(view)
                    viewX += imgScrollView.width
                }
            }
            imgScrollView.contentSize = CGSize(width: viewX, height: 0)
            countLabel.text = "1/\(imgs.count)"
        }
    }
    /// 每张图片
    private var filterImages: [AEFilterImageView] = []
    private var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.alpha = 0
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.alpha = 1
        navigationController?.navigationBar.isHidden = false
    }
    
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        label.text = "1/1"
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitle("下一步", for: .normal)
        btn.addTarget(self, action: #selector(nextBtnClicked), for: .touchUpInside)
        return btn
    }()
    private lazy var backItem: UIButton = {
//        let img = UIImage(named: "white_back_round")
        let item = UIButton()
        item.setTitle("back", for: .normal)
        item.setTitleColor(UIColor.red, for: .normal)
//        item.setImage(img, for: .normal)
        item.addTarget(self, action: #selector(backItemDidClick), for: .touchUpInside)
        return item
    }()

    // 图片承载器
    private lazy var imgScrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - (44 + 168)))
        view.delegate = self
        view.isPagingEnabled = true
        view.backgroundColor = UIColor.white
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private lazy var filterView: AEFilterImageView = {
        let view = AEFilterImageView(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - (44 + 168)))
        view.backgroundColor = .black
        return view
    }()
    
    // 滤镜选择  H:168
    private lazy var filterCellView: AEFilterCellView = {
        let view = AEFilterCellView()
        return view
    }()
}

extension AEPublishFilterController {
    
    private func setupUI() {
        // 浏览图片 屏幕高 - 状态栏(statusBarHeight) - 滤镜样式(168) - X底部适配(screenBottomHeight)
        view.addSubview(imgScrollView)
        
        filterCellView.frame = CGRect(x: 0, y: imgScrollView.frame.maxY, width: UIScreen.main.bounds.size.width, height: 168)
        view.addSubview(filterCellView)

        countLabel.frame = CGRect(x: 0, y: 44 + 6, width: 60, height: 32)
        countLabel.center.x = view.center.x
        view.addSubview(countLabel)
        nextBtn.frame = CGRect(x: UIScreen.main.bounds.size.width - 8 - 68, y: 44 + 6, width: 68, height: 32)
        view.addSubview(nextBtn)
        backItem.frame = CGRect(x: 8, y: 44 + 6, width: 32, height: 32)
        view.addSubview(backItem)
        
        filterCellView.cellClicked = { [weak self] (filter) in
            print(filter)
            self?.filterImages[self?.index ?? 0].filter = filter
        }
        
    }
    
    @objc private func nextBtnClicked() {
        let showImgs: [UIImage] = filterImages.map { ($0.showImage ?? UIImage()) }
        if mode == .insert {
            insertHandle?(showImgs)
            self.dismiss(animated: true, completion: nil)
            return
        }
        for (idx, img) in showImgs.enumerated() {
            datas[idx].updateValue(img as Any, forKey: "image")
        }
        pushVC(tag: "", datas)
    }
    
    private func pushVC(tag: String, _ list: [[String: Any]]) {

    }
    
    @objc private func backItemDidClick() {
        dismiss(animated: true, completion: nil)
    }
}


extension AEPublishFilterController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x / scrollView.frame.size.width
        let contenX = Int(offsetX) % imgs.count
        index = contenX
        countLabel.text = "\(contenX + 1)/\(imgs.count)"
        
        // 当前选中的滤镜
//        print("当前选中的滤镜")
//        print(filterImages[contenX].filter.rawValue)
        filterCellView.setFilterCell = filterImages[contenX].filter
    }
    
    
}
