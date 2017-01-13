//
//  MediaTableHeaderView.swift
//  Ookami
//
//  Created by Maka on 10/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Kingfisher

protocol MediaTableHeaderViewDelegate: class {
    func didTapEntryButton(state: MediaTableHeaderView.EntryButtonState)
    func didTapTrailerButton()
}

struct MediaTableHeaderViewData {
    var title: String?
    var details: String?
    var airing: String?
    var posterImage: String?
    var coverImage: String?
    var showTrailerIcon: Bool
    var entryState: MediaTableHeaderView.EntryButtonState = .add
}

class MediaTableHeaderView: NibLoadableView {

    enum EntryButtonState {
        case add
        case edit
    }
    
    var data: MediaTableHeaderViewData? {
        didSet { updateData() }
    }
    
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var airingLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var entryButton: UIButton!
    
    @IBOutlet weak var trailerButton: UIButton!
    
    weak var delegate: MediaTableHeaderViewDelegate?
    
    private func updateData() {
        infoView.isHidden = data == nil
        
        titleLabel.text = data?.title ?? ""
        detailLabel.text = data?.details ?? ""
        
        airingLabel.isHidden = data?.airing == nil
        airingLabel.text = data?.airing ?? ""
        
        updateEntryButton(with: .add)
        if let state = data?.entryState {
            updateEntryButton(with: state)
        }
        
        let showIcon = data?.showTrailerIcon ?? false
        trailerButton.isHidden = !showIcon
        trailerButton.setIconImage(withIcon: FontAwesomeIcon.playIcon, size: CGSize(width: 22, height: 22), color: UIColor.white, forState: .normal)
        
        let options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .backgroundDecode]
        
        if let poster = data?.posterImage {
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), options: options)
        } else {
            posterImage.image = nil
        }
        
        if let cover = data?.coverImage {
            let placeholder = UIImage(named: "default-cover")
            coverImage.kf.setImage(with: URL(string: cover), placeholder: placeholder, options: options)
        } else {
            coverImage.image = nil
        }
    }
    
    func updateEntryButton(with state: MediaTableHeaderView.EntryButtonState) {
        
        entryButton.backgroundColor = Theme.Colors().secondary
        
        switch state {
        case .add:
            entryButton.setTitle("Add to library", for: .normal)
            entryButton.setImage(nil, for: .normal)
            break
        case .edit:
            entryButton.setTitle("Entry", for: .normal)
            entryButton.setIconImage(withIcon: FontAwesomeIcon.pencilIcon, size: CGSize(width: 10, height: 10), color: UIColor.white, forState: .normal)
            break
        }
    }

    @IBAction func didTapEntryButton(_ sender: Any) {
        let state = data?.entryState ?? .add
        delegate?.didTapEntryButton(state: state)
    }
    

    @IBAction func didTapTrailerButton(_ sender: Any) {
        delegate?.didTapTrailerButton()
    }
    
}
