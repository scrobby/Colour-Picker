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

//define π for easy access
let π = CGFloat(M_PI)

//define error types
enum ColorPickerError: ErrorType {
	case TotalAngleTooLarge(message: String)
}


protocol ColorPickerDelegate {
	func colorPickerDidSelectColor(picker: ColorPicker, color: UIColor)
	func colorPickerDidCancel(picker: ColorPicker)
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
			_backgroundView?.translatesAutoresizingMaskIntoConstraints = false
			_backgroundView?.backgroundColor = .blackColor()
			
			_backgroundView?.alpha = 0.0
			
			let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: "backgroundTapped")
			_backgroundView?.addGestureRecognizer(tapGestureRecogniser)
		}
		
		return _backgroundView!
	}
	
	//MARK: Colors
	///An array of UIColor objects that will be displayed by the picker
	var colors = Array<UIColor>() {
		didSet {
			_colorButtons = nil //ensures that the buttons are created again after a colour is added/removed
		}
	}
	
	private var _currentColor: UIColor? {
		didSet {
			self.currentColorButton.color = currentColor
		}
	}
	///The colour currently being displayed at the center of the picker
	var currentColor: UIColor {
		if _currentColor == nil {
			_currentColor = startColor
		}
		
		return _currentColor!
	}
	
	
	//MARK: Angles
	private var _startAngle: Int?
	///The angle at which the first colour will be displayed. 0° is at the top, can be a value of up to 360°.
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
	///The angle at which the final colour will be. Can be up to 359°. If angleOfDisplay is set, there is no need to set this property.
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
			
			//force the angle of display to recalculate when it is called
			_angleOfDisplay = nil
		}
	}
	
	private var _angleOfDisplay: Int?
	///How far the colours should appear around the circle. Can be up to 359°. If endAngle is set, there is no need to set this property.
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
			
			//force the end angle to recalculate when it is next called
			_endAngle = nil
		}
	}
	
	//MARK: Buttons
	//TODO: Make it possible to add different shapes
	private var _colorButtons: Array<ColorPickerButton>?
	///The ColorPickerButton objects that will be displayed by the ColorPicker.
	var colorButtons: Array<ColorPickerButton> {
		if _colorButtons == nil {
			_colorButtons = Array<ColorPickerButton>()
			
			for color in self.colors {
				let button = ColorPickerButton(frame: self.frame)
				button.color = color
				button.borderColor = self.borderColor
				button.borderWidth = self.borderWidth
				
				button.addTarget(self, action: "didPressColorButton:", forControlEvents: .TouchUpInside)
				
				_colorButtons! += [button]
			}
		}
		return _colorButtons!
	}
	
	private var _currentColorButton: ColorPickerButton?
	///The ColorPickerButton in the centre, displaying the colour currently selected by the Picker.
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
	///Determines in which direction the position and animation should occur.
	var clockwise = false
	
	///Determines how far from the centre the buttons should be displayed.
	var radius: CGFloat = 60.0
	
	//The delegate of the ColorPicker.
	var delegate: ColorPickerDelegate?
	
	//The border colour displayed by all of the ColorPickerButton objects.
	@IBInspectable var borderColor: UIColor = .whiteColor()
	
	//The width of the border displayed by all the ColorPickerButton onjets.
	@IBInspectable var borderWidth: CGFloat = 2.0
	
	///Used only for ColorPickers created in IB.
	@IBInspectable private var startColor: UIColor = .redColor()
	
	
	//MARK: - Initialisers
	
	/// Initialises a ColourPicker object with the default settings.
	/// - Parameter colors: The UIColor objects that should be displayed by the picker.
	/// - Parameter frame: The CGRect in which the picker should be drawn (this should be the size of only one ColorPickerButton: the rest will be displayed around it, outside of the frame.
	/// - Parameter delegate: The delegate for the ColourPicker. Must conform to ColorPickerDelegate.
	convenience init(colors: Array<UIColor>, frame: CGRect, delegate: ColorPickerDelegate?) {
		self.init(colors: colors, startAngle: 0, angleOfDisplay: 180, frame: frame)
		self.delegate = delegate
	}
	
	/// Initialises a ColourPicker object with a few more parameters. A delegate must be set after.
	/// - Parameter colors: The UIColor objects that should be displayed by the picker.
	/// - Parameter startAngle: The angle at which the first ColourPicker button should be displayed
	/// - Parameter angleOfDisplay: The total angle over which the buttons should be displayed. This should not exceed 360° or it will automatically be capped.
	/// - Parameter frame: The CGRect in which the picker should be drawn (this should be the size of only one ColorPickerButton: the rest will be displayed around it, outside of the frame.
	init(colors: Array<UIColor>, startAngle: Int, angleOfDisplay: Int, frame: CGRect) {
		self.colors = colors
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.angleOfDisplay = angleOfDisplay
	}
	
	/// Initialises a ColourPicker object with a few more parameters. A delegate must be set after.
	/// - Parameter colors: The UIColor objects that should be displayed by the picker.
	/// - Parameter startAngle: The angle at which the first ColourPicker button should be displayed
	/// - Parameter endAngle: The final angle at which the buttons should be displayed. The difference between this and the **startAngle** should not exceed 360°.
	/// - Parameter frame: The CGRect in which the picker should be drawn (this should be the size of only one ColorPickerButton: the rest will be displayed around it, outside of the frame.
	init(colors: Array<UIColor>, startAngle: Int, endAngle: Int, frame: CGRect) {
		self.colors = colors
		
		super.init(frame: frame)
		
		self.startAngle = startAngle
		self.endAngle = endAngle
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
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
	/// Sets the colour of the main ColorPickerButton.
	/// - Parameter color: The colour to be displayed.
	func setCurrentColor(color: UIColor) {
		self._currentColor = color
	}
	
	/// Will be true if the ColourPicker is currently visible
	var displayed = false
	
	/// The center of the button relative to the key window
	private var storedCenter: CGPoint?
	
	// The center of the button in its original view
	private var originalCenter: CGPoint?
	
	
	//MARK: - Actions
	/// Called when the main colour button is tapped.
	/// Will either show or hide the picker
	/// - Parameter sender: The button which was tapped.
	func didPressSelectedColorButton(sender: ColorPickerButton) {
		if displayed == false {
			self.show({ () -> Void in
				self.displayed = true
			})
		} else {
			self.delegate?.colorPickerDidCancel(self)
			
			self.dismiss(nil, completion: { () -> Void in
				
			})
		}
	}
	
	/// Called when one of the other colour buttons was tapped.
	/// - Parameter sender: The button which was tapped.
	func didPressColorButton(sender: ColorPickerButton) {
		self.delegate?.colorPickerDidSelectColor(self, color: sender.color)
		self.dismiss(sender, completion: { () -> Void in
			self.setCurrentColor(sender.color)
		})
	}
	
	/// Called when the background has been tapped.
	/// Will cause the picker to react as though it has been cancelled.
	private func backgroundTapped() {
		self.delegate?.colorPickerDidCancel(self)
		self.dismiss(nil, completion: { () -> Void in
			
		})
	}
	
	
	//MARK: - Showing/Dismissing
	/// Causes the picker to show.
	/// This results in the ColorPicker moving from its original superview into the sharedApplication's keyWindow.
	/// - Parameter completion: A block that will be carried out once the ColourPicker has been shown.
	func show(completion: () -> Void) {
		self.currentColorButton.enabled = false
		self.backgroundView.userInteractionEnabled = false
		self.keyWindow.addSubview(self.backgroundView)
		
		if storedCenter == nil {
			originalCenter = self.currentColorButton.center
			storedCenter = self.convertPoint(self.currentColorButton.center, toView: self.keyWindow)
		}
		
		var count = 0
		
		let totalDelay = 0.3
		let intervalDelay = (totalDelay / Double(self.colorButtons.count))
		let animationTime = 0.3
		
		//put them on screen
		for buttonToAdd in self.colorButtons {
			if buttonToAdd.superview == nil {
				buttonToAdd.translatesAutoresizingMaskIntoConstraints = true
				self.keyWindow.addSubview(buttonToAdd)
			}
			
			buttonToAdd.alpha = 1.0
			buttonToAdd.center = self.storedCenter!
			
			let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
			
			let newX = self.storedCenter!.x + self.radius * cos(currentAngle)
			let newY = self.storedCenter!.y + self.radius * sin(currentAngle)
			
			let delayTime = Double(count) * intervalDelay
			
			UIView.animateWithDuration(animationTime, delay:delayTime , usingSpringWithDamping: 0.6, initialSpringVelocity: 6.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
				buttonToAdd.center = CGPointMake(newX, newY)
				}, completion: { (success: Bool) -> Void in
			})
			
			count++
		}
		
		let totalTime = totalDelay + animationTime
		
		self.keyWindow.addSubview(self.currentColorButton)
		self.currentColorButton.center = self.storedCenter!
		
		self.currentColorButton.showCloseButton((time: totalTime - intervalDelay, totalAngle: self.angleOfDisplay, self.clockwise))
		
		UIView.animateWithDuration(totalTime, animations: { () -> Void in
			self.backgroundView.alpha = 0.5
			}, completion: { (success: Bool) -> Void in
				completion()
				self.currentColorButton.enabled = true
				self.backgroundView.userInteractionEnabled = true
		})
	}
	
	/// Causes the picker to disappear.
	/// This results in the ColorPicker moving the sharedApplication's keyWindow to its original superview.
	/// - Parameter completion: A block that will be carried out once the ColourPicker has been dismissed.
	func dismiss(selectedColorButton: ColorPickerButton?, completion: () -> Void) {
		//ensure that the colour picker cannot be dismissed/shown whilst animating
		self.currentColorButton.enabled = false
		self.backgroundView.userInteractionEnabled = false
		
		//set up the animation variables
		let totalDelay = 0.2
		let intervalDelay = (totalDelay / Double(self.colorButtons.count))
		let animationTime = 0.2
		let bounceTime = 0.07
		
		var count = 0
		
		for buttonToAdd in self.colorButtons {
			//get the current angle of the button
			let currentAngle = self.startAngle.degreesToRadians + self.spacingAngle * CGFloat(count)
			
			//create a point slightly outisde of where the colour is currently positioned for bounce effect
			let newX = self.storedCenter!.x + (self.radius + 20) * cos(currentAngle)
			let newY = self.storedCenter!.y + (self.radius + 20) * sin(currentAngle)
			let newPoint = CGPointMake(newX, newY)
			
			//set up times for the buttons to dismiss sequentially
			var delayTime = Double(self.colorButtons.count - count) * intervalDelay
			
			//if the current button was the one tapped, make its delay the longest
			if selectedColorButton == buttonToAdd {
				delayTime = Double(self.colorButtons.count + 2) * intervalDelay
				
				//add the button to the top, to make it "replace" the current button
				self.keyWindow.insertSubview(buttonToAdd, aboveSubview: self.currentColorButton)
			}
			
			//perform animations
			UIView.animateWithDuration(bounceTime, delay: delayTime, options: .CurveLinear, animations: { () -> Void in
				//perform the initial bounce
				buttonToAdd.center = newPoint
				
				}, completion: { (success: Bool) -> Void in
					UIView.animateWithDuration(animationTime, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
						//move to the original centre, behind the original button
						buttonToAdd.center = self.storedCenter!
						
						}, completion: { (success: Bool) -> Void in
							//once hidden, remove the button
							buttonToAdd.removeFromSuperview()
					})
			})
			
			count++
		}
		
		//get the total time of the animation
		var totalTime = totalDelay + animationTime + bounceTime
		
		//adjust the dismiss according to the overall animations
		if selectedColorButton != nil {
			totalTime = Double(self.colorButtons.count + 2) * intervalDelay + animationTime
		} else {
			self.currentColorButton.hideCloseButton((time: totalTime - bounceTime, totalAngle: self.angleOfDisplay, clockwise: self.clockwise))
		}
		
		UIView.animateWithDuration(totalTime + 0.01, animations: { () -> Void in
			//remove the background view
			self.backgroundView.alpha = 0.0
			
			}, completion: { (done: Bool) -> Void in
				//hide the close button
				self.currentColorButton.hideCloseButton(nil)
				
				//get rid of the background
				self.backgroundView.removeFromSuperview()
				self._backgroundView = nil
				
				//put the current colour button back in its original place
				self.currentColorButton.frame = self.bounds
				self.addSubview(self.currentColorButton)
				
				//reset everything
				self.displayed = false
				self.currentColorButton.enabled = true
				
				completion()
		})
	}
}


