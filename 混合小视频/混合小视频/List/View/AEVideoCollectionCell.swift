//
//  AEVideoCollectionCell.swift
//  ShortVideo
//
//  Created by Allen on 2018/9/11.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit

class AEVideoCollectionCell: UICollectionViewCell {
    
    var imgNmaed: UIImage? {
        didSet {
            coverImg.image = imgNmaed ?? UIImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.red
        
        contentView.addSubview(coverImg)
        coverImg.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var coverImg: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        
        return img
    }()
    
}
