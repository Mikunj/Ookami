//
//  TrendingViewController.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

/*
 
 Plan: This will accept an array of [TrendingDataSource] which confroms to the protocol <UICollectionViewDataSource, UICollectionViewDelegate>
 We can make a base data source which handles all the displaying of the collection cells (and accepts a mediafilter) and then subclass them into AnimeTrendingDataSource and MangaTrendingDataSource.
 From there they can both handle the on-tap events and the see all events.
 
 TODO: Maybe in the data source we have a layout property which gets automatically set to the collection view in the table cell?
 From there we can use `collectionViewContentSize` property to work out the height of the cell. Look below.
 
 - Also need a way for the DataSource to pass back the collection cell sizes so that we can correctly compute the CollectionViewTableViewCell sizes. (25 + top&bottom padding + cell height)
 
 We need to set the tags on the tableview cells so that we know what row was tapped when see all button was tapped. This way we can pass the call to the correct data source.
 
 https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
 */

class TrendingViewController: UIViewController {
    
    //The table view
    lazy var tableView: UITableView  = {
        let t = UITableView()
        
        t.cellLayoutMarginsFollowReadableWidth = false
        
        t.delegate = self
        t.dataSource = self
        
        t.tableFooterView = UIView(frame: .zero)
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        t.register(cellType: CollectionViewTableViewCell.self)
        
        return t
    }()
    
    //The scroll offsets of the collection views
    var offsets: [Int: CGFloat] = [:]
    
    //The data to show
    var data: [TrendingDataSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the tableview
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }
    }
    
}

//MARK:- Tableview Data Source
extension TrendingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(for: indexPath) as CollectionViewTableViewCell
        
        let source = data[indexPath.row]
        cell.delegate = self
        cell.collectionView.collectionViewLayout = source.collectionViewLayout
        source.setup(collectionView: cell.collectionView)
        
        return cell
    }
}

//MARK:- Tableview Delegate
extension TrendingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Height = 30 (title & button) + Collection view height
        let source = data[indexPath.row]
        
        //If we have a flow layout then calculate the height
        let layout = source.collectionViewLayout
        
        let itemHeight = layout.itemSize.height
        let padding = layout.sectionInset.top + layout.sectionInset.bottom
        let height = itemHeight + padding + 1
        
        return 30.0 + height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableCell = cell as? CollectionViewTableViewCell else { return }
        
        let source = data[indexPath.row]
        
        tableCell.setTitle(title: source.title)
        tableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: source, forRow: indexPath.row)
        tableCell.collectionViewOffset = offsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableCell = cell as? CollectionViewTableViewCell else { return }
        offsets[indexPath.row] = tableCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

//MARK:- CollectionViewTableViewCellDelegate
extension TrendingViewController: CollectionViewTableViewCellDelegate {
    func didTapSeeAll(sender: CollectionViewTableViewCell) {
        let index = sender.tag
        let source = data[index]
        source.didTapSeeAllButton()
    }
}

//MARK:- Trending Delegate
extension TrendingViewController: TrendingDelegate {
    func reload(dataSource: TrendingDataSource) {
        guard let index = data.index(of: dataSource) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
