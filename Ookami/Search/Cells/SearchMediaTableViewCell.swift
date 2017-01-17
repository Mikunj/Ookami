//
//  SearchMediaTableViewCell.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

struct SearchMediaTableCellData {
    var name: String = ""
    var details: String = ""
    var synopsis: String = ""
    var posterImage: String? = nil
    var indicatorColor: UIColor = UIColor.white
}

class SearchMediaTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var posterImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(data: SearchMediaTableCellData) {
        //Set header stuff
        nameLabel.text = data.name
        detailLabel.text = data.details
        synopsisLabel.text = data.synopsis
        
        //Set the poster image
        if let poster = data.posterImage {
            let placeholder = UIImage(named: "default-poster.jpg")
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), placeholder: placeholder, options: [.transition(.fade(0.2)), .backgroundDecode])
        }else {
            posterImage.image = nil
        }

        indicatorView.isHidden = data.indicatorColor == UIColor.clear
        indicatorView.backgroundColor = data.indicatorColor
    }
    
}
