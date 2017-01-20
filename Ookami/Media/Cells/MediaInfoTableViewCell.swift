//
//  MediaInfoTableViewCell.swift
//  Ookami
//
//  Created by Maka on 20/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

class MediaInfoTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        infoTitleLabel.textColor = Theme.Colors().secondary
        infoLabel.textColor = Theme.Colors().primary
    }
}
