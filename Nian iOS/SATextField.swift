//
//  SATextField.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

protocol delegateInput {
    
    /* 获取键盘高度 */
    var keyboardHeight: CGFloat { get set }
    var Locking: Bool { get set }
    
    /* 按下 Send 后的操作 */
    func send()
    
    /* 每次键盘或者该视图发生变化都要调用这个参数 */
    func resize()
}

class InputView: UIView, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    let heightCell: CGFloat = 56
    let widthImageHead: CGFloat = 32
    let heightImageHead: CGFloat = 32
    let padding: CGFloat = 16
    let heightInputMax: CGFloat = 75
    let widthEmoji: CGFloat = 44
    var delegate: delegateInput?
    var heightInputOneLine: CGFloat = 0
    var imageEmoji: UIImageView!
    var isEmojing = false
    var viewEmoji: UIView!
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var collectionView: UICollectionView!
    
    /* 当前选择的图片 */
    var current = 0
    
    /* 表情键盘的高度 */
    let heightEmoji: CGFloat = 224
    
    
    var labelPlaceHolder: UILabel!
    
    /* 输入框 */
    var inputKeyboard: UITextView!
    
    /* 输入框的头像 */
    var imageHead: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, globalHeight - heightCell, globalWidth, 56))
        self.backgroundColor = UIColor.BackgroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        /* 输入框 */
        inputKeyboard = UITextView()
        inputKeyboard.frame = CGRectMake(padding * 2 + widthImageHead, 0, globalWidth - padding * 3 - widthEmoji - widthImageHead, 0)
        inputKeyboard.font = UIFont.systemFontOfSize(12)
        inputKeyboard.returnKeyType = UIReturnKeyType.Send
        inputKeyboard.delegate = self
        heightInputOneLine = resize()
        inputKeyboard.setY((heightCell - heightInputOneLine)/2)
        
        /* 输入框左侧的头像 */
        imageHead = UIImageView(frame: CGRectMake(padding, (heightCell - heightImageHead)/2, widthImageHead, heightImageHead))
        imageHead.setHead(SAUid())
        imageHead.layer.cornerRadius = 16
        imageHead.layer.masksToBounds = true
        
        /* placeHolder */
        labelPlaceHolder = UILabel(frame: CGRectMake(5, 0, inputKeyboard.width(), heightInputOneLine))
        labelPlaceHolder.text = "回应一下！"
        labelPlaceHolder.textColor = UIColor.secAuxiliaryColor()
        labelPlaceHolder.font = UIFont.systemFontOfSize(12)
        
        self.addSubview(inputKeyboard)
        self.addSubview(imageHead)
        inputKeyboard.addSubview(labelPlaceHolder)
        
        /* 表情输入 */
        imageEmoji = UIImageView(frame: CGRectMake(globalWidth - widthEmoji - padding, (heightCell - widthEmoji) / 2, widthEmoji, widthEmoji))
        imageEmoji.image = UIImage(named: "keyemoji")
        self.addSubview(imageEmoji)
        
        /* 分割线 */
        let viewLine = UIView(frame: CGRectMake(0, 0, globalWidth, globalHalf))
        viewLine.backgroundColor = UIColor.LineColor()
        self.addSubview(viewLine)
        
        /* 绑定事件 */
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTap"))
        self.userInteractionEnabled = true
        imageEmoji.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onEmoji"))
        imageEmoji.userInteractionEnabled = true
        
        /* 表情键盘构建 */
        viewEmoji = UIView(frame: CGRectMake(0, globalHeight, globalWidth, heightEmoji))
        viewEmoji.backgroundColor = UIColor.BackgroundColor()
        viewEmoji.hidden = true
        
        /* 默认是 iPhone 6 */
        var paddingH: CGFloat = 20
        var paddingV: CGFloat = 8
        var w = (heightEmoji - 44 - paddingV * 2)/2
        
        /* iPhone 4 */
        if globalWidth == 320 {
            paddingH = 0
            paddingV = (heightEmoji - globalWidth/2 - 44) / 2
            w = globalWidth/4
        } else if globalWidth == 414 {
            /* iPhone 6 Plus */
            paddingH = 0
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: paddingV, left: paddingH, bottom: paddingV, right: paddingH)
        collectionView = UICollectionView(frame: CGRectMake(0, 0, globalWidth, heightEmoji - 44), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.registerNib(UINib(nibName: "EmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCollectionCell")
        collectionView.alwaysBounceHorizontal = true
        viewEmoji.addSubview(collectionView)
        
        let v1 = UIView(frame: CGRectMake(0, 0, globalWidth, globalHalf))
        v1.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v1)
        
        let v2 = UIView(frame: CGRectMake(0, heightEmoji - 44 - globalHalf, globalWidth, globalHalf))
        v2.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v2)
        
        /* 可滚动的表情选择 */
        tableView = UITableView()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tableView.frame = CGRectMake(0, heightEmoji - 44, globalWidth - 44, 44)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "EmojiCell", bundle: nil), forCellReuseIdentifier: "EmojiCell")
        viewEmoji.addSubview(tableView)
        
        let imageStore = UIImageView(frame: CGRectMake(globalWidth - 44, heightEmoji - 44, 44, 44))
        imageStore.image = UIImage(named: "keysettings")
        viewEmoji.addSubview(imageStore)
        
        load()
    }
    
    /* 弹起系统自带键盘 */
    func onTap() {
        inputKeyboard.becomeFirstResponder()
        resignEmoji()
    }
    
    /* 移除表情键盘 */
    func resignEmoji() {
        self.isEmojing = false
        imageEmoji.image = UIImage(named: "keyemoji")
        if let v = viewEmoji {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                v.setY(globalHeight)
                }, completion: { (Bool) -> Void in
                    v.removeFromSuperview()
            })
        }
    }
    
    /* 点击表情按钮 */
    func onEmoji() {
        /* 如果不是表情键盘 */
        if !isEmojing {
            self.isEmojing = true
            imageEmoji.image = UIImage(named: "keyboard")
            delegate?.Locking = true
            self.delegate?.keyboardHeight = heightEmoji
            inputKeyboard.resignFirstResponder()
            viewEmoji.hidden = false
            /* 设置表情的界面 */
            self.findRootViewController()?.view.addSubview(viewEmoji)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.delegate?.resize()
                self.viewEmoji.setY(globalHeight - self.heightEmoji)
                }) { (Bool) -> Void in
                    self.delegate?.Locking = false
            }
            
        } else {
            /* 如果是表情键盘，弹出自带键盘 */
            onTap()
        }
    }
    
    /* 根据内容来调整输入框高度 */
    func resize() -> CGFloat {
        let size = CGSizeMake(inputKeyboard.contentSize.width, CGFloat.max)
        let h = min(inputKeyboard.sizeThatFits(size).height, heightInputMax)
        self.inputKeyboard.frame.size.height = h
        return h
    }
    
    /* 根据输入框高度来调整整个视图 */
    func resizeView(heightInput: CGFloat) -> CGFloat {
        let h = heightInput + heightCell - heightInputOneLine
        let heightOrigin = self.height()
        if h != heightOrigin {
            self.imageHead.setY(heightOrigin - self.imageHead.height() - (self.heightCell - self.imageHead.height()) / 2)
            self.imageEmoji.setY(heightOrigin - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
            self.setY(globalHeight - heightOrigin - delegate!.keyboardHeight)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageHead.setY(h - self.imageHead.height() - (self.heightCell - self.imageHead.height()) / 2)
                self.imageEmoji.setY(h - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
                self.setHeight(h)
                self.delegate?.resize()
            })
        }
        return h
    }
    
    func load() {
        if let emojis = Cookies.get("emojis") as? NSMutableArray {
            var i = 0
            for _emoji in emojis {
                if let emoji = _emoji as? NSDictionary {
                    let e = NSMutableDictionary(dictionary: emoji)
                    let isClicked = i == 0 ? "1" : "0"
                    e.setValue(isClicked, forKey: "isClicked")
                    dataArray.addObject(e)
                }
                i++
            }
            tableView.reloadData()
        }
        // todo: 判断没有的情况？！
    }
}