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

protocol ColorPickerDelegate {
	func colorPickerDidSelectColor(color: UIColor)
}

@IBDesignable class ColorPicker: UIView {
	//MARK: Entirely calculated variables
	private var spacingAngle: CGFloat {
		let spacing = (CGFloat(self.angleOfDisplay)/CGFloat(self.colors.count - 1)).degreesToRadians
		if clockwise {
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
			_backgroundView?.backgroundColor = .blackColor()
			
			_backgroundView?.alpha = 0.0
		}
		
		return _backgroundView!
	}
	
	//MARK: Colors
	var colors = Array<UIColor>() {
		didSet {
			_colorButtons = nil //makes sure that there are enough buttons
			println("called")
		}
	}
	
	private var _currentColor: UIColor?
	var currentColor: UIColor {
		if _currentColor == nil {
			_currentColor = startColor
		}
		
		return _currentColor!
	}
	
	
	//MARK: Angles
	var _startAngle: Int?
	var startAngle: Int {
		get {
			if _startAngle == nil {
				_startAngle = 0
			}
			
			if clockwise {
				return _startAngle! - 90
			} else {
				return _startAngle! + 270
			}
		}
		set {
			_startAngle = newValue
		}
	}
	
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
			var proposedAngle = 180
			
			if _angleOfDisplay != nil {
				proposedAngle = _angleOfDisplay!
			} else if _endAngle != nil {
				proposedAngle = endAngle - startAngle
			}
			
			if proposedAngle < 0 {
				proposedAngle *= -1
			}
			
			let requiredDistanceFor360 = Int((360.0/CGFloat(self.colors.count)) * CGFloat(self.colors.count - 1))
			
			if proposedAngle > requiredDistanceFor360 {
				proposedAngle = requiredDistanceFor360
			}
			
