//
//  ItemUpdatable.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

protocol ItemUpdatable {
    /// Update class based on the given data
    ///
    /// - Parameters:
    ///   - data: The item data
    ///   - loadImages: Whether to load the images
    func update(data: ItemData, loadImages: Bool)
    
    //Called when item is out of view
    func stopUpdating()
}
