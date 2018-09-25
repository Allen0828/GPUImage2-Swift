//
//  AEListViewController.swift
//  ShortVideo
//
//  Created by Allen on 2018/9/11.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit
import AVKit

private var VIDEOCELLID = "ShortVideoCellID"

class AEListViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var videoImg: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "短视频"
        
        /*
        
         
         */
        
        
        
        setupUI()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VIDEOCELLID, for: indexPath) as! AEVideoCollectionCell
        cell.imgNmaed = videoImg
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }
    
    @objc private func buttonClick() {
        
        let view = ALPhotoSheet()
        view.chooseTag = { [weak self]  (tag) in

            if tag == 1 {

                self?.navigationController?.pushViewController(
                    AERecordingController(), animated: true)
            }else {
                self?.openAlbum()
            }

        }
        
        view.show()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        view.addSubview(beginButton)
        beginButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.bottom.equalTo(self.view).offset(-50)
            make.centerX.equalTo(self.view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (view.frame.size.width - 24) / 2
            
            layout.itemSize = CGSize(width: width, height: width)
            //collectionView.frame.size
        }
    }

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = UIColor.clear
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(AEVideoCollectionCell.classForCoder(), forCellWithReuseIdentifier: VIDEOCELLID)

        
        return collection
    }()
    
    lazy var beginButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "choose_video"), for: .normal)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        return btn
    }()

}

//MARK: 选择相册
extension AEListViewController {
    
    private func openAlbum() {
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("读取相册错误")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.videoQuality = .typeMedium
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let videoURL = info[UIImagePickerControllerMediaURL] as! URL

        picker.dismiss(animated: true, completion: nil)
        reviewVideo(videoURL)
    }
    
    func reviewVideo(_ videoURL: URL) {
        
        let asset = AVURLAsset(url: videoURL)
        let time = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(time)
        
        
        if CGFloat(audioDurationSeconds) < 3 {
            print("视频不能低于3秒")
            return
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timeSecond = CMTimeMakeWithSeconds(0.0,600)
        var actualTime:CMTime = CMTimeMake(0,0)
        let imageRef:CGImage = try! generator.copyCGImage(at: timeSecond, actualTime: &actualTime)
        let frameImg = UIImage(cgImage: imageRef)
        
        videoImg = frameImg
        collectionView.reloadData()
        
//        
//        if CGFloat(audioDurationSeconds) > 120 {
//            let intercept = AEInterceptController()
//
//            navigationController?.pushViewController(intercept, animated: true)
//        }else {
            let edit = ShowLiveViewController()
            edit.path = videoURL

            navigationController?.pushViewController(edit, animated: true)
//        }

    }

}




