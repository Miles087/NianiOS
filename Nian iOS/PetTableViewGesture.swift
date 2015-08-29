//
//  PetTableViewGesture.swift
//  Nian iOS
//
//  Created by Sa on 15/7/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController: NIAlertDelegate {
    
    func showPetInfo() {
        petDetailView = NIAlert()
        petDetailView?.delegate = self
        let data = dataArray[current] as! NSDictionary
        let name = data.stringAttributeForKey("name")
        let level = data.stringAttributeForKey("level")
        let owned = data.stringAttributeForKey("owned")
        let description = data.stringAttributeForKey("description")
        var content = description
        
        var titleButton = "哦"
        if owned == "1" {
            titleButton = "分享"
            if let _level = Int(level) {
                let _tmp = 5 - _level % 5
                if _level  < 10 {
                    content += "\n\n（距离下次进化还有 \(_tmp) 级）"
                } else if _level < 15 {
                    content += "\n\n（距离满级还有 \(_tmp) 级）"
                } else if _level == 15 {
                    content += "\n\n（这只宠物满级了！）"
                }
            }
        } else {
            content += "\n\n（还没获得这个宠物...）"
        }
        petDetailView?.dict = NSMutableDictionary(objects: [self.imageView, name, content, [titleButton]],
            forKeys: ["img", "title", "content", "buttonArray"])
        petDetailView?.showWithAnimation(.flip)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }
        return true
    }
}

extension UIImageView {
    
    /**
    已知此方法就是为了加载灰度图片，所以
    思路：先生成一个假的 API, 加载缓存的灰度图片，不然就去请求网络图片
    
    - parameter urlString: <#urlString description#>
    */
    func setImageGray(urlString: String) {
        // 生成灰度图片
        let _urlString = urlString + "Gray"
        let _req = NSURLRequest(URL: NSURL(string: _urlString)!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
        
        if let cachedImage = UIImageView.self.sharedImageCache().cachedImageForRequest(_req) {
            self.image = cachedImage
        } else {
            let url = NSURL(string: urlString)
            self.image = nil
            self.backgroundColor = UIColor.clearColor()
            let req = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 60)
            self.setImageWithURLRequest(req,
                placeholderImage: nil,
                success: { [unowned self] (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                    self.image = image.convertToGrayscale()
                    self.contentMode = .ScaleAspectFill
                    
                    // 缓存灰度图片，对应的是生成的假的 _req
                    UIImageView.self.sharedImageCache().cacheImage(self.image, forRequest: _req)
                },
                failure: nil)}
    }
}