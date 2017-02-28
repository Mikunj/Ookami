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
import Diff
import XLPagerTabStrip
import NVActivityIndicatorView
import DZNEmptyDataSet

//TODO: Add more cells, clean up code a bit
//The datasource which is used by the controller
protocol ItemViewControllerDataSource: class {
    weak var delegate: ItemViewControllerDelegate? { get set }
    var count: Int { get }
    
    func items() -> [ItemData]
    func didSelectItem(at indexPath: IndexPath)
    func refresh()
    func shouldShowEmptyDataSet() -> Bool
    func dataSetImage() -> UIImage?
    func dataSetTitle() -> NSAttributedString?
    func dataSetDescription() -> NSAttributedString?
}

//The delegate which is implemented by the controller
protocol ItemViewControllerDelegate: class {
    func didReloadItems(dataSource: ItemViewControllerDataSource)
    func showActivityIndicator()
    func hideActivityIndicator()
}

//Controller for displaying a grid of items
class ItemViewController: UIViewController {
    
    //Callback block which gets called whenever scrolling occurs
    var onScroll: ((UIScrollView) -> Void)? = nil
    
    //Different cells that we can set
    enum CellType {
        case detailGrid
        case simpleGrid
    }
    
    //Types of cell to use
    var type: CellType = .detailGrid {
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
            data = _source == nil ? [] : _source!.items()
        }
    }
    
    //A variable to indicate whether images should be loaded
    var shouldLoadImages: Bool = false {
        didSet {
            if oldValue != shouldLoadImages {
                collectionView.reloadData()
            }
        }
    }
    
    //The current array of data
    private var viewVisible: Bool = false
    fileprivate var data: [ItemData] {
        didSet {
            //Only animate if the view is visible
            //This is to avoid dumb inconsitency issues :(
            //And to also make the initial loading seem instantaneous, instead of just 'popping' in
            if viewVisible {
                collectionView.animateItemChanges(oldData: oldValue, newData: data)
            } else {
                collectionView.reloadData()
            }
            
        }
    }
    
    //The collection view
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 175)
        
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        c.alwaysBounceVertical = true
        c.backgroundColor = UIColor.groupTableViewBackground
        c.dataSource = self
        c.delegate = self
        
        c.emptyDataSetSource = self
        c.emptyDataSetDelegate = self
        
        //Cells
        c.register(cellType: ItemDetailGridCell.self)
        c.register(cellType: ItemSimpleGridCell.self)
        
        return c
    }()
    
    //The activity indicator
    var activityIndicator: NVActivityIndicatorView = {
        let theme = Theme.ActivityIndicatorTheme()
        return theme.view()
    }()
    
    /// Create an ItemViewController
    ///
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: ItemViewControllerDataSource? = nil) {
        
        //Set the initial items if we have them
        self.data = dataSource?.items() ?? []
        
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }
    
    /// Do not use this to initialize `ItemViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use ItemViewController.init(dataSource:)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewVisible = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add collectionview
        self.view.addSubview(collectionView)
        constrain(collectionView) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the indicator
        let size = Theme.ActivityIndicatorTheme().size
        
        self.view.addSubview(activityIndicator)
        
        constrain(activityIndicator) { view in
            view.center == view.superview!.center
            view.width == size.width
            view.height == size.height
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
        let options = sizes.flatMap { try? CollectionCellSpacerOption(itemSize: $0, minimumGutter: 2.0, availableWidth: width) }
        
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
        case .detailGrid:
            return [CGSize(width: 100, height: 175), CGSize(width: 120, height: 210)]
        case .simpleGrid:
            return [CGSize(width: 100, height: 150), CGSize(width: 120, height: 180)]
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
        data = dataSource.items()
        collectionView.reloadEmptyDataSet()
    }
    
    func showActivityIndicator() {
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
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
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell?
        
        switch type {
        case .detailGrid:
            cell = collectionView.dequeueReusableCell(for: indexPath) as ItemDetailGridCell
        case .simpleGrid:
            cell = collectionView.dequeueReusableCell(for: indexPath) as ItemSimpleGridCell
        }

        return cell ?? UICollectionViewCell()
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
        if let updatable = cell as? ItemUpdatable {
            let item = data[indexPath.row]
            updatable.update(data: item, loadImages: shouldLoadImages)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ItemUpdatable)?.stopUpdating()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?(scrollView)
    }
}

//MARK:- DZNEmptyDataSet Data Source
extension ItemViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return dataSource?.dataSetImage() ?? UIImage()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return dataSource?.dataSetTitle() ?? NSAttributedString(string: "")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return dataSource?.dataSetDescription() ?? NSAttributedString(string: "")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.clear
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 8
    }
}

//MARK:- DZNEmptyDataSet Delegate
extension ItemViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return dataSource?.shouldShowEmptyDataSet() ?? true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
