//
//  Double+Ookami.swift
//  Ookami
//
//  Created by Maka on 11/4/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

extension Double {
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded(.down) / n
    }
}
