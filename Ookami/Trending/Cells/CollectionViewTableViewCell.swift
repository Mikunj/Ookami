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
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(detail: String) {
        detailLabel.text = detail
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
