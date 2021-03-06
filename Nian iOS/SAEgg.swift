//
//  SAEgg.swift
//  Nian iOS
//
//  Created by Sa on 15/7/16.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import SpriteKit

@objc protocol ShareDelegate {
    /* 当抽到新宠物时，点击分享弹出调用 onShare */
    func onShare(_ avc: UIActivityViewController)
    @objc optional func saEgg(_ saEgg: SAEgg, tapBackground: Bool)
    @objc optional func saEgg(_ saEgg: SAEgg, lotteryResult: NSDictionary)
}

class SAEgg: NIAlert, NIAlertDelegate {
    var confirmNiAlert = NIAlert()
    var lotteryNiAlert = NIAlert()
    var planktonNiAlert = NIAlert()
    var coinLessNiAlert = NIAlert()
    var petData: NSDictionary!
    var delegateShare: ShareDelegate?
    var skView: SKView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func niAlert(_ niAlert: NIAlert, tapBackground: Bool) {
        // 点击了 saEgg 的 background ，然后交给 delegate 处理
        delegateShare?.saEgg?(self, tapBackground: true)
        
        if niAlert == self {
            self.dismissWithAnimation(.normal)
        } else if niAlert == self.confirmNiAlert {
            self.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        } else if niAlert == self.lotteryNiAlert {
            self.dismissWithAnimation(.normal)
            self.lotteryNiAlert.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        } else if niAlert == self.coinLessNiAlert {
            self.dismissWithAnimation(.normal)
            self.coinLessNiAlert.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        } else if niAlert == self.planktonNiAlert {
            self.dismissWithAnimation(.normal)
            self.planktonNiAlert.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        }
    }
    
