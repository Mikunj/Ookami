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
import DynamicColor

//Constraints still breaking on mobile .... WHY!!
//It resolves itself automatically anyway but the console gets spammed with messages


final class ItemDetailGridCell: UICollectionViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var contentDetailView: GradientView!
    
    @IBOutlet weak var contentDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let labelTheme = Theme.TextTheme()
        countLabel.textColor = labelTheme.textColor
        
        let viewTheme = Theme.ViewTheme()
        let color = viewTheme.backgroundColor
        countLabel.backgroundColor = color
        posterImage.backgroundColor = color.isLight() ? color.darkened(amount: 0.1) : color.lighter(amount: 0.1)
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
        countLabel.text = data.countString ?? "-"
        
        //Check if we have details, else just hide the view
        let isEmpty = data.details?.isEmpty ?? true
        contentDetailView.isHidden = data.details == nil || isEmpty
        contentDetailLabel.text = data.details ?? ""
        
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
        
        //This is to lower memory usage
        posterImage.image = nil
    }
}


