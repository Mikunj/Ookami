//
//  LibraryEntryDeleteHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class LibraryEntryDeleteHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .delete
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        return LibraryEntryViewData.TableData(type: .delete, value: "Delete library entry", heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        let sheet = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        
        sheet.popoverPresentationController?.sourceView = cell
        sheet.popoverPresentationController?.sourceRect = cell.bounds
        
        sheet.addAction(UIAlertAction(title: "Yes, Delete it!", style: .destructive) { action in
            
            //Send the delete action and show error if it occurred
            controller.showIndicator()
            LibraryService().delete(entry: updater.entry) { error in
                controller.hideIndicator()
                guard error == nil else {
                    ErrorAlert.showAlert(in: controller, title: "Failed to delete entry", message: error!.localizedDescription)
                    return
                }
                
                let _ = controller.navigationController?.popViewController(animated: true)
            }
        })
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Present the sheet if we haven't
        if controller.presentedViewController == nil {
            controller.present(sheet, animated: true)
        }
    }
}

