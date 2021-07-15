# GPUImage-Swift
swift使用GPUImage做视频滤镜

文章链接： https://blog.csdn.net/weixin_40085372/article/details/82667256


## 运行报错Library not loaded: @rpath/GPUImage.framework/
一定是选择 new copy files Phase 时  Destination 选错，设置为frameworks 重新编译即可


# 常见的错误
在运行GPUImage2时 有肯定奇奇怪怪的问题出现  （欢迎大家补充）
## 在安装完成后 import GPUImage 提示No such module 'GPUImage'
此问题大概率是 编译还未通过，在确保安装步骤没问题后 强行Command+B 编译一次即可。
## 在Release模式下 奔溃EXC_BAD_ACCESS
在高版本的 xcode中 打包出来 或者 run改为Release 会报僵尸对象错误 
**GPUImage2/framework/Source/Apple/PictureInput.swift  119行**
 glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, widthToUseForTexture, heightToUseForTexture, 0, GLenum(format), GLenum(GL_UNSIGNED_BYTE), imageData)
 由于高版本运行时  获取ImageData 前 没有判断 runOperationSynchronously 导致的问题
 **修改方法**
 在PictureInput.swift 文件中  从87行-131行 替换为以下代码 在此编译 即可通过
 ```swift
        if (shouldRedrawUsingCoreGraphics) {
            // For resized or incompatible image: redraw
            imageData = UnsafeMutablePointer<GLubyte>.allocate(capacity:Int(widthToUseForTexture * heightToUseForTexture) * 4)

            let genericRGBColorspace = CGColorSpaceCreateDeviceRGB()
            
            let imageContext = CGContext(data:imageData, width:Int(widthToUseForTexture), height:Int(heightToUseForTexture), bitsPerComponent:8, bytesPerRow:Int(widthToUseForTexture) * 4, space:genericRGBColorspace,  bitmapInfo:CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
            //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
            imageContext?.draw(image, in:CGRect(x:0.0, y:0.0, width:CGFloat(widthToUseForTexture), height:CGFloat(heightToUseForTexture)))
        }
        // 同步运行 代码地址 https://github.com/Allen0828/GPUImage-Swift
        sharedImageProcessingContext.runOperationSynchronously {
            
            if !shouldRedrawUsingCoreGraphics {
                // Access the raw image bytes directly
                dataFromImageDataProvider = image.dataProvider?.data
                #if os(iOS)
                imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider))
                #else
                imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)
                #endif
            }
            
            do {
                // TODO: Alter orientation based on metadata from photo
                self.imageFramebuffer = try Framebuffer(context:sharedImageProcessingContext, orientation:orientation, size:GLSize(width:widthToUseForTexture, height:heightToUseForTexture), textureOnly:true)
            } catch {
                fatalError("ERROR: Unable to initialize framebuffer of size (\(widthToUseForTexture), \(heightToUseForTexture)) with error: \(error)")
            }
            
            glBindTexture(GLenum(GL_TEXTURE_2D), self.imageFramebuffer.texture)
            if (smoothlyScaleOutput) {
                glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
            }
            
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, widthToUseForTexture, heightToUseForTexture, 0, GLenum(format), GLenum(GL_UNSIGNED_BYTE), imageData)
            
            if (smoothlyScaleOutput) {
                glGenerateMipmap(GLenum(GL_TEXTURE_2D))
            }
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }

        if (shouldRedrawUsingCoreGraphics) {
            imageData.deallocate()
        }
    }

```

# 像素缓冲区旋转 (可能会造成图片比例变形)

```swift

static double radians (double degrees) {return degrees * M_PI/180;}

static double ScalingFactorForAngle(double angle, CGSize originalSize) {
    double oriWidth = originalSize.height;
    double oriHeight = originalSize.width;
    double horizontalSpace = fabs( oriWidth*cos(angle) ) + fabs( oriHeight*sin(angle) );
    double scalingFactor = oriWidth / horizontalSpace ;
    return scalingFactor;
}

CGColorSpaceRef rgbColorSpace = NULL;
CIContext *context = nil;
CIImage *ci_originalImage = nil;
CIImage *ci_transformedImage = nil;
CIImage *ci_userTempImage = nil;

static inline void RotatePixelBufferToAngle(CVPixelBufferRef thePixelBuffer, double theAngle) {
    @autoreleasepool {
        if (context==nil) {
            rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: (__bridge id)rgbColorSpace,
                                                       kCIContextOutputColorSpace : (__bridge id)rgbColorSpace}];
        }
        long int w = CVPixelBufferGetWidth(thePixelBuffer);
        long int h = CVPixelBufferGetHeight(thePixelBuffer);
        ci_originalImage = [CIImage imageWithCVPixelBuffer:thePixelBuffer];
        ci_userTempImage = [ci_originalImage imageByApplyingTransform:CGAffineTransformMakeScale(0.6, 0.6)];
        //        CGImageRef UICG_image = [context createCGImage:ci_userTempImage fromRect:[ci_userTempImage extent]];
        double angle = theAngle;
        angle = angle+M_PI;
        double scalingFact = ScalingFactorForAngle(angle, CGSizeMake(w, h));
        
        CGAffineTransform transform =  CGAffineTransformMakeTranslation(w/2.0, h/2.0);
        transform = CGAffineTransformRotate(transform, angle);
        transform = CGAffineTransformTranslate(transform, -w/2.0, -h/2.0);
        //rotate it by applying a transform
        ci_transformedImage = [ci_originalImage imageByApplyingTransform:transform];

        CVPixelBufferLockBaseAddress(thePixelBuffer, 0);

        CGRect extentR = [ci_transformedImage extent];
        CGPoint centerP = CGPointMake(extentR.size.width/2.0+extentR.origin.x,
                                      extentR.size.height/2.0+extentR.origin.y);
        CGSize scaledSize = CGSizeMake(w*scalingFact, h*scalingFact);
        CGRect cropRect = CGRectMake(centerP.x-scaledSize.width/2.0, centerP.y-scaledSize.height/2.0,
                                     scaledSize.width, scaledSize.height);

        CGImageRef cg_img = [context createCGImage:ci_transformedImage fromRect:cropRect];
        ci_transformedImage = [CIImage imageWithCGImage:cg_img];

        ci_transformedImage = [ci_transformedImage imageByApplyingTransform:CGAffineTransformMakeScale(1.0/scalingFact, 1.0/scalingFact)];
        [context render:ci_transformedImage toCVPixelBuffer:thePixelBuffer bounds:CGRectMake(0, 0, w, h) colorSpace:NULL];

        CGImageRelease(cg_img);
        CVPixelBufferUnlockBaseAddress(thePixelBuffer, 0);
        context = nil;
    }
}

// 调用示例
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    if (!next) { return; }
    next = NO;

    AECapturedTools *tools = [[AECapturedTools alloc] initWithFrame:frame];
    CVPixelBufferRef pixelBuffer = tools.rgbPixel;
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    UIDevice *device = [UIDevice currentDevice];
    UIInterfaceOrientation type = UIInterfaceOrientationPortrait;
    switch (device.orientation) {
        case UIDeviceOrientationLandscapeLeft:
            RotatePixelBufferToAngle(pixelBuffer, radians(270));
            type = UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
          RotatePixelBufferToAngle(pixelBuffer, radians(90));
            break;
       case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            break;
       case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
      }
}

```

