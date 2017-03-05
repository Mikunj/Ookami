//
//  MediaTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

class MediaTrendingDataSource: TrendingDataSource {
    
    //The current media ids that we have
    var mediaIds: [Int] = []
    
    //Whether we are currently fetching
    var fetching: Bool = false
    
    //The collection view layout to use
    override var collectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let padding: CGFloat = 4
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding / 2, left: padding, bottom: padding * 2, right: padding)
        
        let phoneSize = CGSize(width: 110, height: 165)
        let padSize = CGSize(width: 150, height: 225)
        layout.itemSize = UIDevice.current.userInterfaceIdiom == .pad ? padSize : phoneSize
        
        return layout
    }
    
    /// Create a Media Trending Data Source
    ///
    /// - Parameters:
    ///   - title: The title
    ///   - detail: The detail
    ///   - parent: The parent of the data source
    ///   - delegate: The delegate
    override init(title: String, detail: String = "", parent: UIViewController, delegate: TrendingDelegate) {
        super.init(title: title, detail: detail, parent: parent, delegate: delegate)
        fetch()
    }
    
    //Fetch the media
    func fetch() {
    }
    
    //The item data for item at index path
    func itemData(for indexPath: IndexPath) -> ItemData? {
        return nil
    }
    
    //MARK:- Collection View
    override func setup(collectionView: UICollectionView) {
        if mediaIds.count == 0 { fetch() }
        collectionView.register(cellType: ItemSimpleGridCell.self)
        super.setup(collectionView: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaIds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemSimpleGridCell
        
        //Load the data
        if let data = itemData(for: indexPath) {
            cell.update(data: data, loadImages: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    

}
