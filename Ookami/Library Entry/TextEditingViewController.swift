//
//  TextEditingViewController.swift
//  Ookami
//
//  Created by Maka on 7/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

protocol TextEditingViewControllerDelegate: class {
    func textEditingViewController(_ controller: TextEditingViewController, didSave text: String)
}

//A View controller for showing a UITextView which can be edited.
//When presenting this don't animate it as it handles the animation itself.
class TextEditingViewController: UIViewController, UITextViewDelegate {
    
    weak var delegate: TextEditingViewControllerDelegate?
    
    fileprivate var placeHolderText: String
    fileprivate var initialText: String
    fileprivate var viewTitle: String
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Create a TextEditingViewController
    ///
    /// - Parameter text: The text to edit
    init(title: String, text: String, placeholder: String) {
        self.viewTitle = title
        self.initialText = text
        self.placeHolderText = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Do not use this to initialize `LibraryEntryViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use TextEditingViewController(text:)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 0
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            super.dismiss(animated: false, completion: completion)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = 0
        
        //Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.view.insertSubview(blurEffectView, at: 0)
        
        //Add slight round corner
        containerView.layer.cornerRadius = 2
        
        //Setup the text
        titleLabel.text = viewTitle
        textView.text = initialText.isEmpty ? placeHolderText : initialText
        textView.textColor = initialText.isEmpty ? UIColor.lightGray : UIColor.black
        textView.delegate = self
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        //If we find placeholder text then just return empty string
        let text: String = textView.text == placeHolderText ? "" : textView.text
        delegate?.textEditingViewController(self, didSave: text)
        self.dismiss(animated: false)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGray
        }
    }
    
}
