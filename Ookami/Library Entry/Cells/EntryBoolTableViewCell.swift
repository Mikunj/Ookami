//
//  EntryBoolTableViewCell.swift
//  Ookami
//
//  Created by Maka on 6/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

class EntryBoolTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var headingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headingLabel.textColor = Theme.EntryView().headingColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
