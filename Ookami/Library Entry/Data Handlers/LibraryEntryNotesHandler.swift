//
//  LibraryEntryNotesHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class LibraryEntryNotesHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .notes
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        return LibraryEntryViewData.TableData(type: .string, value: entry.notes, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let editingVC = TextEditingViewController(title: "Notes", text: updater.entry.notes, placeholder: "Type your notes here!")
        editingVC.modalPresentationStyle = .overCurrentContext
        editingVC.delegate = controller
        
        let vc = controller.tabBarController ?? controller
        vc.present(editingVC, animated: false)
    }
}

