//
//  EntryButtonTableViewCell.swift
//  Ookami
//
//  Created by Maka on 7/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Reusable

protocol EntryButtonDelegate: class {
    func didTapButton(inCell: EntryButtonTableViewCell, indexPath: IndexPath?)
}

class EntryButtonTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    var indexPath: IndexPath?
    weak var delegate: EntryButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        headingLabel.textColor = Theme.EntryView().headingColor
        valueLabel.textColor = Theme.EntryView().valueColor
        button.setTitleColor(Theme.EntryView().tintColor, for: .normal)
    }

    
    @IBAction func didTapButton(_ sender: UIButton) {
        delegate?.didTapButton(inCell: self, indexPath: indexPath)
    }
    
}
