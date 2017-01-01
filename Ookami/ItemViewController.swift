//
//  ItemViewController.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit
import Cartography
import Dwifft

//TODO: Add more cells, clean up code a bit, fix layouts
//Also look into performance with KingFisher

//The datasource which is used by the controller
protocol ItemViewControllerDataSource {
    var delegate: ItemViewControllerDelegate? { get set }
    
    func items() -> [ItemData]
    func didSelectItem(at indexpath: IndexPath)
}

//The delegate which is implemented by the controller
protocol ItemViewControllerDelegate {
    func didReloadItems(dataSource: ItemViewControllerDataSource)
}

//Controller for displaying a grid of items
class ItemViewController: UIViewController {
    
    //The datasource we are going to use
    fileprivate var _source: ItemViewControllerDataSource?
    var dataSource: ItemViewControllerDataSource? {
        
        get {
            return _source
        }
        
        set(newSource) {
            _source?.delegate = nil
            _source = newSource
            _source?.delegate = self
        }
    }
    
    fileprivate var diffCalculator: CollectionViewDiffCalculator<ItemData>?
    
    //The collection view
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 150)
        
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        c.dataSource = self
        c.delegate = self
        
        c.register(cellType: ItemDetailGridCell.self)
        return c
    }()
    
    init(dataSource: ItemViewControllerDataSource) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add collectionview
        self.view.addSubview(collectionView)
        constrain(collectionView) { view in
            view.edges == view.superview!.edges
        }
        
        //The diff calculator which automatically animates collection view
        diffCalculator = CollectionViewDiffCalculator(collectionView: collectionView)
    }
}

//MARK:- Item Delegate
extension ItemViewController: ItemViewControllerDelegate {
    func didReloadItems(dataSource: ItemViewControllerDataSource) {
        diffCalculator?.rows = dataSource.items()
    }
}

//MARK:- Collection Datasource
extension ItemViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diffCalculator?.rows.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ItemDetailGridCell = collectionView.dequeueReusableCell(for: indexPath)
        
        if let item = diffCalculator?.rows[indexPath.row] {
           cell.update(data: item)
        }
        
        return cell
    }
    
}

//MARK:- Collection Delegate
extension ItemViewController: UICollectionViewDelegate {
    
}
