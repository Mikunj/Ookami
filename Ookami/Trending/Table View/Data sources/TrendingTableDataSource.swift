//
//  TrendingTableDataSource.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

protocol TrendingTableDelegate: class {
    func reload(dataSource: TrendingTableDataSource)
}

class TrendingTableDataSource: NSObject {
    
    //The title of the cell
    var title: String
    
    //The detail string
    var detail: String = ""
    
    //The parent of the data source
    weak var parent: UIViewController?
    
    //The delegate for the data source
    weak var delegate: TrendingTableDelegate?
    
    //The layout that will be applied to the collection view
    var collectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }
    
    init(title: String, detail: String = "", parent: UIViewController, delegate: TrendingTableDelegate) {
        self.title = title
        self.detail = detail
        self.parent = parent
        self.delegate = delegate
    }
    
    //Setup the collection view
    func setup(collectionView: UICollectionView) {
    }
    
    //Reload the data
    func reload() {
        delegate?.reload(dataSource: self)
    }
    
    //The see all button was tapped
    func didTapSeeAllButton() {
    }

}

//MARK:- UICollectionViewDataSource
extension TrendingTableDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

//MARK:- UICollectionViewDelegate
extension TrendingTableDataSource: UICollectionViewDelegate {}
