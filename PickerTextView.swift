//
//  PickerTextView.swift
//
//  Created by Vicente Suarez on 2/12/15.
//  Copyright (c) 2015 Vicente Suarez. All rights reserved.
//

import UIKit

enum PickerTextViewBorderStyle {
    case None, Line, Bezel, RoundedRect
}
/*
* Picker text view is a subclass of UITextView that simulates the appearance of the
* UITextField including the placeholder text and border styles.
*/
class PickerTextView: UITextView {
    
    let kLabelLeftOffset: CGFloat = 4.0         // Distance of placeholder from top of the text view.
    let kLabelTopOffsetRetina: CGFloat = 8.0    // Distance of placeholder from top in retina devices.
    var labelOffset: CGSize?                    // Holds the distance of the placeholder from the top and left of the text view.
    
    // MARK: - Place holder properties
    
    var placeholderText: String? {      // Stores the text of the placeholder.
        didSet {
            // Set the text in the label.
            placeHolderLabel.text = placeholderText
            placeHolderLabel.sizeToFit()
        }
    }
    
    var placeHolderLabel: UILabel {     // Stores the placeholder view.
        if _placeHolderLabel != nil {
            return _placeHolderLabel!
        }
        
        // Set-up the placeholder label
        let labelFrame = placeHolderLabelFrame
        let aPlaceHolderLabel = UILabel(frame: labelFrame)
        aPlaceHolderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        aPlaceHolderLabel.numberOfLines = 0
        aPlaceHolderLabel.font = font
        aPlaceHolderLabel.text = placeholderText
        aPlaceHolderLabel.textColor = UIColor(white: 0.75, alpha: 1.0)
        addSubview(aPlaceHolderLabel)
        sendSubviewToBack(aPlaceHolderLabel)
        
        _placeHolderLabel = aPlaceHolderLabel
        
        return _placeHolderLabel!
    }
    var _placeHolderLabel: UILabel?
    
    var placeHolderLabelFrame: CGRect {         // Stores the frame size and distance of the placeholder.
        if _placeHolderLabelFrame != nil {
            return _placeHolderLabelFrame!
        }
        
        // Set-up the placeholder position.
        let labelLeftOffset = kLabelLeftOffset
        var labelTopOffset: CGFloat = 0.0
        if UIScreen.mainScreen().scale == 2.0 {
            labelTopOffset = kLabelTopOffsetRetina
        }
        labelOffset = CGSizeMake(labelLeftOffset, labelTopOffset)
        
        // Set-up the position and size of the placeholder.
        let aPLaceHolderLabelFrame = CGRectMake(labelOffset!.width,
            labelOffset!.height,
            bounds.size.width - (2 * labelOffset!.width),
            bounds.size.height - (2 * labelOffset!.height))
        _placeHolderLabelFrame = aPLaceHolderLabelFrame
        
        return _placeHolderLabelFrame!
    }
    var _placeHolderLabelFrame: CGRect?
    
    // MARK: Text view properties
    
    override var text: String! {        // Holds the placeholder text.
        didSet {
            updatePlaceHolderLabelVisibility()
        }
    }
    
    override var font: UIFont! {        // Hods the font of the text and placeholder text.
        didSet {
            placeHolderLabel.font = font
        }
    }
    
    override var textAlignment: NSTextAlignment {       // Holds the alignment of the text and the placeholder text.
        didSet {
            placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    /*
    * Prevents events from happening on the text view when there is a custom input view assigned to the text view in place of the system keyboard.
    * @postcondition If there is an input view the text view prevents any actions such as copying and pasting.
    */
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return inputView == nil
    }
    
    /*
    * Hides the cursor when there is a custom input view assigned to the text view in place of the system keyboard.
    * @postcondition If there is a custom input view the text view hides the cursor.
    */
    override func caretRectForPosition(position: UITextPosition!) -> CGRect {
        if inputView != nil {
            return CGRectZero
        }
        return super.caretRectForPosition(position)
    }
    
    // MARK: - Initializers
    
    /*
    * @see finishInitialization:
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInizialization()
    }
    
    /*
    * Performs additional initialization.
    * @postcondition Self is an observer of the text in the text view.
    * @see textChanged:
    */
    func finishInizialization() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Placeholder actions
    
    /*
    * Hides the place holder text when the text view needs to display dictation results.
    * @postcondition The place holder text label is hidden.
    */
    override func insertDictationResultPlaceholder() -> AnyObject {
        
        let placeHolder: AnyObject = super.insertDictationResultPlaceholder()
        placeHolderLabel.hidden = true  // Hide placeholder.
        return placeHolder
    }
    
    /*
    * Shows the place holder text when the text view no longer needs to display dictation results.
    * @postcondition The place holder text label is showing is there is the text is empty.
    * @see updatePlaceholderVisibility
    */
    override func removeDictationResultPlaceholder(placeholder: AnyObject, willInsertResult: Bool) {
        super.removeDictationResultPlaceholder(placeholder, willInsertResult: willInsertResult)
        placeHolderLabel.hidden = false     // Show placeholder
        updatePlaceHolderLabelVisibility()  // Update visibilit of the placeholder.
    }
    
    /*
    * Shows and hides the placeholder according to the lenght of the text in the text label
    * @postcondition The placeholder text shows when the text is empty, it is hidden when the text length is greater than one.
    */
    func updatePlaceHolderLabelVisibility() {
        if text.isEmpty {
            placeHolderLabel.alpha = 1.0
        } else {
            placeHolderLabel.alpha = 0.0
        }
    }
    
    /*
    * Hides the place holder text when the text view needs to display dictation results.
    * @postcondition The place holder text label is hidden.
    */
    func textChanged(notification: NSNotification) {
        updatePlaceHolderLabelVisibility()
    }
    
    // MARK: - Text view border
    
    var borderView: UIView {        // The subview that displays the border of the text view
        if _borderView != nil {
            return _borderView!
        }
        
        // Create the border view and add it to the text view.
        let aBorderView = UIView()
        addSubview(aBorderView)
        aBorderView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Position the border view.
        let width = NSLayoutConstraint(item: aBorderView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: aBorderView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: aBorderView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: aBorderView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        addConstraints([width, height, top, leading])
        
        // Perform initial border set-up.
        aBorderView.clipsToBounds = true
        aBorderView.layer.masksToBounds = true
        aBorderView.layer.borderWidth = 1
        aBorderView.layer.shadowOffset = CGSizeMake(1, 1)
        aBorderView.layer.shadowOpacity = 1
        aBorderView.layer.shadowRadius = 0.6
        aBorderView.userInteractionEnabled = false
        
        _borderView = aBorderView
        
        return _borderView!
    }
    var _borderView: UIView?
    
    var borderStyle: PickerTextViewBorderStyle = PickerTextViewBorderStyle.None {   // The style of the border view
        didSet {
            switch borderStyle {
            case .None:
                borderView.layer.borderColor = UIColor.clearColor().CGColor
                borderView.layer.shadowColor = UIColor.clearColor().CGColor
            case .Line:
                borderView.layer.borderColor = UIColor.blackColor().CGColor
                borderView.layer.shadowColor = UIColor.clearColor().CGColor
                borderView.layer.cornerRadius = 0
            case .Bezel:
                borderView.layer.borderColor = UIColor.blackColor().CGColor
                borderView.layer.shadowColor = UIColor.grayColor().CGColor
                borderView.layer.cornerRadius = 0
            case .RoundedRect:
                borderView.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
                borderView.layer.shadowColor = UIColor.clearColor().CGColor
                borderView.layer.cornerRadius = 5
            }
        }
    }
}
