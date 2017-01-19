//
//  SearchMediaDataSource.swift
//  Ookami
//
//  Created by Maka on 19/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import RealmSwift

//The data source for showing media in search
class SearchMediaDataSource: SearchViewControllerDataSource {
    
    //The delegate
    weak var delegate: SearchViewControllerDelegate? = nil
    
    //The data used for animation
    var data: [SearchMediaTableCellData] = []
    
    //The network operation
    var operation: Operation? = nil
    
    init(parent: UITableView) {
        parent.register(cellType: SearchMediaTableViewCell.self)
    }
    
    //We use populatedSections to only show sections which have data
    //No point in showing Movie if there is no movie in the response
    func numberOfSection(in tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfRows(in section: Int, tableView: UITableView) -> Int {
        return data.count
    }
    
    func cellForRow(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SearchMediaTableViewCell
        
        let data = self.data[indexPath.row]
        cell.update(data: data)
        
        return cell
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? 332 : 166
    }
    
    //If you return nil then no section header is displayed
    func title(for section: Int) -> String? {
        return nil
    }
    
    //Update the anime data
    func updateData(newData: [SearchMediaTableCellData]) {
        let oldData = self.data
        self.data = newData
        delegate?.reloadTableView(oldData: oldData, newData: newData)
    }
    
    func didUpdateSearch(text: String) {
        
        //Don't bother calling api if text is empty
        if text.isEmpty {
            willClearData()
            updateData(newData: [])
            operation?.cancel()
            delegate?.hideIndicator()
            return
        }
        
        //Check if we have a operation in progress, if so then cancel it
        if operation != nil {
            operation?.cancel()
        }
        
        delegate?.showIndicator()
        
        //Set the operation and its delegate
        operation = operation(for: text) {
            self.operation = nil
            self.delegate?.hideIndicator()
        }
    }
    
    func willClearData() {
    }
    
    func operation(for searchText: String, completion: @escaping () -> Void) -> Operation {
        fatalError("operation(for:) needs to be implemented in a subclass")
    }
    
    func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        fatalError("didTapCell(indexPath:controller:) needs to be implemented in a subclass")
    }
    
}
