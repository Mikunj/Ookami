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
    
    //Different cells that we can set
    enum CellType {
        case DetailGrid
    }
    
    //Types of cell to use
    var type: CellType = .DetailGrid {
        didSet {
            applySpacer()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
    
    //The datasource we are going to use
    private var _source: ItemViewControllerDataSource?
    var dataSource: ItemViewControllerDataSource? {
        
        get {
            return _source
        }
        
        set(newSource) {
            _source?.delegate = nil
            _source = newSource
            _source?.delegate = self
            
            //Reload the data in the view
            collectionView.setContentOffset(CGPoint.zero, animated: true)
            if let source = _source {
                didReloadItems(dataSource: source)
            } else {
                diffCalculator?.rows = []
            }
        }
    }
    
    //A difference calculator used for animating collection view
    fileprivate var diffCalculator: CollectionViewDiffCalculator<ItemData>?
    
    //The collection view
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        c.backgroundColor = UIColor.groupTableViewBackground
        c.dataSource = self
        c.delegate = self
        
        c.register(cellType: ItemDetailGridCell.self)
        
        return c
    }()
    
    
    /// Create an ItemViewController
    ///
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: ItemViewControllerDataSource? = nil) {
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
        
        diffCalculator = CollectionViewDiffCalculator(collectionView: collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        applySpacer()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Apply CollectionCellSpacer to the layout
    func applySpacer() {
        let sizes = itemSize()
        let width = UIScreen.main.bounds.width
        let options = sizes.flatMap { try? CollectionCellSpacerOption(itemSize: $0, minimumGutter: 1.0, availableWidth: width) }
        
        guard let best = CollectionCellSpacer.bestSpacing(with: options) else {
                return
        }
        
        //Apply the options
        let spacer = CollectionCellSpacer(option: best)
        spacer.applySpacing(to: collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        
    }
    
    /// An array of item sizes to use
    func itemSize() -> [CGSize] {
        switch type {
        case .DetailGrid:
            return [CGSize(width: 100, height: 175), CGSize(width: 120, height: 210)]
        }
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
        
        return cell
    }
    
}

//MARK:- Collection Delegate
extension ItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        dataSource?.didSelectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Update the cell if we can
        if let updatable = cell as? ItemUpdatable,
            let item = diffCalculator?.rows[indexPath.row] {
            updatable.update(data: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ItemUpdatable)?.stopUpdating()
    }
}
