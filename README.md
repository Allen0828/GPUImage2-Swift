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
