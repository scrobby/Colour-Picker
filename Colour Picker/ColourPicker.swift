/* ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
The MIT License (MIT)

Copyright (c) 2015 Carl Goldsmith

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-- */



import Foundation
import UIKit

enum ColourPickerDirection {
	case Clockwise
	case CounterClockwise
}

@IBDesignable class ColourPicker: UIView {
	//MARK: Entirely calculated variables
	private var spacingAngle: CGFloat {
		let spacing = (self.angleOfDisplay/(self.colours.count - 1)).degreesToRadians
		if self.directionOfDisplay == .Clockwise {
			return spacing
		} else {
			return spacing * -1
		}
	}
	private var keyWindow: UIWindow {
		return UIApplication.sharedApplication().keyWindow!
	}
	
	private var _backgroundView: UIView?
	private var backgroundView: UIView {
		if _backgroundView == nil {
			_backgroundView = UIView(frame: keyWindow.bounds)
			_backgroundView?.setTranslatesAutoresizingMaskIntoConstraints(false)
			
			_backgroundView?.alpha = 0.0
		}
		
		return _backgroundView!
	}
	
	//MARK: Colours
	var colours: Array<UIColor> {
		didSet {
			_colourButtons = nil //makes sure that there are enough buttons
		}
	}
	//	private var _colours: Array<UIColor>?
	//	var colours: Array<UIColor> {
	//		get {
	//			if self._colours == nil {
	//				self._colours = [.redColor(), .greenColor(), .blueColor(), .yellowColor(), .purpleColor()]
	//			}
	//			return self._colours!
	//		}
	//		set {
	//			self._colours = newValue
	//		}
	//	}
	
	private var _selectedColour: UIColor? //if no selected colour is given, the picker will automatically choose the first in the array
	var selectedColour: UIColor {
		get {
			if self._selectedColour == nil {
				self.selectedColour = self.colours[0]
			}
			return self._selectedColour!
		}
		set {
			self._selectedColour = newValue
		}
	}
	
	
	//MARK: Angles
	var startAngle: Int
	
	private var _endAngle: Int?
	var endAngle: Int {
		get {
			if _endAngle == nil {
				_endAngle = startAngle + angleOfDisplay
			}
			
			return _endAngle!
		}
		set {
			if startAngle + newValue < 359 && newValue > 0 {
				_endAngle = newValue
			} else if newValue < 0 {
				_endAngle = 0
			} else {
				_endAngle = 359 - startAngle
			}
			
			_angleOfDisplay = nil
		}
	}
	
	private var _angleOfDisplay: Int?
	var angleOfDisplay: Int {
		get {
			if _angleOfDisplay != nil {
				return _angleOfDisplay!
			} else if _endAngle != nil {
				return endAngle - startAngle
			} else {
				return 180
			}
		}
		set {
			if newValue < 359 && newValue > 0 {
				_angleOfDisplay = newValue
			} else if newValue < 0 {
				_angleOfDisplay = 0
			} else {
				_angleOfDisplay = 359
			}
			
			_endAngle = nil
		}
	}
	
	//MARK: Buttons
	//TODO: Make it possible to add different shapes
	private var _colourButtons: Array<ColourPickerButton>?
	var colourButtons: Array<ColourPickerButton> {
		if _colourButtons == nil {
			_colourButtons = Array<ColourPickerButton>()
			
			for colour in self.colours {
				let button = ColourPickerButton(frame: self.frame)
				button.colour = colour
				button.borderColor = self.borderColour
				button.borderWidth = self.borderWidth
				_colourButtons! += [button]
			}
		}
		return _colourButtons!
	}
	
	private var _currentColourButton: ColourPickerButton?
	var currentColourButton: ColourPickerButton {
		if _currentColourButton == nil {
			_currentColourButton = ColourPickerButton()
			
			_currentColourButton!.colour = self.currentColour
			_currentColourButton!.borderColor = self.borderColour
			_currentColourButton!.borderWidth = self.borderWidth
			
			_currentColourButton!.addTarget(self, action: "didPressSelectedColourButton:", forControlEvents: .TouchUpInside)
		}
		return _currentColourButton!
	}
	
	//MARK: Other Variables
	var directionOfDisplay: ColourPickerDirection = .CounterClockwise
	var radius: CGFloat = 60.0
	
	@IBInspectable var startColour: UIColor = .redColor()
	private var _currentColour: UIColor?
	var currentColour: UIColor {
		if _currentColour == nil {
			_currentColour = startColour
		}
		
		return _currentColour!
	}
	
	@IBInspectable var borderColour: UIColor = .whiteColor()
	@IBInspectable var borderWidth: CGFloat = 2.0
	
	
	//MARK: - Initialisers
	//// All the angles in here should be done as integers, up to the value of 359°
	convenience init(anchorPoint: CGPoint, colours: Array<UIColor>, frame: CGRect) {
		self.init(colours: colours, startAngle: 0, angleOfDisplay: 180, frame: frame)
	}
	
