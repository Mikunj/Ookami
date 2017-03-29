//
//  LibraryEntryReconsumingHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class LibraryEntryReconsumingHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .reconsuming
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        return LibraryEntryViewData.TableData(type: .bool, value: entry.reconsuming, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        //Just invert the value
        updater.update(reconsuming: !updater.entry.reconsuming)
        controller.reloadData()
    }
}

