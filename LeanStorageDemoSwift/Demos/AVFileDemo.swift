//
//  AVFileDemo.swift
//  LeanStorageDemoSwift
//
//  Created by lzw on 15/9/1.
//  Copyright (c) 2015年 微信:  lzwjava. All rights reserved.
//

import UIKit
import AVOSCloud

class AVFileDemo: Demo {
    func demoCreateFile() {
        var data: NSData = NSData(contentsOfFile: (NSBundle.mainBundle().pathForResource("cloud", ofType: "png"))!)!
        var file: AVFile = AVFile.fileWithName("cloud.png", data: data) as! AVFile
        file.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if (self.filterError(error)) {
                self.log("文件已经保存到服务器:[\(file.objectId)] file:\(file.url)")
            }
        }
        logThreadTips()
    }
    
    func demoFromPathCreateFile() {
        var file: AVFile = AVFile.fileWithName("cloud.png", contentsAtPath: NSBundle.mainBundle().pathForResource("cloud", ofType: "png")) as! AVFile
        file.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if (self.filterError(error)) {
                self.log("文件已经保存到服务器:[\(file.objectId)] \(file.url)")
            }
        }
    }
    
    func getDemoFile(block : (file: AVFile!) -> Void) {
        AVFile.getFileWithObjectId("5573fddee4b06a32094af62b", withBlock: { (file: AVFile?, error: NSError?) -> Void in
            if self.filterError(error) {
                block(file:file)
            }
        })
    }
    
    func demoDeleteFile() {
        var file: AVFile = AVFile.fileWithName("cloud.png", contentsAtPath: NSBundle.mainBundle().pathForResource("cloud", ofType: "png")) as! AVFile
        file.save()
        
        file.deleteInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
            if (self.filterError(error)) {
                self.log("文件[\(file.objectId)] 已经删除")
            }
        })
    }
    
    func demoWithFileIdGetFile() {
        getDemoFile { (file) -> Void in
            self.log("获取成功: \(file?.description)")
            file!.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) in
                if self.filterError(error) {
                    var image: UIImage = UIImage(data: data!, scale: UIScreen.mainScreen().scale)!
                    self.showImage(image)
                    self.log("成功得到图片: \(image.description)")
                }
                }, progressBlock: {(percentDone: Int) in
                    self.log("加载进度: \(percentDone)%%")
            })
        }
    }
    
    func demoFileMetaData() {
        var path: String = NSBundle.mainBundle().pathForResource("cloud", ofType: "png")!
        var image: UIImage = UIImage(contentsOfFile: path)!
        var imageData: NSData = UIImageJPEGRepresentation(image, 0.8)
        var file: AVFile = AVFile.fileWithData(imageData) as! AVFile
        file.metaData.setObject(image.size.width, forKey: "width")
        file.metaData.setObject(image.size.height, forKey: "height")
        file.metaData.setObject("LeanCloud", forKey: "author")
        file.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
            if self.filterError(error) {
                self.log("保存文件成功，同时关联了许多元数据 metaData : %@",file.metaData)
            }
        })
    }
    
    
    func demoThumbnail() {
        getDemoFile { (file) -> Void in
            file!.getThumbnail(false, width: 100, height: 100, withBlock: {(image: UIImage?, error: NSError?) in
                if self.filterError(error) {
                    self.showImage(image!)
                    self.log("成功获取宽高为100的缩略图")
                }
            })
        }
    }
    
    func demoCombineQiniuApi() {
        getDemoFile { (file) -> Void in
            var thumbnailFile: AVFile = AVFile.fileWithURL("\(file!.url)?imageView/1/w/50/h/100") as! AVFile
            thumbnailFile.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) in
                if self.filterError(error) {
                    var image: UIImage = UIImage(data: data!, scale: UIScreen.mainScreen().scale)!
                    self.showImage(image)
                    self.log("成功用七牛接口获得缩略图")
                }
            })
        }
    }
    
    func demoFileLocalPath() {
        getDemoFile { (file) -> Void in
            self.log("保存了文件，文件本地路径为：\(file.localPath())")
        }
    }
    
    func demoClearFileCache() {
        AVFile.clearAllCachedFiles()
        self.log("清除了全部文件的缓存，请运行用文件ID获取文件的例子，会看到下载进度多次被回调")
    }
   
}