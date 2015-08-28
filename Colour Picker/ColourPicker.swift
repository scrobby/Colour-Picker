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
			_backgroundView?.backgroundColor = .blackColor()
			
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
	var _startAngle: Int!
	var startAngle: Int {
		get {
			var returnAngle = _startAngle
			
			if self.directionOfDisplay == .Clockwise {
				return _startAngle - 90
			} else {
				return _startAngle + 270
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
			
			let requiredDistanceFor360 = (360/self.colours.count) * (self.colours.count - 1)
			
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
	
	var animator: UIDynamicAnimator?
	
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
	
	var behavioursToAdd = Array<AnyObject>()
	
	
	//MARK: - Initialisers
	//// All the angles in here should be done as integers, up to the value of 359°
	convenience init(anchorPoint: CGPoint, colours: Array<UIColor>, frame: CGRect) {
		self.init(colours: colours, startAngle: 0, angleOfDisplay: 180, frame: frame)
	}
	
	init(colours: Array<UIColor>, startAngle: Int, angleOfDisplay: Int, frame: CGRect) {
		self.colours = colours
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.angleOfDisplay = angleOfDisplay
	}
	
	init(colours: Array<UIColor>, startAngle: Int, endAngle: Int, frame: CGRect) {
		self.colours = colours
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.endAngle = endAngle
	}
	
	override init(frame: CGRect) {
		self.colours = [.redColor(), .greenColor()]
		
		super.init(frame: frame)
		self.startAngle = 0
	}
	
	required init(coder aDecoder: NSCoder) {
		self.colours = [.redColor(), .greenColor()]
		
		super.init(coder: aDecoder)
		self.startAngle = 0
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
	
	var displayed = false
	var storedCenter: CGPoint?
	var originalCenter: CGPoint?
	
	//MARK: - Actions
	func didPressSelectedColourButton(sender: UIButton) {
		behavioursToAdd = Array()
		
		if displayed == false {
			sender.enabled = false
			
			self.keyWindow.addSubview(self.backgroundView)
			
			if storedCenter == nil {
				originalCenter = self.currentColourButton.center
				storedCenter = self.convertPoint(self.currentColourButton.center, toView: self.keyWindow)
			}
			
			var count = 0
			var points = Array<CGPoint>()
			
			//put them on screen
			for buttonToAdd in self.colourButtons {
				if buttonToAdd.superview == nil {
					buttonToAdd.setTranslatesAutoresizingMaskIntoConstraints(false)
					self.keyWindow.addSubview(buttonToAdd)
					buttonToAdd.center = self.storedCenter!
					buttonToAdd.alpha = 1.0
				}
				
				let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
				
				let newX = self.storedCenter!.x + self.radius * cos(currentAngle)
				let newY = self.storedCenter!.y + self.radius * sin(currentAngle)
				
				var snapBehaviour = UISnapBehavior(item: buttonToAdd, snapToPoint: CGPointMake(newX, newY))
				snapBehaviour.damping = 0.4 //(1.0 / CGFloat(self.colourButtons.count)) * CGFloat(count + 1)
				
				//				var magnitude = (1.0 / CGFloat(self.colourButtons.count)) * CGFloat(self.colourButtons.count - count)
				
				var pushBehaviour = UIPushBehavior(items: [buttonToAdd], mode: .Instantaneous)
				pushBehaviour.setAngle(currentAngle, magnitude: 0.5)
				
				behavioursToAdd += [snapBehaviour, pushBehaviour]
				
				
				count++
			}
			
			self.keyWindow.addSubview(self.currentColourButton)
			self.currentColourButton.center = self.storedCenter!
			
			var resistanceBehaviour = UIDynamicItemBehavior(items: self.colourButtons)
			resistanceBehaviour.resistance = 8.0
			
			var gravityBehaviour = UIGravityBehavior(items: self.colourButtons)
			gravityBehaviour.setAngle(self.startAngle.degreesToRadians, magnitude: 0.5)
			
			behavioursToAdd += [resistanceBehaviour]
			
			if self.animator == nil {
				self.animator = UIDynamicAnimator(referenceView: self.keyWindow)
			} else {
				self.animator?.removeAllBehaviors()
			}
			
			for behaviour in self.behavioursToAdd {
				self.animator!.addBehavior(behaviour as! UIDynamicBehavior)
			}
			
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.backgroundView.alpha = 0.5
			})
			
			displayed = true
			sender.enabled = true
		} else {
			sender.enabled = false
			
			var count = 0
			var points = Array<CGPoint>()
			
			//put them on screen
			for buttonToAdd in self.colourButtons {
				let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
				
				let newX = self.storedCenter!.x + self.radius * cos(currentAngle)
				let newY = self.storedCenter!.y + self.radius * sin(currentAngle)
				
				var snapBehaviour = UISnapBehavior(item: buttonToAdd, snapToPoint: self.storedCenter!)
				snapBehaviour.damping = 0.8
				
				var resistanceBehaviour = UIDynamicItemBehavior(items: [buttonToAdd])
				resistanceBehaviour.resistance = 10
				
				var magnitude = (1.0 / CGFloat(self.colourButtons.count)) * CGFloat(self.colourButtons.count - count)
				
				var pushBehaviour = UIPushBehavior(items: [buttonToAdd], mode: .Instantaneous)
				pushBehaviour.setAngle(currentAngle + 180.degreesToRadians, magnitude: magnitude)
				
				behavioursToAdd += [snapBehaviour, pushBehaviour, resistanceBehaviour]
				
				
				count++
			}
			
			var gravityBehaviour = UIGravityBehavior(items: self.colourButtons)
			gravityBehaviour.setAngle(0.0, magnitude: 0.2)
			
			//			behavioursToAdd += [gravityBehaviour]
			
			if self.animator == nil {
				self.animator = UIDynamicAnimator(referenceView: self.keyWindow)
			} else {
				self.animator?.removeAllBehaviors()
			}
			
			for behaviour in self.behavioursToAdd {
				self.animator!.addBehavior(behaviour as! UIDynamicBehavior)
			}
			
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.backgroundView.alpha = 0.0
				for button in self.colourButtons {
					button.alpha = 0.0
				}
				}, completion: { (completion: Bool) -> Void in
					self.addSubview(self.currentColourButton)
					self.currentColourButton.center = self.originalCenter!
					
					self.backgroundView.removeFromSuperview()
					for button in self.colourButtons {
						button.removeFromSuperview()
					}
					self.displayed = false
					sender.enabled = true
			})
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
		self.colour.setFill()
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