    func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self {
            if didselectAtIndex == 1 {
                niAlert.dismissWithAnimation(.normal)
            } else if didselectAtIndex == 0 {
                // 确认抽蛋页面
                self.confirmNiAlert.delegate = self
                self.confirmNiAlert.dict = NSMutableDictionary(objects: ["", "抽蛋", "在上方随便选一个蛋！", []],
                    forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                let img1 = self.setupEgg(40, named: "pet_egg1")
                let img2 = self.setupEgg(104, named: "pet_egg2")
                let img3 = self.setupEgg(168, named: "pet_egg3")
                img1.tag = 1
                img2.tag = 2
                img3.tag = 3
                self.confirmNiAlert._containerView?.addSubview(img1)
                self.confirmNiAlert._containerView?.addSubview(img2)
                self.confirmNiAlert._containerView?.addSubview(img3)
                self.dismissWithAnimationSwtich(self.confirmNiAlert)
            }
        } else if niAlert == lotteryNiAlert {
            if didselectAtIndex == 0 {
                let card = (Bundle.main.loadNibNamed("Card", owner: self, options: nil))?.first as! Card
                let petName = self.petData.stringAttributeForKey("name")
                let petImage = self.petData.stringAttributeForKey("image")
                let content = "我在念里拿到了可爱的「\(petName)」"
                card.content = content
                card.widthImage = "360"
                card.heightImage = "360"
                card.url = "http://img.nian.so/pets/\(petImage)!d"
                let img = card.getCard()
                let avc = SAActivityViewController.shareSheetInView([img, content as AnyObject], applicationActivities: [], isStep: true)
                delegateShare?.onShare(avc)
            } else if didselectAtIndex == 1 {
                self.dismissWithAnimation(.normal)
                self.confirmNiAlert.dismissWithAnimation(.normal)
                self.lotteryNiAlert.dismissWithAnimation(.normal)
            }
        } else if niAlert == planktonNiAlert {
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.planktonNiAlert.imgView?.setX(-150)
                self.planktonNiAlert.imgView?.alpha = 0
                }, completion: { (Bool) -> Void in
                    self.dismissWithAnimation(.normal)
                    self.confirmNiAlert.dismissWithAnimation(.normal)
                    self.planktonNiAlert.dismissWithAnimation(.normal)
            })
        } else if niAlert == coinLessNiAlert {
            self.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
            self.coinLessNiAlert.dismissWithAnimation(.normal)
        }
    }
    
    @objc func onEggTouchDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    @objc func onEggTouchCancel(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
    }
    
    @objc func onEggTouchUp(_ sender: UIButton) {
        let tag = sender.tag
        sender.backgroundColor = UIColor.clear
        self.confirmNiAlert.titleLabel?.isHidden = true
        self.confirmNiAlert.contentLabel?.isHidden = true
        for view: AnyObject in self.confirmNiAlert._containerView!.subviews {
            if view is UIButton {
                if view as! UIButton != sender {
                    (view as! UIButton).removeFromSuperview()
                }
            }
        }
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            sender.setX(104)
        })
        let ac = UIActivityIndicatorView(frame: CGRect(x: 121, y: 150, width: 30, height: 30))
        ac.color = UIColor.HighlightColor()
        ac.isHidden = false
        ac.startAnimating()
        self.confirmNiAlert._containerView!.addSubview(ac)
        Api.postPetLottery(tag) { json in
            if json != nil {
                if let j = json as? NSDictionary {
                    let err = j.stringAttributeForKey("error")
                    if err == "0" {
                        // 抽到宠物
                        self.petData = (json!.object(forKey: "data") as! NSDictionary).object(forKey: "pet") as! NSDictionary
                        let petName = self.petData.stringAttributeForKey("name")
                        let petImage = self.petData.stringAttributeForKey("image")
                        let isOwned = self.petData.stringAttributeForKey("own")
                        if let coin = Cookies.get("coin") as? String {
                            if let _coin = Int(coin) {
                                let coinNew = _coin - 3
                                Cookies.set("\(coinNew)" as AnyObject?, forKey: "coin")
                            }
                        }
                        if isOwned == "0" {
                            // 此前没有这个宠物，出现宠物
                            self.lotteryNiAlert.delegate = self
                            self.lotteryNiAlert.dict = NSMutableDictionary(objects: ["http://img.nian.so/pets/\(petImage)!d", petName, "你获得了一个\(petName)", ["分享", "好"]],
                                                                           forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                            self.confirmNiAlert.dismissWithAnimationSwtich(self.lotteryNiAlert)
                            self.delegateShare?.saEgg?(self, lotteryResult: self.petData)
                        } else {
                            // 拥有这个宠物了，本地出现浮游生物
                            let arrayContent = ["虽然没有抽到宠物\n但你抽到了一个抱抱","作为一个烧麦\n不知道被吃掉\n是幸运还是不幸呀","(・ω・) -__- )・∀・)\n好挤呀","今天我从天空飘着时\n看到地上有个\n可爱的女孩子在玩念","我们还会见面的！\n吖，别摔手机啊","作为一个医生\n我每天都被自己帅晕","打劫念币啦","谢谢你的念币\n终于凑够钱买别墅了","不好意思\n跑错片场了","谢谢你喂我\n我已经快十分钟没吃过东西了","是 你 在 召 唤 我 吗","同样是独角\n为什么它是传说中的宠物\n而我只能做美男子呢","你说你原本想抽的不是我？\n我的心碎了","如果看到一只拉风的炸鸡\n接下来一辈子都会交好运","我妈说花开的时候\n就会遇到真爱","每当有人对我说 \ngive me five 的时候\n我都既快乐又困扰"]
                            
                            // 当前版本的浮游生物总数量
                            let num = arrayContent.count
                            
                            // 我拥有浮游总数
                            var count = 1
                            
                            // 当前要显示的浮游生物编号
                            var id = 1
                            
                            if let _idPlankton = Cookies.get("plankton") as? String {
                                if let _idTemp = Int(_idPlankton) {
                                    let next = _idTemp + 1
                                    
                                    if next > num {
                                        // 如果全部获得了
                                        count = num
                                        id = getRandomNumber(1, to: num)
                                    } else {
                                        // 如果还没全部获得
                                        count = next
                                        id = next
                                        Api.getPlanktonIncrease() { json in
                                            
                                        }
                                    }
                                }
                            }
                            
                            self.planktonNiAlert.delegate = self
                            self.planktonNiAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pet\(id)")!, "浮游生物", "\(arrayContent[id - 1])", ["拜拜"]],
                                                                            forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                            self.confirmNiAlert.dismissWithAnimationSwtich(self.planktonNiAlert)
                            Cookies.set("\(count)" as AnyObject?, forKey: "plankton")
                        }
                    } else if err == "2" {
                        self.coinLessNiAlert.delegate = self
                        self.coinLessNiAlert.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "念币不足", "没有足够的念币...", ["哦"]],
                                                                        forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                        self.confirmNiAlert.dismissWithAnimationSwtich(self.coinLessNiAlert)
                    } else {
                        self.coinLessNiAlert.delegate = self
                        self.coinLessNiAlert.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "奇怪的错误", "遇到了一个奇怪的错误", ["哦"]],
                                                                        forKeys: ["img" as NSCopying, "title" as NSCopying, "content" as NSCopying, "buttonArray" as NSCopying])
                        self.confirmNiAlert.dismissWithAnimationSwtich(self.coinLessNiAlert)
                    }
                }
            }
        }
    }
    
    func setupEgg(_ x: CGFloat, named: String) -> UIButton {
        let button = UIButton(frame: CGRect(x: x, y: 40, width: 64, height: 80))
        button.addTarget(self, action: #selector(SAEgg.onEggTouchDown(_:)), for: UIControlEvents.touchDown)
        button.addTarget(self, action: #selector(SAEgg.onEggTouchDown(_:)), for: UIControlEvents.touchDragInside)
        button.addTarget(self, action: #selector(SAEgg.onEggTouchUp(_:)), for: UIControlEvents.touchUpInside)
        button.addTarget(self, action: #selector(SAEgg.onEggTouchCancel(_:)), for: UIControlEvents.touchDragOutside)
        button.setBackgroundImage(UIImage(named: named), for: UIControlState())
        button.setBackgroundImage(UIImage(named: named), for: UIControlState.highlighted)
        button.layer.cornerRadius = 8
        return button
    }
}
