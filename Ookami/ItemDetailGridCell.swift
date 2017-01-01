//
//  ItemDetailGridCell.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Kingfisher
import Reusable

//TODO: Make nameView fade from black to clear

final class ItemDetailGridCell: UICollectionViewCell, NibReusable {

    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Update the cell with the given data
    ///
    /// - Parameter data: The item data to update with
    func update(data: ItemData) {
        nameLabel.text = data.name ?? "-"
        detailLabel.text = data.countString ?? "-"
        
        //Set the image
        if let poster = data.posterImage {
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster))
        }else {
            posterImage.image = nil
        }
        
    }

}
