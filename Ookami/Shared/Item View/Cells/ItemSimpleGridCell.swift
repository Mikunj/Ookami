//
//  ItemSimpleGridCell.swift
//  Ookami
//
//  Created by Maka on 28/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

class ItemSimpleGridCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contentDetailView: GradientView!
    
    @IBOutlet weak var contentDetailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let viewTheme = Theme.ViewTheme()
        let color = viewTheme.backgroundColor
        posterImage.backgroundColor = color.isLight() ? color.darkened(amount: 0.1) : color.lighter(amount: 0.1)
    }
    
}

//MARK:- Reusable
extension ItemSimpleGridCell: NibReusable {}

//MARK:- Item Updatable
extension ItemSimpleGridCell: ItemUpdatable {
    
    /// Update the cell with the given data
    ///
    /// - Parameter data: The item data to update with
    func update(data: ItemData, loadImages: Bool) {
        nameLabel.text = data.name ?? "-"
        
        //Check if we have details, else just hide the view
        let isEmpty = data.details?.isEmpty ?? true
        contentDetailView.isHidden = data.details == nil || isEmpty
        contentDetailLabel.text = data.details ?? ""
        
        //Set the image
        if loadImages, let poster = data.posterImage {
            let placeholder = UIImage(named: "default-poster.jpg")
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), placeholder: placeholder, options: [.transition(.fade(0.4)), .backgroundDecode])
        } else {
            posterImage.image = nil
        }
        
    }
    
    func stopUpdating() {
        posterImage.kf.cancelDownloadTask()
        
        //This is to lower memory usage
        posterImage.image = nil
    }
}

