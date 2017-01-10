//
//  MediaTableHeaderView.swift
//  Ookami
//
//  Created by Maka on 10/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Kingfisher

struct MediaTableHeaderViewData {
    var title: String?
    var details: String?
    var posterImage: String?
    var coverImage: String?
    var youtubeID: String?
}

class MediaTableHeaderView: NibLoadableView {
    
    var data: MediaTableHeaderViewData? {
        didSet { updateData() }
    }

    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    
    private func updateData() {
        infoView.isHidden = data == nil
        
        titleLabel.text = data?.title ?? ""
        detailLabel.text = data?.details ?? ""
        
        let options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .backgroundDecode]
        
        if let poster = data?.posterImage {
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), options: options)
        } else {
            posterImage.image = nil
        }
        
        if let cover = data?.coverImage {
            coverImage.kf.setImage(with: URL(string: cover), options: options)
        } else {
            coverImage.image = nil
        }
    }
    
}
