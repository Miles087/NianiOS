//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: VVeboViewController, UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, editDreamDelegate, topDelegate, ShareDelegate {
    
    var page: Int = 1
    var Id: String = "1"
    var deleteDreamSheet:UIActionSheet?
    var quitSheet: UIActionSheet!
    var navView:UIView!
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    var newEditStepRow: Int = 0
    var newEditStepData: NSDictionary?
    
    var dataArrayTop: NSDictionary!
    
    var SATableView: VVeboTableView!
    var dataArray = NSMutableArray()
    var delegateDelete: DeleteDreamDelegate?
    var willBackToRootViewController = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SATableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
        
        /* 从导航栏栈里删除，只剩下 Home 和当前视图控制器 */
        if willBackToRootViewController {
            var arr = navigationController?.viewControllers
            var arrNew: [UIViewController] = []
            if arr != nil {
                for i in 0...(arr!.count - 1) {
                    if i == 0 || i == arr!.count - 1 {
                        arrNew.append(arr![i])
                    }
                }
                navigationController?.viewControllers = arrNew
            }
        }
    }
    
    func setupViews() {
        self.viewBack()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        self.view.backgroundColor = UIColor.BackgroundColor()
        
        self.SATableView = VVeboTableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.SATableView.delegate = self
        self.SATableView.dataSource = self
        self.SATableView.separatorStyle = .None
        
        let nib = UINib(nibName:"DreamCell", bundle: nil)
        let nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        
        self.SATableView.registerNib(nib, forCellReuseIdentifier: "dream")
        self.SATableView.registerNib(nib2, forCellReuseIdentifier: "dreamtop")
        self.view.addSubview(self.SATableView)
        currenTableView = SATableView
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
    }
    
    func load(clear: Bool = true){
        if clear {
            self.page = 1
        }
        Api.getDreamStep(Id, page: page) { json in
            if json != nil {
                if json!.objectForKey("error") as! NSNumber != 0 {
                    let status = json!.objectForKey("status") as! NSNumber
                    self.SATableView.hidden = true
                    self.navigationItem.rightBarButtonItems = []
                    if status == 404 {
                        self.view.addGhost("这个记本\n不见了")
                    } else if status == 403 {
                        self.view.addGhost("你发现了\n一个私密的记本\n里面记着什么？")
                    } else {
                        self.showTipText("遇到了一个奇怪的错误，代码是 \(status)")
                    }
                } else {
                    let data: AnyObject? = json!.objectForKey("data")
                    if clear {
                        self.dataArrayTop = self.DataDecode(data!.objectForKey("dream") as! NSDictionary)
                        let uid = self.dataArrayTop.stringAttributeForKey("uid")
                        self.dataArray.removeAllObjects()
                        globalVVeboReload = true
                        let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "setupNavBtn")
                        btnMore.image = UIImage(named: "more")
                        let btnInvite = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onInvite")
                        btnInvite.image = UIImage(named: "addFriend")
                        
                        /* 当当前用户是记本主人时，提供邀请入口 */
                        if uid == SAUid() {
                            self.navigationItem.rightBarButtonItems = [btnMore, btnInvite]
                        } else {
                            self.navigationItem.rightBarButtonItems = [btnMore]
                        }
                    } else {
                        globalVVeboReload = false
                    }
                    let steps = data!.objectForKey("steps") as! NSArray
                    for d in steps {
                        let data = VVeboCell.SACellDataRecode(d as! NSDictionary)
                        self.dataArray.addObject(data)
                    }
                    self.currentDataArray = self.dataArray
                    self.SATableView.reloadData()
                    self.SATableView.headerEndRefreshing()
                    self.SATableView.footerEndRefreshing()
                    self.page++
                }
            }
        }
    }
    
    /* 当点击了邀请后 */
    func onInvite() {
        let vc = List()
        vc.type = ListType.Invite
        vc.id = Id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupNavBtn() {
        let uid = dataArrayTop.stringAttributeForKey("uid")
        let percent = dataArrayTop.stringAttributeForKey("percent")
        let title = dataArrayTop.stringAttributeForKey("title")
        let isLiked = dataArrayTop.stringAttributeForKey("isliked")
        let joined = dataArrayTop.stringAttributeForKey("joined")
        
        let acEdit = SAActivity()
        acEdit.saActivityTitle = "编辑"
        acEdit.saActivityType = "编辑"
        acEdit.saActivityImage = UIImage(named: "av_edit")
        acEdit.saActivityFunction = {
            self.editMyDream()
        }
        
        let acDone = SAActivity()
        acDone.saActivityTitle = percent == "0" ? "完成" : "未完成"
        let percentNew = percent == "0" ? "1" : "0"
        let imageNew = percent == "0" ? "av_finish" : "av_nofinish"
        acDone.saActivityType = "完成"
        acDone.saActivityImage = UIImage(named: imageNew)
        acDone.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(percentNew, forKey: "percent")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            Api.postCompleteDream(self.Id, percent: percentNew) { string in
            }
        }
        
        let acDelete = SAActivity()
        acDelete.saActivityTitle = "删除"
        acDelete.saActivityType = "删除"
        acDelete.saActivityImage = UIImage(named: "av_delete")
        acDelete.saActivityFunction = {
            self.deleteDreamSheet = UIActionSheet(title: "再见啦，记本 #\(self.Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteDreamSheet!.addButtonWithTitle("确定删除")
            self.deleteDreamSheet!.addButtonWithTitle("取消")
            self.deleteDreamSheet!.cancelButtonIndex = 1
            self.deleteDreamSheet!.showInView(self.view)
        }
        
        let acLike = SAActivity()
        acLike.saActivityTitle = isLiked == "0" ? "赞" : "取消赞"
        let isLikedNew = isLiked == "0" ? "1" : "0"
        acLike.saActivityType = "赞"
        acLike.saActivityImage = UIImage(named: "av_like")
        acLike.saActivityFunction = {
            let mutableData = NSMutableDictionary(dictionary: self.dataArrayTop)
            mutableData.setValue(isLikedNew, forKey: "isliked")
            self.dataArrayTop = mutableData
            self.SATableView.reloadData()
            Api.postLikeDream(self.Id, like: isLikedNew) { string in }
        }
        
        let acReport = SAActivity()
        acReport.saActivityTitle = "举报"
        acReport.saActivityType = "举报"
        acReport.saActivityImage = UIImage(named: "av_report")
        acReport.saActivityFunction = {
            self.showTipText("举报好了！")
        }
        
        let acQuit = SAActivity()
        acQuit.saActivityTitle = "离开"
        acQuit.saActivityType = "离开"
        acQuit.saActivityImage = UIImage(named: "av_quit")
        acQuit.saActivityFunction = {
            self.quitSheet = UIActionSheet(title: "再见啦，记本 #\(self.Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.quitSheet.addButtonWithTitle("确定退出")
            self.quitSheet.addButtonWithTitle("取消")
            self.quitSheet.cancelButtonIndex = 1
            self.quitSheet.showInView(self.view)
        }
        
        var arr = [acLike, acReport]
        if uid == SAUid() {
            arr = [acDone, acEdit, acDelete]
        } else if joined == "1" {
            arr = [acQuit, acLike, acReport]
        }
        let avc = SAActivityViewController.shareSheetInView(["「\(title)」- 来自念", NSURL(string: "http://nian.so/m/dream/\(self.Id)")!], applicationActivities: arr)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func onStep(){
        if dataArrayTop != nil {
            var title = dataArrayTop.stringAttributeForKey("title").decode()
            if dataArrayTop.stringAttributeForKey("private") == "1" {
                title = "\(title)（私密）"
            } else if dataArrayTop.stringAttributeForKey("percent") == "1" {
                title = "\(title)（完成）"
            }
            UIView.animateWithDuration(0.3, animations: {
                self.SATableView.contentOffset.y = title.stringHeightBoldWith(18, width: 240) + 252 + 52
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("dreamtop", forIndexPath: indexPath) as! DreamCellTop
            c.data = dataArrayTop
            c.delegate = self
            c.setup()
            return c
        } else {
            return getCell(indexPath, dataArray: dataArray, type: 1)
        }
    }
    
    func onFo() {
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("1", forKey: "followed")
        dataArrayTop = mutableData
        SATableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        Api.getFollowDream(id) { json in }
    }
    
    func onUnFo() {
        let id = dataArrayTop.stringAttributeForKey("id")
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue("0", forKey: "followed")
        dataArrayTop = mutableData
        SATableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        Api.getUnFollowDream(id) { json in }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if dataArrayTop != nil {
                if let h = dataArrayTop.objectForKey("heightCell") as? CGFloat {
                    return h
                }
            }
            return 0
        }else{
            return getHeight(indexPath, dataArray: dataArray)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataArrayTop == nil ? 0 : 1
        }else{
            return self.dataArray.count
        }
    }
    
    func onAddStep(){
        let vc = AddStep(nibName: "AddStep", bundle: nil)
        vc.idDream = Id
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func setupRefresh(){
        self.SATableView!.addHeaderWithCallback({
            self.load()
        })
        self.SATableView!.addFooterWithCallback({
            self.load(false)
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除记本
                self.navigationItem.rightBarButtonItems = buttonArray()
                Api.getDeleteDream(self.Id, callback: { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.delegateDelete?.deleteDreamCallback(self.Id)
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        } else if actionSheet == quitSheet {
            /* 离开多人记本 */
            if buttonIndex == 0 {
                self.navigationItem.rightBarButtonItems = buttonArray()
                Api.getQuit(self.Id) { json in
                    self.navigationItem.rightBarButtonItems = []
                    self.delegateDelete?.deleteDreamCallback(self.Id)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func editMyDream() {
        let editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        editdreamVC.delegate = self
        editdreamVC.isEdit = 1
        let id = dataArrayTop.stringAttributeForKey("id")
        let title = dataArrayTop.stringAttributeForKey("title")
        let content = dataArrayTop.stringAttributeForKey("content")
        let img = dataArrayTop.stringAttributeForKey("image")
        let thePrivate = Int(dataArrayTop.stringAttributeForKey("private"))!
        editdreamVC.editId = id
        editdreamVC.editTitle = title.decode()
        editdreamVC.editContent = content.decode()
        editdreamVC.editImage = img
        editdreamVC.isPrivate = thePrivate
        let tags: Array<String> = dataArrayTop.objectForKey("tags") as! Array
        editdreamVC.tagsArray = tags
        self.navigationController?.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags:Array<String>) {
        let mutableData = NSMutableDictionary(dictionary: dataArrayTop)
        mutableData.setValue(editPrivate, forKey: "private")
        mutableData.setValue(editTitle, forKey: "title")
        mutableData.setValue(editDes, forKey: "content")
        mutableData.setValue(editImage, forKey: "image")
        mutableData.setValue(editTags, forKey: "tags")
        dataArrayTop = DataDecode(mutableData)
        self.SATableView.reloadData()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v > 0 {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            let v = otherGestureRecognizer.view?.frame.origin.y
            if v == 0 {
                return true
            }
        }
        return false
    }
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func DataDecode(data: NSDictionary) -> NSDictionary {
        let thePrivate = data.stringAttributeForKey("private")
        let percent = data.stringAttributeForKey("percent")
        let title = data.stringAttributeForKey("title").decode()
        let content = data.stringAttributeForKey("content").decode()
        var _title = ""
        if thePrivate == "1" {
            _title = "\(title)（私密）"
        } else if percent == "1" {
            _title = "\(title)（完成）"
        }
        let hTitle = _title.stringHeightBoldWith(18, width: 240)
        var hContent: CGFloat = 0
        if content != "" {
            hContent = content.stringHeightWith(12, width: 240)
            let h4Lines = "\n\n\n".stringHeightWith(12, width: 240)
            hContent = min(hContent, h4Lines)
        }
        var heightCell = 306 + hTitle + 8 + hContent
        if content == "" {
            heightCell = 306 + hTitle
        }
        heightCell = SACeil(heightCell, dot: 0, isCeil: true)
        let mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(hTitle, forKey: "heightTitle")
        mutableData.setValue(hContent, forKey: "heightContent")
        mutableData.setValue(heightCell, forKey: "heightCell")
        mutableData.setValue(content, forKey: "content")
        mutableData.setValue(title, forKey: "title")
        return NSDictionary(dictionary: mutableData)
    }
}