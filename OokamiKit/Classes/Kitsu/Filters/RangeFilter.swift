//
//  RangeFilter.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//A Struct representing a range filter
public struct RangeFilter<T: Comparable>: CustomStringConvertible where T: CustomStringConvertible {
    public var start: T
    public var end: T?
    
    public init(start: T, end: T?) {
        self.start = start
        self.end = end
    }
    
    //Apply correction to the values so that start < end
    mutating func applyCorrection() {
        //Check that start < end
        if let end = self.end {
            let start = self.start
            
            self.start = min(start, end)
            self.end = max(start, end)
        }
    }
    
    //Cap the start and end values to the min and max
    mutating func capValues(min minValue: T, max maxValue: T) {
        self.start = min(maxValue, max(minValue, self.start))
        
        if let end = self.end {
            self.end = min(maxValue, max(minValue, end))
        }
    }
    
    public var description: String {
        let end = self.end?.description ?? ""
        return "\(start)..\(end)"
    }
}