	init(colours: Array<UIColor>, startAngle: Int, angleOfDisplay: Int, frame: CGRect) {
		self.colours = colours
		self.startAngle = startAngle
		
		super.init(frame: frame)
		
		self.angleOfDisplay = angleOfDisplay
	}
	
	init(colours: Array<UIColor>, startAngle: Int, endAngle: Int, frame: CGRect) {
		self.colours = colours
		self.startAngle = startAngle
		
		super.init(frame: frame)
		
		self.endAngle = endAngle
	}
	
	override init(frame: CGRect) {
		self.colours = [.redColor(), .greenColor()]
		self.startAngle = 0
		
		super.init(frame: frame)
	}
	
	required init(coder aDecoder: NSCoder) {
		self.colours = [.redColor(), .greenColor()]
		self.startAngle = 0
		
		super.init(coder: aDecoder)
	}
	
	
	//MARK: - Drawing the view
	override func drawRect(rect: CGRect) {
		self.currentColourButton.frame = self.bounds
		self.addSubview(self.currentColourButton)
	}
	
	override func intrinsicContentSize() -> CGSize {
		return CGSizeMake(30.0, 30.0)
	}
	
	
	//MARK: - Setters
	func setCurrentColour(colour: UIColor, animated: Bool) {
		self._currentColour = colour
		self._currentColourButton = nil
		self.setNeedsDisplay()
	}
	
	
	//MARK: - Actions
	func didPressSelectedColourButton(sender: UIButton) {
//		self.keyWindow.addSubview(self.backgroundView)
//		var viewsDict: Dictionary<String, UIView> = ["backgroundView" : backgroundView]
//		var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: nil, metrics: nil, views: viewsDict)
//		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView]|", options: nil, metrics: nil, views: viewsDict)
//		self.keyWindow.addConstraints(constraints)
//		
//		[UIView.animateWithDuration(0.5, animations: { () -> Void in
//			self.backgroundView.alpha = 0.4
//		})]
		
		let centerInKeyWindow = keyWindow.convertPoint(self.center, toWindow: self.keyWindow)
		let newCenter = CGPointMake(centerInKeyWindow.x, centerInKeyWindow.y - self.radius)
		
//		self.keyWindow.addSubview(self.currentColourButton)
//		self.currentColourButton.center = centerInKeyWindow
		
		var count = 0
		
		for buttonToAdd in self.colourButtons {
			self.keyWindow.addSubview(buttonToAdd)
			buttonToAdd.center = centerInKeyWindow
			buttonToAdd.layer.anchorPoint = CGPointMake(0.5, (radius / buttonToAdd.frame.size.height))
//			buttonToAdd.layer.anchorPoint = centerInKeyWindow
			
			buttonToAdd.backgroundColor = .redColor()
			
			let rotation = CGAffineTransformMakeRotation(self.spacingAngle * CGFloat(count))
			buttonToAdd.transform = rotation
			
			println("Tried: \(buttonToAdd.frame)")
			count++
		}
	}
}


enum ColourPickerButtonShape {
	case Circle
}

@IBDesignable class ColourPickerButton: UIButton {
	var colour: UIColor = .redColor()
	var borderColor: UIColor = .whiteColor()
	var borderWidth: CGFloat = 1.0
	
	private var _backgroundColor: UIColor?
	override var backgroundColor: UIColor? {
		get {
			if _backgroundColor == nil {
				_backgroundColor = .clearColor()
			}
			
			return _backgroundColor!
		}
		set {
			_backgroundColor = newValue
		}
	}
	
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		let newRect = rect.rectThatFitsInsideSelfWithStrokeWidth(borderWidth)
		
		self.borderColor.setStroke()
		self.colour.setFill()
		CGContextSetLineWidth(context, borderWidth)
		CGContextFillEllipseInRect(context, newRect)
		CGContextStrokeEllipseInRect(context, newRect)
	}
}

extension Int {
	var degreesToRadians : CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
}

extension CGRect {
	func rectThatFitsInsideSelfWithStrokeWidth(width: CGFloat) -> CGRect {
		return CGRectMake(self.origin.x + width, self.origin.y + width, self.width - width * 2, self.height - width * 2)
	}
}

extension UIColor {
	func adjustLightness(value: CGFloat) -> UIColor {
		let newRed = redValue * value
		let newGreen = greenValue * value
		let newBlue = blueValue * value
		return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
	}
	
	var RGBValues: (red: CGFloat, green: CGFloat, blue: CGFloat) {
		let components = CGColorGetComponents(self.CGColor)
		
		let red = components[0]
		let green = components[1]
		let blue = components[2]
		
		return (red, green, blue)
	}
	
	var redValue: CGFloat {
		return self.RGBValues.red
	}
	
	var greenValue: CGFloat {
		return self.RGBValues.green
	}
	
	var blueValue: CGFloat {
		return self.RGBValues.blue
	}
	
	func greyscaleVersion() -> UIColor {
		let newValue = (redValue + greenValue + blueValue) / 3
		return UIColor(red: newValue, green: newValue, blue: newValue, alpha: 1.0)
	}
}