			return proposedAngle
		}
		set {
			_angleOfDisplay = newValue
			
			_endAngle = nil
		}
	}
	
	//MARK: Buttons
	//TODO: Make it possible to add different shapes
	private var _colorButtons: Array<ColorPickerButton>?
	var colorButtons: Array<ColorPickerButton> {
		if _colorButtons == nil {
			_colorButtons = Array<ColorPickerButton>()
			
			for color in self.colors {
				let button = ColorPickerButton(frame: self.frame)
				button.color = color
				button.borderColor = self.borderColor
				button.borderWidth = self.borderWidth
				_colorButtons! += [button]
			}
		}
		return _colorButtons!
	}
	
	private var _currentColorButton: ColorPickerButton?
	var currentColorButton: ColorPickerButton {
		if _currentColorButton == nil {
			_currentColorButton = ColorPickerButton()
			
			_currentColorButton!.color = self.currentColor
			_currentColorButton!.borderColor = self.borderColor
			_currentColorButton!.borderWidth = self.borderWidth
			
			_currentColorButton!.addTarget(self, action: "didPressSelectedColorButton:", forControlEvents: .TouchUpInside)
		}
		return _currentColorButton!
	}
	
	//MARK: Other Variables
	var clockwise = false
	var radius: CGFloat = 60.0
	
	@IBInspectable var borderColor: UIColor = .whiteColor()
	@IBInspectable var borderWidth: CGFloat = 2.0
	@IBInspectable var startColor: UIColor = .redColor()
	
	
	//MARK: - Initialisers
	//// All the angles in here should be done as integers, up to the value of 359°
	convenience init(anchorPoint: CGPoint, colors: Array<UIColor>, frame: CGRect) {
		self.init(colors: colors, startAngle: 0, angleOfDisplay: 180, frame: frame)
	}
	
	init(colors: Array<UIColor>, startAngle: Int, angleOfDisplay: Int, frame: CGRect) {
		self.colors = colors
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.angleOfDisplay = angleOfDisplay
	}
	
	init(colors: Array<UIColor>, startAngle: Int, endAngle: Int, frame: CGRect) {
		self.colors = colors
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.endAngle = endAngle
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	//MARK: - Drawing the view
	override func drawRect(rect: CGRect) {
		self.currentColorButton.frame = self.bounds
		self.addSubview(self.currentColorButton)
	}
	
	override func intrinsicContentSize() -> CGSize {
		return CGSizeMake(30.0, 30.0)
	}
	
	
	//MARK: - Setters
	func setCurrentColor(color: UIColor, animated: Bool) {
		self._currentColor = color
		self._currentColorButton = nil
		self.setNeedsDisplay()
	}
	
	var displayed = false
	var storedCenter: CGPoint?
	var originalCenter: CGPoint?
	
	//MARK: - Actions
	func didPressSelectedColorButton(sender: UIButton) {
		if displayed == false {
			sender.enabled = false
			
			self.show({ () -> Void in
				self.displayed = true
				sender.enabled = true
			})
		} else {
			sender.enabled = false
			
			self.dismiss({ () -> Void in
				self.addSubview(self.currentColorButton)
				self.displayed = false
				sender.enabled = true
			})
		}
	}
	
	func show(completion: () -> Void) {
		self.keyWindow.addSubview(self.backgroundView)
		
		if storedCenter == nil {
			originalCenter = self.currentColorButton.center
			storedCenter = self.convertPoint(self.currentColorButton.center, toView: self.keyWindow)
		}
		
		var count = 0
		var totalTime = 0.0
		var delayInterval = 0.05
		
		//put them on screen
		for buttonToAdd in self.colorButtons {
			if buttonToAdd.superview == nil {
				buttonToAdd.setTranslatesAutoresizingMaskIntoConstraints(false)
				self.keyWindow.addSubview(buttonToAdd)
			}
			
			buttonToAdd.alpha = 1.0
			buttonToAdd.center = self.storedCenter!
			
			let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
			
			let newX = self.storedCenter!.x + self.radius * cos(currentAngle)
			let newY = self.storedCenter!.y + self.radius * sin(currentAngle)
			
			let delayTime = Double(count) * delayInterval
			
			UIView.animateWithDuration(0.3, delay:delayTime , usingSpringWithDamping: 0.6, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
				buttonToAdd.center = CGPointMake(newX, newY)
				}, completion: { (success: Bool) -> Void in
			})
			
			count++
		}
		
		totalTime = Double(self.colorButtons.count - 1) * delayInterval + 0.3
		
		self.keyWindow.addSubview(self.currentColorButton)
		self.currentColorButton.center = self.storedCenter!
		
		UIView.animateWithDuration(totalTime, animations: { () -> Void in
			self.backgroundView.alpha = 0.5
			}, completion: { (success: Bool) -> Void in
				completion()
		})
	}
	
	func dismiss(completion: () -> Void) {
		var count = 0
		var totalTime = 0.0
		var delayInterval = 0.05
		
		for buttonToAdd in self.colorButtons {
			let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
			
			let newX = self.storedCenter!.x + (self.radius + 20) * cos(currentAngle)
			let newY = self.storedCenter!.y + (self.radius + 20) * sin(currentAngle)
			let newPoint = CGPointMake(newX, newY)
			
			let delayTime = Double(self.colorButtons.count - count) * delayInterval/1.5
			
			UIView.animateWithDuration(0.07, delay: delayTime - 0.07, options: .CurveLinear, animations: { () -> Void in
				buttonToAdd.center = newPoint
				}, completion: nil)
			
			UIView.animateWithDuration(0.2, delay: delayTime, options: .CurveEaseOut, animations: { () -> Void in
				buttonToAdd.center = self.storedCenter!
				}, completion: { (success: Bool) -> Void in
					buttonToAdd.removeFromSuperview()
			})
			
			count++
		}
		
		totalTime = Double(self.colorButtons.count - 1) * delayInterval/1.5 + 0.2
		
		UIView.animateWithDuration(totalTime, animations: { () -> Void in
			self.backgroundView.alpha = 0.0
			}, completion: { (done: Bool) -> Void in
				self.currentColorButton.frame = self.bounds
				self.backgroundView.removeFromSuperview()
				completion()
		})
	}
}


//MARK: - Color Picker Button

enum ColorPickerButtonShape {
	case Circle
}

@IBDesignable class ColorPickerButton: UIButton {
	var color: UIColor = .redColor()
	var borderColor: UIColor = .whiteColor()
	var borderWidth: CGFloat = 1.0
	
	var snapBehaviour: UISnapBehavior?
	
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
		self.color.setFill()
		CGContextSetLineWidth(context, borderWidth)
		CGContextFillEllipseInRect(context, newRect)
		CGContextStrokeEllipseInRect(context, newRect)
	}
	
	func configureSnapBehaviour() {
		self.snapBehaviour = UISnapBehavior(item: self, snapToPoint: self.center)
		println(self.center)
	}
	
	override func intrinsicContentSize() -> CGSize {
		return CGSizeMake(30.0, 30.0)
	}
}


//MARK: - Extensions

extension Int {
	var degreesToRadians : CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
}

extension CGFloat {
	var degreesToRadians : CGFloat {
		return self * CGFloat(M_PI) / 180.0
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
}