//
//  MediaFranchiseController.swift
//  Ookami
//
//  Created by Maka on 30/8/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit
import RealmSwift
import DynamicColor

/// A Controller which handles the fetching and displaying of media franchises
class MediaFranchiseController: NSObject {
    
    //The source id and type
    fileprivate var sourceId: Int
    fileprivate var sourceType: Media.MediaType
    
    //The parent of the controller
    fileprivate var parent: UIViewController
    
    //The on update block
    fileprivate var onUpdate: () -> Void
    
    //The scroll offsets of the collection view
    fileprivate var offset: CGFloat = 0
    
    //The collection view layout for the franchises
    fileprivate var collectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let padding: CGFloat = 4
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding * 2, right: padding)
        
        let phoneSize = CGSize(width: 110, height: 190)
        let padSize = CGSize(width: 150, height: 250)
        layout.itemSize = UIDevice.current.userInterfaceIdiom == .pad ? padSize : phoneSize
        
        return layout
    }
    
    //The section for the view controller
    fileprivate var controllerSection: MediaViewControllerSection?
    
    //The service for franchises
    var service: PaginatedService?
    
    //Realm tokem
    var token: NotificationToken?
    
    //Franchises
    var franchises: Results<MediaRelationship>?
    
    /// Create the MediaFranchiseController
    ///
    /// - Parameters:
    ///   - mediaId: The media id to get franchise for
    ///   - mediaType: The media type
    ///   - onUpdate: Block which gets called when franchises is updated
    init(mediaId: Int, mediaType: Media.MediaType, parent: UIViewController, onUpdate: @escaping () -> Void) {
        self.sourceId = mediaId
        self.sourceType = mediaType
        self.parent = parent
        self.onUpdate = onUpdate
        super.init()
        
        updateControllerSection()
        updateFranchises()
        fetchFranchises()
    }
    
    deinit {
        token?.invalidate()
        service?.cancel()
    }
    
    //Get the MediaViewControllerSection for the controller
    func section() -> MediaViewControllerSection? {
        return (franchises?.count ?? 0) > 0 ? controllerSection : nil
    }
    
    fileprivate func fetchFranchises() {
        service = MediaService().getMediaRelationships(for: self.sourceId, type: self.sourceType) { [weak self] _, error in
            guard error == nil else {
                return
            }
            self?.service?.next()
        }
    }
    
    //Update the view controller section
    fileprivate func updateControllerSection() {
        controllerSection = MediaViewControllerSection(title: "More from this Series", cellCount: 1)
        
        controllerSection?.cellForIndexPath = { indexPath, tableView in
            let cell =  tableView.dequeueReusableCell(for: indexPath) as CollectionViewTableViewCell
            cell.collectionView.register(cellType: ItemDetailGridCell.self)
            return cell
        }
        
        controllerSection?.willDisplayCell = { indexPath, cell in
            guard let tableCell = cell as? CollectionViewTableViewCell else { return }
            
            tableCell.set(title: "")
            tableCell.set(detail: "")
            tableCell.set(showSeeAll: false)
            tableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            tableCell.collectionView.collectionViewLayout = self.collectionViewLayout
            tableCell.collectionViewOffset = self.offset
            tableCell.collectionView.backgroundColor = UIColor.groupTableViewBackground.lighter(amount: 0.018)
        }
        
        controllerSection?.didEndDisplayingCell = { indexPath, cell in
            guard let tableCell = cell as? CollectionViewTableViewCell else { return }
            self.offset = tableCell.collectionViewOffset
        }
        
        controllerSection?.heightForRow = { indexPath in
            let itemHeight = self.collectionViewLayout.itemSize.height
            let padding = self.collectionViewLayout.sectionInset.top + self.collectionViewLayout.sectionInset.bottom
            let height = itemHeight + padding + 1
            
            //We don't include the header section in CollectionViewTableCell
            //Since it will be hidden
            return height
        }
        
    }
    
    //Get the franchises and add a notification on them
    fileprivate func updateFranchises() {
        franchises = MediaRelationship.belongsTo(sourceId: sourceId, type: sourceType).sorted(byKeyPath: "role")
        token?.invalidate()
        token = franchises?.observe { [unowned self] _ in
            self.onUpdate()
        }
    }
    
    //Get the item data for the given indexpath
    fileprivate func itemData(for indexPath: IndexPath) -> ItemData? {
        guard let relationship = franchises?[indexPath.row] else { return nil }
        var data: ItemData? = nil
        
        if let anime = relationship.anime {
            data = anime.toItemData()
            data?.details = anime.subtype?.rawValue.uppercased()
        }
        
        if let manga = relationship.manga {
            data = manga.toItemData()
            data?.details = manga.subtype?.rawValue.uppercased()
        }
        
        let role = relationship.role.replacingOccurrences(of: "_", with: " ")
        data?.moreDetails = role.uppercased()
        
        return data
    }
    
}

//MARK:- UICollectionViewDataSource
extension MediaFranchiseController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return franchises?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemDetailGridCell
        
        //Load the data
        if let data = itemData(for: indexPath) {
            cell.update(data: data, loadImages: true)
        }
        
        return cell
    }
}

//MARK:- UICollectionViewDelegate
extension MediaFranchiseController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        //TODO: Launch media screen here
        guard let relationship = franchises?[indexPath.row] else { return }
        
        if let anime = relationship.anime {
            AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
        
        if let manga = relationship.manga {
            AppCoordinator.showMangaVC(in: parent, manga: manga)
        }
    }
}
