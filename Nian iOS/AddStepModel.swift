//
//  AddStepModel.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AddStepModel: NSObject {

    /**
     <#Description#>
     
     - parameter content:  <#content description#>
     - parameter stepType: <#stepType description#>
     - parameter images:   <#images description#>
     - parameter callback: <#callback description#>
     */
    
    // todo: 可以编辑自己的进展吗？
    // todo: 可以删除自己的进展吗？
    // todo: 接受邀请后应该在本地插入一个那个记本
    class func postAddStep(content content: String, stepType: Int, images: NSArray, dreamId: String, callback: NetworkClosure) {
        let _uid = CurrentUser.sharedCurrentUser.uid!
        let _shell = CurrentUser.sharedCurrentUser.shell!
        
        
        let jsonString = try! NSJSONSerialization.dataWithJSONObject(images, options: NSJSONWritingOptions.PrettyPrinted)
        let imagesString = NSString(data: jsonString, encoding: NSUTF8StringEncoding)!
        
        NianNetworkClient.sharedNianNetworkClient.post(
            "multidream/\(dreamId)/update?uid=\(_uid)&&shell=\(_shell)",
            content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"],
            callback: callback)
    }
    
    
    /**
     <#Description#>
     
     - parameter content:  <#content description#>
     - parameter stepType: <#stepType description#>
     - parameter sid:      <#sid description#>
     - parameter images:   <#images description#>
     - parameter dreamId:  <#dreamId description#>
     - parameter callback: <#callback description#>
     */
    class func postEditStep(content content: String, stepType: Int, images: NSArray, sid: String, callback: NetworkClosure) {
        let _uid = CurrentUser.sharedCurrentUser.uid!
        let _shell = CurrentUser.sharedCurrentUser.shell!
    
        let jsonString = try! NSJSONSerialization.dataWithJSONObject(images, options: NSJSONWritingOptions.PrettyPrinted)
        let imagesString = NSString(data: jsonString, encoding: NSUTF8StringEncoding)!
    
        NianNetworkClient.sharedNianNetworkClient.post(
            "v2/step/\(sid)/edit?uid=\(_uid)&shell=\(_shell)",
            content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"],
            callback: callback)
    }
    
    
    
    
    
    
    
}