//MARK: - Color Picker Button
/// A button that is displayed by a ColourPicker.
@IBDesignable class ColorPickerButton: UIButton {
	var color: UIColor = .redColor() {
		didSet {
			self.setNeedsDisplay()
		}
	}
	var borderColor: UIColor = .whiteColor() {
		didSet {
			if self._crossView != nil {
				self.crossView.color = borderColor
			}
		}
	}
	
	var borderWidth: CGFloat = 1.0 {
		didSet {
			if self._crossView != nil {
				self.crossView.width = borderWidth
			}
		}
	}
	
	private var _crossView: ColorPickerCrossView?
	var crossView: ColorPickerCrossView {
		if _crossView == nil {
			_crossView = ColorPickerCrossView(frame: self.bounds)
			_crossView?.width = self.borderWidth + 1
			_crossView?.color = self.borderColor
			_crossView?.backgroundColor = .clearColor()
			_crossView?.alpha = 0.0
		}
		
		return _crossView!
	}
	
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
	
	var isShowing = false
	
	func showCloseButton(animations: (time: Double, totalAngle: Int, clockwise: Bool)?) {
		isShowing = true
		
		self.layer.addSublayer(self.crossView.layer)
		self.crossView.alpha = 1.0
		
		if animations != nil {
			var animationTime = animations!.time/2
			
			var startValue: CGFloat {
				if animations!.clockwise {
					return 2*π - animations!.totalAngle.degreesToRadians
				} else {
					return 2*π + animations!.totalAngle.degreesToRadians
				}
			}
			
			let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
			rotationAnimation.duration = animationTime
			rotationAnimation.values = [startValue, 2*π]
			rotationAnimation.keyTimes = [0.0, 1.0]
			rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			
			let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
			scaleAnimation.duration = animationTime
			scaleAnimation.values = [0.0, 1.0]
			scaleAnimation.keyTimes = [0.0, 1.0]
			scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			
			self.crossView.layer.addAnimation(scaleAnimation, forKey: nil)
			self.crossView.layer.addAnimation(rotationAnimation, forKey: nil)
		}
	}
	
