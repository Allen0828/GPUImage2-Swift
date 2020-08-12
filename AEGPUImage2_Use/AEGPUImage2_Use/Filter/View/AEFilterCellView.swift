//
//  AEFilterCellView.swift
//  BPlus
//
//  Created by 张其锋 on 2020/1/13.
//  Copyright © 2020 bplus. All rights reserved.
//

import UIKit

enum FilterItem: String {
//    .original, .natural, .solar, .clean, .magazine, .grapefruit, .forest, .food, .film, .juice, .cold]
    case original = "原图"
    case natural = "自然"
    case solar = "日系"
    case clean = "奶白"
    case magazine = "杂志"
    case grapefruit = "西柚"
    case forest = "森系"
    case food = "美食"
    case film = "胶片"
    case juice = "果汁"
    case cold = "冷调"
}


class AEFilterCellView: UIView {
    
    public var cellClicked: ((FilterItem)->Void)?
    // 自动选择滤镜item
    public var setFilterCell: FilterItem = .original {
        didSet {
            if let index = items.firstIndex(of: setFilterCell) {
                collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .top)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        setupUI()
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let filterCellId = "FilterCell"
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 84, height: 120)
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.black
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(AEFilterCell.self, forCellWithReuseIdentifier: filterCellId)
        return collection
    }()
    
    private let items: [FilterItem] = [.original, .natural, .solar, .clean, .magazine, .grapefruit, .forest, .food, .film, .juice, .cold]
}

extension AEFilterCellView {
    private func setupUI() {
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 168)
        addSubview(collectionView)
//        collectionView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(self)
//            make.top.equalTo(self).offset(16)
//            make.bottom.equalTo(self).offset(-screenBottomHeight)
//        }

    }
}

extension AEFilterCellView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellId, for: indexPath) as! AEFilterCell
        cell.backgroundColor = UIColor.black
        cell.cellModel = items[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AEFilterCell {
            cell.isSelected = true
            cellClicked?(items[indexPath.item])
        }
    }
}


class AEFilterCell: UICollectionViewCell {
    
    public var cellModel: FilterItem = .original {
        didSet {
            name.text = cellModel.rawValue
            img.image = UIImage(named: "filter_img_\(cellModel)")
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                name.textColor = UIColor.red
                icon.isHidden = false
                maskV.isHidden = false
            } else {
                name.textColor = UIColor.white
                icon.isHidden = true
                maskV.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.frame = CGRect(x: 0, y: 0, width: 84, height: 84)
        contentView.addSubview(img)
//        img.snp.makeConstraints { (make) in
//            make.width.equalToSuperview()
//            make.height.equalTo(self.contentView.snp.width)
//            make.top.left.equalToSuperview()
//        }
        
        name.frame = CGRect(x: 0, y: 84, width: 84, height: 120 - 84)
        contentView.addSubview(name)
//        name.snp.makeConstraints { (make) in
//            make.top.equalTo(self.img.snp.bottom).offset(8)
//            make.centerX.equalToSuperview()
//        }
        maskV.frame = img.frame
        img.addSubview(maskV)
//        maskV.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
//        img.addSubview(icon)
//        icon.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    private lazy var img: UIImageView = {
        let img = UIImageView()
        img.layer.masksToBounds = true
        return img
    }()
    private lazy var icon: UIImageView = {
        let img = UIImageView(image: UIImage(named: "square_red_select_icon"))
        img.isHidden = true
        return img
    }()
    private lazy var maskV: UIView = {
        let v = UIView()
        v.isHidden = true
        v.backgroundColor = .white
        v.layer.cornerRadius = 6
        v.layer.masksToBounds = true
        v.alpha = 0.7
        return v
    }()
}
