//
//  ImageFilter.swift
//  混合小视频
//
//  Created by Allen on 2018/9/18.
//  Copyright © 2018年 Allen. All rights reserved.
//

import UIKit

class ImageFilter: NSObject {
    
    public class func filter(tag: Int) -> GPUImageFilter {
        
        switch tag {
        case 0:
            return GPUImageNormalBlendFilter()
        case 1:
            return GPUImageSepiaFilter()
        case 2:
            return GPUImageColorInvertFilter()
        case 3:
            return GPUImageDilationFilter()
        case 4:
            return GPUImageEmbossFilter()
        case 5:
            return GPUImageHazeFilter()
        case 6:
            return GPUImageToonFilter()
        case 7:
            return GPUImageBulgeDistortionFilter()
        case 8:
            return GPUImageGlassSphereFilter()
        default:
            return GPUImageGrayscaleFilter()
        }
    }
}
