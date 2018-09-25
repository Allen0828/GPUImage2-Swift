//
//  ALPhotoSheet.swift
//  YinKe
//
//  Created by Allen on 2018/7/26.
//  Copyright © 2018年 Manta. All rights reserved.
//

import UIKit

class ALPhotoSheet: UIView {
    
    var chooseTag: ((_ tag: Int) -> ())?
    
    func show() -> Void {
        UIApplication.shared.delegate?.window??.addSubview(self)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    func close() -> Void {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlDown, animations: {
            self.alpha = 0
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        }) { (finished) in
            for view:UIView in self.subviews {
                view.removeFromSuperview()
            }
            self.removeFromSuperview()
         }
    }
    
    private var camera: UIButton?
    private var library: UIButton?

    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        camera = UIButton()
        camera?.backgroundColor = UIColor.orange
        camera?.setTitle("拍摄", for: .normal)
        camera?.setTitleColor(UIColor.black, for: .normal)
        camera?.layer.cornerRadius = 25
        camera?.tag = 1
        camera?.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        library = UIButton()
        library?.backgroundColor = UIColor.orange
        library?.setTitle("从图库选择", for: .normal)
        library?.setTitleColor(UIColor.black, for: .normal)
        library?.layer.cornerRadius = 25
        library?.tag = 2
        library?.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        addSubview(library!)
        addSubview(camera!)
        
        library?.snp.makeConstraints({ (make) in
            make.width.equalTo(256)
            make.height.equalTo(50)
            make.bottom.equalTo(self).offset(-40)
            make.centerX.equalTo(self)
        })
        camera?.snp.makeConstraints { (make) in
            make.width.equalTo(256)
            make.height.equalTo(50)
            make.bottom.equalTo(self.library!.snp.top).offset(-25)
            make.centerX.equalTo(self)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapGesture(tap:UITapGestureRecognizer) -> Void {
        close()
    }
    @objc private func buttonClick(btn: UIButton)->Void {
        close()
        if chooseTag != nil {
            chooseTag!(btn.tag)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        close()
    }
    
}
