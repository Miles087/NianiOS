//
//  SearchCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import Foundation
import UIKit

class searchResultCell: MKTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var footView: UIView!
    
    var uid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headImageView.layer.cornerRadius = 4.0
        self.headImageView.layer.masksToBounds = true
        self.headImageView.contentMode = .Center
        self.footView.setWidth(globalWidth - 70)
        self.footView.setX(70)
        self.followButton.layer.cornerRadius = 15
        self.followButton.layer.masksToBounds = true
        self.followButton.setX(globalWidth - 85)
    }
    
    func bindData(data: ExploreSearch.DreamSearchData, tableView: UITableView) {
        self.title.text = SADecode(data.title.stringByDecodingHTMLEntities())
        self.content.text = SADecode(data.content.stringByDecodingHTMLEntities())
        self.uid = data.uid
        self.headImageView.setImage("http://img.nian.so/dream/\(data.img)!dream", placeHolder: IconColor)
        self.headImageView.tag = data.id.toInt()!
        
        if data.follow == "0" {
            self.followButton.tag = 100
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
        } else {
            self.followButton.tag = 200
            self.followButton.layer.borderWidth = 0
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.followButton.backgroundColor = SeaColor
            self.followButton.setTitle("关注中", forState: .Normal)
        }
    }
    
    @IBAction func follow(sender: UIButton) {
        var tag = sender.tag
        if tag == 100 {     //没有关注
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "1", callback: {
                    String in
                    if String == "fo"{
                    } else if String == "err" {
                    }
                })
            })
        }else if tag == 200 {   //正在关注
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "0", callback: {
                    String in
                    if String == "" {
                    } else if String == "err" {
                    }
                })
            })
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.headImageView.cancelImageRequestOperation()
        self.headImageView.image = nil
    }
    
}

class dreamSearchStepCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageContent: UIImageView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewControl: UIView!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnUnlike: UIButton!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var viewLine: UIView!
    
    var cellData: ExploreSearch.DreamStepData?
    var uid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.followButton.setX(globalWidth-15-70)
        self.labelDream.setWidth(globalWidth-148)
        self.viewControl.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
        self.viewLine.setWidth(globalWidth)
        self.btnLike.setX(globalWidth-50)
        self.btnUnlike.setX(globalWidth-50)
        self.btnMore.setX(globalWidth-90)
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnUnlike.addTarget(self, action: "onUnlikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.followButton.layer.cornerRadius = 15.0
        self.followButton.layer.masksToBounds = true
        self.followButton.addTarget(self, action: "onFollowClick:", forControlEvents: .TouchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        self.imageHead.image = nil
        self.imageContent.cancelImageRequestOperation()
        self.imageContent.image = nil
    }
    
    func bindData(data: ExploreSearch.DreamStepData, tableview: UITableView) {
        cellData = data
        var imageDelta: CGFloat =  0
        var textHeight = data.content.stringHeightWith(16, width: globalWidth-30)
        if data.content == "" {
            textHeight = 0
        }
        var textDelta = CGFloat(textHeight - labelContent.height())
        labelContent.setHeight(textHeight)
        if !data.img0!.isZero && !data.img1!.isZero {     //有图片
            imageDelta = CGFloat(data.img1 * Float(globalWidth) / data.img0)
            
            imageContent.setImage(V.urlStepImage(data.img, tag: .Large), placeHolder: IconColor)
            imageContent.setHeight(imageDelta)
            imageContent.setWidth(globalWidth)
            imageContent.setX(0)
            imageContent.hidden = false
            labelContent.setY(imageContent.bottom() + 15)
        }else if data.content == "" {
            imageContent.image = UIImage(named: "check")
            imageContent.setHeight(23)
            imageContent.setWidth(50)
            imageContent.setX(15)
            imageContent.hidden = false
            labelContent.setY(imageContent.bottom() + 15)
        }else{
            imageContent.hidden = true
            labelContent.setY(70)
        }
        if data.content == "" {
            viewControl.setY(labelContent.bottom()-10)
        }else{
            viewControl.setY(labelContent.bottom()+5)
        }
        viewLine.setY(viewControl.bottom()+10)
        imageHead.setHead(data.uid)
        
        labelName.text = SADecode(data.user.stringByDecodingHTMLEntities())
        labelDream.text = SADecode(data.title.stringByDecodingHTMLEntities())
        labelContent.text = SADecode(data.content.stringByDecodingHTMLEntities())
        self.uid = data.uid
        var liked = (data.liked != nil && data.liked != 0)
        btnLike.hidden = liked
        btnUnlike.hidden = !liked
        setCommentText(data.comment)
        setLikeText(data.like)
        
        if data.follow == "0" {
            self.followButton.tag = 100
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
        } else {
            self.followButton.tag = 200
            self.followButton.layer.borderWidth = 0
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = SeaColor
            self.followButton.setTitle("关注中", forState: .Normal)
        }
    }
    
    func onFollowClick(sender: UIButton) {
        var tag = sender.tag
        if tag == 100 {     //没有关注
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "1", callback: {
                    String in
                    if String == "fo" {
                    } else {
                    }
                })
                
            })
        }else if tag == 200 {   //正在关注
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "0", callback: {
                    String in
                    if String == " " {
                    } else {
                    }
                })
            })
        }
        
    }
    
    func setLikeText(like: Int) {
        if like == 0 {
            self.labelLike.hidden = true
        }else{
            self.labelLike.hidden = false
        }
        var likeText = "\(like) 赞"
        labelLike.text = likeText
        var likeWidth = likeText.stringWidthWith(13, height: 30) + 17
        labelLike.setWidth(likeWidth)
    }
    
    func setCommentText(comment: Int) {
        var commentText = ""
        if comment != 0 {
            commentText = "\(comment) 评论"
        }else{
            commentText = "评论"
        }
        labelComment.text = commentText
        var commentWidth = commentText.stringWidthWith(13, height: 30) + 17
        labelComment.setWidth(commentWidth)
        labelLike.setX(commentWidth + 23)
    }
    
    func onLikeClick() {
        self.cellData!.liked = 1
        self.btnLike.hidden = true
        self.btnUnlike.hidden = false
        self.cellData!.like = self.cellData!.like + 1
        self.setLikeText(self.cellData!.like)
        Api.postLikeStep(cellData!.sid, like: 1) {
            result in
            if result != nil && result == "1" {
            }
        }
    }
    
    func onUnlikeClick() {
        self.cellData!.liked = 0
        self.btnLike.hidden = false
        self.btnUnlike.hidden = true
        self.cellData!.like = self.cellData!.like - 1
        self.setLikeText(self.cellData!.like)
        Api.postLikeStep(cellData!.sid, like: 0) {
            result in
            if result != nil && result == "1" {
            }
        }
    }
    
    class func heightWithData(content: String, w: Float, h: Float) -> CGFloat {
        var height = content.stringHeightWith(16, width: globalWidth-30)
        if h == 0.0 || w == 0.0 {
            if content == "" {
                return 156 + 23
            }else{
                return height + 151
            }
        } else {
            if content == "" {
                return 156 + CGFloat(h * Float(globalWidth) / w)
            }else{
                return height + 171 + CGFloat(h * Float(globalWidth) / w)
            }
        }
    }
}
