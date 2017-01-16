//
//  MediaTableHeaderView.swift
//  Ookami
//
//  Created by Maka on 10/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Kingfisher

//TODO: Improve this view ... it just looks ugly

protocol MediaTableHeaderViewDelegate: class {
    func didTapEntryButton(state: MediaTableHeaderView.EntryButtonState)
    func didTapTrailerButton()
    func didTapCoverImage(_ imageView: UIImageView)
}

struct MediaTableHeaderViewData {
    var title: String?
    var details: String?
    var airing: String?
    var posterImage: String?
    var coverImage: String?
    var showTrailerIcon: Bool = false
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
    
    @IBOutlet weak var trailerView: UIView!
    
    @IBOutlet weak var trailerImage: UIImageView!
    
    @IBOutlet weak var seperatorView: UIView!
    
    weak var delegate: MediaTableHeaderViewDelegate?
    var trailerTapGesture: UITapGestureRecognizer?
    var coverTapGesture: UITapGestureRecognizer?
    
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
        trailerView.isHidden = !showIcon
        trailerImage.image = FontAwesomeIcon.playIcon.image(ofSize: CGSize(width: 18, height: 18), color: UIColor.white)
        
        if trailerTapGesture == nil {
            trailerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTrailerButton(_:)))
            trailerView.addGestureRecognizer(trailerTapGesture!)
        }
        
        if coverTapGesture == nil {
            coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCoverImage(_:)))
            seperatorView.addGestureRecognizer(coverTapGesture!)
        }
        
        let options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .backgroundDecode]
        
        if let poster = data?.posterImage {
            let placeholder = UIImage(named: "default-poster.jpg")
            posterImage.kf.indicatorType = .activity
            posterImage.kf.setImage(with: URL(string: poster), placeholder: placeholder, options: options)
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
            entryButton.setIconImage(withIcon: FontAwesomeIcon.pencilIcon, size: CGSize(width: 14, height: 14), color: UIColor.white, forState: .normal)
            break
        }
    }

    @IBAction func didTapEntryButton(_ sender: Any) {
        let state = data?.entryState ?? .add
        delegate?.didTapEntryButton(state: state)
    }
    
    @IBAction func didTapCoverImage(_ sender: Any) {
        delegate?.didTapCoverImage(coverImage)
    }
    

    @IBAction func didTapTrailerButton(_ sender: Any) {
        delegate?.didTapTrailerButton()
    }
    
}
