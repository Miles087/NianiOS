//
//  CircleListCollectionController.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/9/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class CircleListCollectionController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addCircleLabel: UILabel!
    @IBOutlet weak var labelAdd: UILabel!
    
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll", name: "Poll", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        navHide()
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        load()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        globalViewFilmExist = false
    }
    
    func onSearch() {
        var vc = CircleExploreController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func Poll() {
        load()
    }
    
    func load() {
        go {
            var safeuid = SAUid()
            let (resultCircle, errCircle) = SD.executeQuery("SELECT circle FROM `circle` where owner = '\(safeuid)' GROUP BY circle ORDER BY lastdate DESC")
            self.dataArray.removeAllObjects()
            for row in resultCircle {
                var id = (row["circle"]?.asString())!
                var img = ""
                var title = "梦境"
                let (resultDes, err) = SD.executeQuery("select * from circlelist where circleid = '\(id)' and owner = '\(safeuid)' limit 1")
                if resultDes.count > 0 {
                    for row in resultDes {
                        img = (row["image"]?.asString())!
                        title = (row["title"]?.asString())!
                    }
                }
                var data = NSDictionary(objects: [id, img, title], forKeys: ["id", "img", "title"])
                self.dataArray.addObject(data)
            }
            var dataBBS = NSDictionary(objects: ["0", "0", "0"], forKeys: ["id", "img", "title"])
            self.dataArray.addObject(dataBBS)
            back {
                self.collectionView.reloadData()
//                self.collectionView.layoutSubviews(
            }
        }
    }
    
    func setupViews() {
        let flowLayout = UICollectionViewFlowLayout()
        var width = (self.view.bounds.width - 48) / 2
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 16.0
        flowLayout.itemSize = CGSize(width: width, height: 182)
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.collectionView.collectionViewLayout = flowLayout
        self.addCircleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSearch"))
        labelAdd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onAdd"))
    }
    
    
}

extension CircleListCollectionController: UICollectionViewDataSource, UICollectionViewDelegate  {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identifier = "CircleCollectionCell"
        var c = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! CircleCollectionCell
        c.data = self.dataArray[indexPath.row] as? NSDictionary
        c.btnStep.tag = indexPath.row
        c.btnBBS.tag = indexPath.row
        c.btnChat.tag = indexPath.row
        c.btnStep.addTarget(self, action: "toStep:", forControlEvents: UIControlEvents.TouchUpInside)
        c.btnBBS.addTarget(self, action: "toBBS:", forControlEvents: UIControlEvents.TouchUpInside)
        c.btnChat.addTarget(self, action: "toChat:", forControlEvents: UIControlEvents.TouchUpInside)
        return c
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var data = dataArray[indexPath.row] as! NSDictionary
        var id = data.stringAttributeForKey("id")
        if id == "0" {
            var vc = ExploreController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            toCircle(indexPath.row, tab: 2)
        }
    }
    
    func toStep(sender: UIButton) {
        var tag = sender.tag
        toCircle(tag, tab: 0)
    }
    
    func toBBS(sender: UIButton) {
        var tag = sender.tag
        toCircle(tag, tab: 1)
    }
    
    func toChat(sender: UIButton) {
        var tag = sender.tag
        toCircle(tag, tab: 2)
    }
    
    func toCircle(index: Int, tab: Int) {
        go {
            var vc = NewCircleController()
            var data = self.dataArray[index] as! NSDictionary
            var id = data.stringAttributeForKey("id")
            var title = data.stringAttributeForKey("title")
            vc.id = id
            vc.current = tab
            vc.textTitle = title
            SD.executeChange("update circle set isread = 1 where circle = \(id) and owner = \(SAUid())")
            back {
                self.load()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func onAdd() {
        showFilm("创建", prompt: "创建一个梦境\n需要花费 20 念币", button: "20 念币", transDirectly: false){ film in
            var addcircleVC = AddCircleController(nibName: "AddCircle", bundle: nil)
            self.navigationController?.pushViewController(addcircleVC, animated: true)
            self.onFilmClose()
        }
    }
}





















