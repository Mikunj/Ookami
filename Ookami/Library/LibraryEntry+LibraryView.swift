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
//    This has been commented incase the feature wants to be re-implemented in the future
//    func color() -> UIColor {
//        let theme = Theme.Status()
//        switch self {
//        case .current:
//            return theme.current
//        case .planned:
//            return theme.planned
//        case .completed:
//            return theme.completed
//        case .onHold:
//            return theme.onHold
//        case .dropped:
//            return theme.dropped
//            
//        }
//    }
    
    /* NOTE: Due to the similarity of Ookami and Aozora, the colors under the statuses will be defaulted to white. When making this i thought the way it was in Aozora was brilliant, but alas it made the app look way to similar too it and thus there was some backlash.*/
    //Get the UIColor for a given status
    func color() -> UIColor {
        return Theme.Colors().secondary
    }
    
}
