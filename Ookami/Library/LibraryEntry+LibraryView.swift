//
//  LibraryEntry+LibraryView.swift
//  Ookami
//
//  Created by Maka on 4/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

extension LibraryEntry.Status {
    //Get the UIColor for a given status
    func color() -> UIColor {
        let theme = Theme.Status()
        switch self {
        case .current:
            return theme.current
        case .planned:
            return theme.planned
        case .completed:
            return theme.completed
        case .onHold:
            return theme.onHold
        case .dropped:
            return theme.dropped
            
        }
    }
    
}
