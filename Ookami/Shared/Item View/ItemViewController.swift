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
import XLPagerTabStrip
import NVActivityIndicatorView

//TODO: Add more cells, clean up code a bit, fix layouts
//Also look into performance with KingFisher

//The datasource which is used by the controller
protocol ItemViewControllerDataSource {
    var delegate: ItemViewControllerDelegate? { get set }
    
    func items() -> [ItemData]
    func didSelectItem(at indexpath: IndexPath)
    func refresh()
}

//The delegate which is implemented by the controller
protocol ItemViewControllerDelegate {
    func didReloadItems(dataSource: ItemViewControllerDataSource)
    func showActivityIndicator()
    func hideActivityIndicator()
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
    
    //The refresh control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
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
        layout.itemSize = CGSize(width: 100, height: 150)
        
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        c.alwaysBounceVertical = true
        c.backgroundColor = UIColor.groupTableViewBackground
        c.dataSource = self
        c.delegate = self
        
        c.register(cellType: ItemDetailGridCell.self)
        
        return c
    }()
    
    //The activity indicator
    var activityIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballSpinFadeLoader, color: UIColor.darkGray)
        return view
    }()
    
    /// Create an ItemViewController
    ///
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: ItemViewControllerDataSource? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
        self.diffCalculator = CollectionViewDiffCalculator(collectionView: collectionView)
    }
    
    /// Do not use this to initialize `ItemViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use ItemViewController.init(dataSource:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add collectionview
        self.view.addSubview(collectionView)
        constrain(collectionView) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the indicator
        self.view.addSubview(activityIndicator)
        constrain(activityIndicator) { view in
            view.center == view.superview!.center
            view.width == 40
            view.height == 40
        }
        
        //Add the refresh control
        collectionView.addSubview(refreshControl)
        collectionView.sendSubview(toBack: refreshControl)
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
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        dataSource?.refresh()
        
    }
}

//MARK:- Indicator Info Provider
extension ItemViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.title ?? "-")
    }
}

//MARK:- Item Delegate
extension ItemViewController: ItemViewControllerDelegate {
    func didReloadItems(dataSource: ItemViewControllerDataSource) {
        diffCalculator?.rows = dataSource.items()
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
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