	func hideCloseButton(animations: (time: Double, totalAngle: Int, clockwise: Bool)?) {
		isShowing = false
		
		if animations != nil {
			var animationTime = animations!.time * 2
			
			var endValue: CGFloat {
				if animations!.clockwise {
					return 2*π - animations!.totalAngle.degreesToRadians
				} else {
					return 2*π + animations!.totalAngle.degreesToRadians
				}
			}
			
			let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
			rotationAnimation.duration = animationTime
			rotationAnimation.values = [2*π, endValue]
			rotationAnimation.keyTimes = [0.0, 1.0]
			rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			rotationAnimation.removedOnCompletion = false
			
			let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
			scaleAnimation.duration = animationTime
			scaleAnimation.values = [1.0, 0.0]
			scaleAnimation.keyTimes = [0.0, 1.0]
			scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			scaleAnimation.fillMode = kCAFillModeForwards
			scaleAnimation.removedOnCompletion = false
			
			let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
			alphaAnimation.duration = animationTime
			alphaAnimation.values = [1.0, 0.0]
			alphaAnimation.keyTimes = [0.0, 1.0]
			alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			alphaAnimation.fillMode = kCAFillModeForwards
			alphaAnimation.removedOnCompletion = false
			
			scaleAnimation.delegate = self
			
			self.crossView.layer.addAnimation(scaleAnimation, forKey: nil)
			self.crossView.layer.addAnimation(rotationAnimation, forKey: nil)
			self.crossView.layer.addAnimation(alphaAnimation, forKey: nil)
		} else {
			self.crossView.removeFromSuperview()
			self._crossView = nil
		}
	}
	
