//
//  RangeSliderView.swift
//  RangeSlider
//
//  Created by Hung on 17/12/16.
//  Copyright © 2016 Hung. All rights reserved.
//

import UIKit


/// delegate for changed value
public protocol RangeSliderViewDelegate: AnyObject {
    /// slider value changed
    func sliderValueChanged(slider: RangeSlider?)
}

/// optional implementation
public extension RangeSliderViewDelegate{
    func sliderValueChanged(slider: RangeSlider?){}
}

/// Range slider with labels for upper and lower thumbs, title label and configurable step value (optional)
open class RangeSliderView: UIView {

    //MARK: properties
    
    open var delegate: RangeSliderViewDelegate? = nil
    
    /// Range slider
    open var rangeSlider : RangeSlider? = nil
    
    /// minimum value
    @IBInspectable open var minimumValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.minimumValue = minimumValue
        }
    }
    
    /// max value
    @IBInspectable open var maximumValue: Double = Double.greatestFiniteMagnitude {
        didSet {
            self.rangeSlider?.maximumValue = maximumValue
        }
    }
    
    /// value for lower thumb
    @IBInspectable open var lowerValue: Double = 0.0 {
        didSet {
            self.rangeSlider?.lowerValue = lowerValue
            
        }
    }
    
    /// value for upper thumb
    @IBInspectable open var upperValue: Double = Double.greatestFiniteMagnitude {
        didSet {
            self.rangeSlider?.upperValue = upperValue
            
        }
    }
    
    /// stepValue. If set, will snap to discrete step points along the slider . Default to nil
    @IBInspectable open var stepValue: Double = 1 {
        didSet {
            self.rangeSlider?.stepValue = stepValue
        }
    }
    
    /// minimum distance between the upper and lower thumbs.
    open var gapBetweenThumbs: Double = 2.0 {
        didSet {
            self.rangeSlider?.gapBetweenThumbs = gapBetweenThumbs
        }
    }
    
    /// tint color for track between 2 thumbs
    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackTintColor = trackTintColor
        }
    }
    
    
    /// track highlight tint color
    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.rangeSlider?.trackHighlightTintColor = trackHighlightTintColor
        }
    }
    
    
    /// thumb tint color
    @IBInspectable open var thumbTintColor: UIColor = UIColor.white {
        didSet {
            self.rangeSlider?.thumbTintColor = thumbTintColor
        }
    }
    
    /// thumb border color
    @IBInspectable open var thumbBorderColor: UIColor = UIColor.gray {
        didSet {
            self.rangeSlider?.thumbBorderColor = thumbBorderColor
        }
    }
    
    
    /// thumb border width
    @IBInspectable open var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            self.rangeSlider?.thumbBorderWidth = thumbBorderWidth

        }
    }
    
    /// set 0.0 for square thumbs to 1.0 for circle thumbs
    @IBInspectable open var curvaceousness: CGFloat = 1.0 {
        didSet {
            self.rangeSlider?.curvaceousness = curvaceousness
        }
    }
    
    /// thumb width and height
    @IBInspectable open var thumbSize: CGFloat = 32.0 {
        didSet {
            if let slider = self.rangeSlider {
                var oldFrame = slider.frame
                oldFrame.size.height = thumbSize
                slider.frame = oldFrame
            }
        }
    }
    
    //MARK: init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    /// setup
    open func setup() {
        self.autoresizingMask = [.flexibleWidth]
        
        self.rangeSlider = RangeSlider(frame: .zero)
        self.addSubview(self.rangeSlider!)
                
        self.rangeSlider?.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
    }
    
    //MARK: range slider delegage
    
    /// Range slider change events. Upper / lower labels will be updated accordingly.
    /// Selected value for filterItem will also be updated
    ///
    /// - Parameter rangeSlider: the changed rangeSlider
    @objc open func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
       
        delegate?.sliderValueChanged(slider: rangeSlider)
        
        
    }
    
    //MARK: -
    
   
    
    /// layout subviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let commonWidth = self.bounds.width
        rangeSlider?.frame = CGRect(x: 0,
                                   y: 0,
                                   width: commonWidth ,
                                   height: thumbSize )
        
        
        
    }
    
   
    
    /// get size for string of this font
    ///
    /// - parameter font: font
    /// - parameter string: a string
    /// - parameter width:  constrained width
    ///
    /// - returns: string size for constrained width
    private func estimatelabelSize(font: UIFont,string: String, constrainedToWidth width: Double) -> CGSize{
        return string.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                   attributes: [NSAttributedString.Key.font: font],
                                   context: nil).size

    }
    

}
