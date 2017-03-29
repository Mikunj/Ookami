//
//  LibraryEntryDataHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

protocol LibraryEntryDataHandler {
    
    //The heading that it handles
    var heading: LibraryEntryViewData.Heading { get }
    
    //The table data
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController)
}
