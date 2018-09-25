//
//  ALFilterView.swift
//  混合小视频
//
//  Created by Allen on 2018/9/25.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit

private let FilterCellID = "FilterCellID"

class ALFilterView: UIView, UICollectionViewDataSource, UICollectionViewDelegate  {

    var cellClick: ((_ tag: Int)->())?
    var closeBlock: (()->())?
    
    override init(frame: CGRect) {
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: UIScreen.main.bounds.size.width,
                               height: 150)
        super.init(frame: viewFrame)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        addSubview(topLabel)
        topLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(8)
            make.centerX.equalTo(self)
        }
        
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(15)
            make.centerY.top.equalTo(self.topLabel)
            make.right.equalTo(self).offset(-8)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(120)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeClick() {
        if closeBlock != nil {
            closeBlock!()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCellID, for: indexPath) as! filterCell
        cell.filterName = dataSource[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if cellClick != nil {
            cellClick!(indexPath.item)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = 90
            
            layout.itemSize = CGSize(width: width, height: 120)
            //collectionView.frame.size
        }
    }
    
    private var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "滤镜"
        
        return label
    }()
    
    private var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close-white"), for: .normal)
        btn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        
        return btn
    }()
    
    private var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = UIColor.clear
        
        collection.register(filterCell.classForCoder(), forCellWithReuseIdentifier: FilterCellID)
        
        
        return collection
    }()
    
    private var dataSource: [[String: String]] = {
        let arr = [["key":"YuanTu","title":"原图"],
                   ["key":"HuaiJiu","title":"怀旧"],
                   ["key":"DiPian","title":"底片"],
                   ["key":"HeiBai","title":"黑白"],
                   ["key":"FuDiao","title":"浮雕"],
                   ["key":"MengLong","title":"朦胧"],
                   ["key":"KaTong","title":"卡通"],
                   ["key":"TuQi","title":"凸起"],
                   ["key":"ShuiJin","title":"水晶"]]
        
        return arr
    }()
    
}


class filterCell: UICollectionViewCell {
    
    var filterName: [String: String]? {
        didSet {
            title.text = filterName?["title"] ?? ""
            img.image = UIImage(named: filterName?["key"] ?? "YuanTu")
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(img)
        img.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.top.left.right.equalTo(self.contentView)
        }
        
        contentView.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var img: UIImageView = {
        let img = UIImageView()
        return img
    }()

}
