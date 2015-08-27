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
				let button = ColourPickerButton()
				button.colour = colour
				_colourButtons! += [button]
			}
		}
		return _colourButtons!
	}
	
	private var _currentColourButton: ColourPickerButton?
	var currentColourButton: ColourPickerButton {
		if _currentColourButton == nil {
			_currentColourButton = ColourPickerButton()
			
			if currentColour != nil {
				_currentColourButton!.colour = currentColour!
			} else {
				_currentColourButton!.colour = colours[0]
			}
		}
		return _currentColourButton!
	}
	
	//MARK: Other Variables
	var directionOfDisplay: ColourPickerDirection = .CounterClockwise
	var radius: CGFloat = 20.0
	var currentColour: UIColor?
	
	
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
	
	override func drawRect(rect: CGRect) {
		self.currentColourButton.frame = self.bounds
		self.addSubview(self.currentColourButton)
	}
}


enum ColourPickerButtonShape {
	case Circle
}

@IBDesignable class ColourPickerButton: UIButton {
	@IBInspectable var colour: UIColor = .redColor()
	
	//	init(colour: UIColor, frame: CGRect) {
	//		self.colour = colour
	//		super.init(frame: frame)
	//	}
	//
	//	override init(frame: CGRect) {
	//		self.colour = .redColor()
	//		super.init(frame: frame)
	//	}
	//
	//	required init(coder aDecoder: NSCoder) {
	//		self.colour = .redColor()
	//		super.init(coder: aDecoder)
	//	}
	
	override func drawRect(rect: CGRect) {
		var path = UIBezierPath(ovalInRect: rect)
		self.colour.setFill()
		path.fill()
	}
}

extension Int {
	var degreesToRadians : CGFloat {
		return CGFloat(self) * CGFloat(M_PI) / 180.0
	}
}