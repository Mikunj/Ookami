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

//Constraints still breaking on mobile .... WHY!!

final class ItemDetailGridCell: UICollectionViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

//MARK:- Reusable
extension ItemDetailGridCell: NibReusable {}

//MARK:- Item Updatable
extension ItemDetailGridCell: ItemUpdatable {
    
    /// Update the cell with the given data
    ///
    /// - Parameter data: The item data to update with
    func update(data: ItemData) {
        nameLabel.text = data.name ?? "-"
        detailLabel.text = data.countString ?? "-"
        
        //Set the image
        if let poster = data.posterImage {
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), options: [.transition(.fade(0.2)), .backgroundDecode])
        }else {
            posterImage.image = nil
        }
        
    }
    
    func stopUpdating() {
        posterImage.kf.cancelDownloadTask()
    }
}


