//
//  EntryMediaHeaderView.swift
//  Ookami
//
//  Created by Maka on 6/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Kingfisher
import OokamiKit

protocol EntryMediaHeaderViewDelegate: class {
    func didTapMediaButton()
}

struct EntryMediaHeaderViewData {
    var mediaType: Media.MediaType? = nil
    var posterImage: String? = nil
    var coverImage: String? = nil
    var name: String = ""
    var details: String = ""
    var synopsis: String = ""
}

class EntryMediaHeaderView: NibLoadableView {
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    
    @IBOutlet weak var mediaButton: UIButton!
    
    weak var delegate: EntryMediaHeaderViewDelegate?
    
    init(data: EntryMediaHeaderViewData) {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let width = UIScreen.main.bounds.width
        let height: CGFloat = isIpad ? 332 : 166
        
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        
        update(data: data)
        
        mediaButton.backgroundColor = Theme.Colors().secondary
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use EntryMediaHeaderView.init(data:)")
    }
    
    @IBAction func didTapMediaButton(_ sender: UIButton) {
        delegate?.didTapMediaButton()
    }
    /// Update the header view with new data
    ///
    /// - Parameter data: The data to update with
    func update(data: EntryMediaHeaderViewData) {
        
        //Set the media button title
        var mediaText = "Media"
        if let type = data.mediaType {
            mediaText = type == .anime ? "Anime" : "Manga"
        }
        mediaButton.setTitle("Go To \(mediaText) Page", for: .normal)
        
        //Set header stuff
        nameLabel.text = data.name
        detailLabel.text = data.details
        synopsisLabel.text = data.synopsis
        
        //Set the poster image
        if let poster = data.posterImage {
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), options: [.transition(.fade(0.2)), .backgroundDecode])
        }else {
            posterImage.image = nil
        }
        
        //Set the cover image
        if let cover = data.coverImage {
            
            //Default to poster image if cover is empty
            var url = URL(string: cover)
            if cover.isEmpty, let poster = data.posterImage {
                url = URL(string: poster)
            }
            
            let processor = BlurImageProcessor(blurRadius: 6)
            let placeholder = UIImage(named: "default-cover")
            coverImage.kf.setImage(with: url, placeholder: placeholder, options: [.backgroundDecode, .processor(processor), .transition(.fade(0.2))])
        } else {
            coverImage.image = nil
        }
    }
    
}
