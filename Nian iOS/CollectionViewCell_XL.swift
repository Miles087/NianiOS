//
//  CollectionViewCell-XL.swift
//  Nian iOS
//
//  Created by WebosterBob on 9/1/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class CollectionViewCell_XL: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: CellLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setupView() {
        
        // 实际判断的是屏幕的宽度
        //        if isiPhone6 || isiPhone6P {
        //            self.imageView.frame = CGRectMake(0, 0, 80, 80)
        //            self.label.frame = CGRectMake(0, 88, 80, 34)
        //
        //            self.layoutIfNeeded()
        //        }
        //
        self.imageView?.layer.cornerRadius = 6.0
        self.imageView?.layer.borderWidth = 0.5
        self.imageView?.layer.borderColor = UIColor.colorWithHex("#E6E6E6").CGColor
        self.imageView?.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.cancelImageRequestOperation()
        self.imageView.image = nil
    }
    
    
}