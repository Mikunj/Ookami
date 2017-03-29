//
//  LibraryEntryPrivateHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryPrivateHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .isPrivate
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        return LibraryEntryViewData.TableData(type: .bool, value: entry.isPrivate, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        updater.update(isPrivate: !updater.entry.isPrivate)
        controller.reloadData()
    }
}

