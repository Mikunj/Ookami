//
//  CollectionViewTableViewCell.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

protocol CollectionViewTableViewCellDelegate: class {
    func didTapSeeAll(sender: CollectionViewTableViewCell)
}

class CollectionViewTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var upperHeightConstraint: NSLayoutConstraint!
    
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        
        set {
            collectionView.contentOffset.x = newValue
        }
    }
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var seeAllButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //Update the height of the upperview if the title, detail and button are not visible
    func updateHeightConstraint() {
        let height = 45.0
        let titleText = titleLabel.text?.isEmpty ?? true
        let detailText = detailLabel.text?.isEmpty ?? true
        
        upperHeightConstraint.constant = CGFloat((titleText && detailText && seeAllButton.isHidden) ? 0.0 : height)
    }
    
    func set(title: String) {
        titleLabel.text = title
        updateHeightConstraint()
    }
    
    func set(detail: String) {
        detailLabel.text = detail
        updateHeightConstraint()
    }
    
    func set(showSeeAll visible: Bool) {
        seeAllButton.isHidden = !visible
        updateHeightConstraint()
    }
    
    func setCollectionViewDataSourceDelegate<T>(dataSourceDelegate: T, forRow row: Int) where
        T: UICollectionViewDelegate,
        T: UICollectionViewDataSource {
            
            self.tag = row
            collectionView.delegate = dataSourceDelegate
            collectionView.dataSource = dataSourceDelegate
            collectionView.tag = row
            collectionView.reloadData()
    }
    
    @IBAction func didTapSeeAll(_ sender: Any) {
        delegate?.didTapSeeAll(sender: self)
    }
}
