//
//  TopicCellHeader.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicCell: UITableViewCell {
    
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewUp: UIImageView!
    @IBOutlet var viewDown: UIImageView!
    @IBOutlet var viewVoteLine: UIView!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var labelNum: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelComment: UILabel!
    @IBOutlet var btnMore: UIButton!
    var data: NSDictionary!
    var index: Int = 0
    
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.selectionStyle = .None
        viewUp.setVote()
        viewDown.setVote()
        labelContent.setWidth(globalWidth - 80)
        viewBottom.setWidth(globalWidth - 80)
        viewLine.setWidth(globalWidth - 80)
        viewLine.setHeight(0.5)
        viewVoteLine.setHeight(0.5)
        btnMore.setX(globalWidth - 80 - 35)
        btnMore.layer.borderColor = lineColor.CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            let content = data.stringAttributeForKey("content").decode()
            let uid = data.stringAttributeForKey("uid")
            let name = data.stringAttributeForKey("user")
            let lastdate = data.stringAttributeForKey("lastdate")
            let time = V.relativeTime(lastdate)
            var comment = "12"
            comment = "回应 \(comment)"
//            let num = SAThousand(data.stringAttributeForKey("reply"))
            let num = "32"
            
            // 计算高度与宽度
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            let hComment = comment.stringWidthWith(13, height: 32) + 16
            
            // 填充内容
            labelContent.text = content
            labelNum.text = num
            labelTime.text = time
            imageHead.setHead(uid)
            labelName.text = name
            labelNum.text = num
            labelComment.text = comment
            
            // 设定高度与宽度
            labelContent.setHeight(hContent)
            viewBottom.setY(labelContent.bottom() + 16)
            viewLine.setY(viewBottom.bottom() + 24)
            labelComment.setWidth(hComment)
            
            // 上按钮
            viewUp.layer.borderColor = UIColor.e6().CGColor
            viewUp.backgroundColor = UIColor.whiteColor()
            labelNum.textColor = UIColor.b3()
            viewVoteLine.backgroundColor = UIColor.e6()
            viewUp.image = UIImage(named: "voteup")
            // 下按钮
            viewDown.layer.borderColor = UIColor.e6().CGColor
            viewDown.backgroundColor = UIColor.whiteColor()
        }
    }
}