	override func drawRect(rect: CGRect) {
		let ctx = UIGraphicsGetCurrentContext()
		let newRect = self.bounds.rectThatFitsInsideSelfWithStrokeWidth(borderWidth)
		
		let path = UIBezierPath(ovalInRect: newRect)
		CGContextBeginPath(ctx)
		CGContextAddPath(ctx, path.CGPath)
		
		CGContextSetFillColorWithColor(ctx, self.color.CGColor)
		
		CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor)
		CGContextSetLineWidth(ctx, self.borderWidth)
		
		CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
			print("About to remove")
			if !isShowing {
				print("Removing")
				self.crossView.removeFromSuperview()
				self._crossView = nil
			}
	}
	
	override func intrinsicContentSize() -> CGSize {
		return CGSizeMake(30.0, 30.0)
	}
}

@IBDesignable class ColorPickerCrossView: UIView {
	@IBInspectable var width: CGFloat = 2.0
	@IBInspectable var color: UIColor = UIColor.whiteColor()
	
	override func drawRect(rect: CGRect) {
		let ctx = UIGraphicsGetCurrentContext()
		
		var path = UIBezierPath()
		
		color.setStroke()
		
		CGContextTranslateCTM(ctx, rect.width/2, rect.height/2)
		CGContextRotateCTM(ctx, π/4)
		
		CGContextTranslateCTM(ctx, -rect.width/2, -rect.height/2)
		
		path = UIBezierPath()
		path.moveToPoint(CGPoint(x: width * 2, y: bounds.height/2))
		path.addLineToPoint(CGPoint(x: bounds.width - width * 2, y: bounds.height/2))
		
		path.moveToPoint(CGPoint(x: bounds.width/2, y: width * 2))
		path.addLineToPoint(CGPoint(x: bounds.width/2, y: bounds.height - width * 2))
		
		path.lineWidth = width/2
		
		path.stroke()
	}
}


//MARK: - Extensions

extension CGFloat {
	var degreesToRadians : CGFloat {
		return self * CGFloat(M_PI) / 180.0
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