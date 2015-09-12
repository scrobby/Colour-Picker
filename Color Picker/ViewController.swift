//
//  ViewController.swift
//  Color Picker
//
//  Created by Carl Goldsmith on 27/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ColorPickerDelegate {
	@IBOutlet weak var colorPicker: ColorPicker!
	
	@IBOutlet weak var colorsLabel: UILabel!
	@IBOutlet weak var startAngleLabel: UILabel!
	@IBOutlet weak var totalAngleLabel: UILabel!
	
	
	let colors: Array<UIColor> = [.redColor(), .greenColor(), .blueColor(), .purpleColor(), .yellowColor(), .orangeColor(), .cyanColor(), .magentaColor(), .grayColor(), .brownColor(), .blackColor(), .lightGrayColor()]

	override func viewDidLoad() {
		super.viewDidLoad()
		
		var counter = 0
		let countTo = 6
		
		self.colorPicker.delegate = self
		
		while counter < countTo {
			self.colorPicker.colors.append(self.colors[counter])
			counter++
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func noColorsChanged(sender: UISlider) {
		var counter = 0
		let countTo = Int(sender.value)
		self.colorsLabel.text = "\(countTo)"
		
		var newColors = Array<UIColor>()
		
		while counter < countTo {
			newColors.append(self.colors[counter])
			counter++
		}
		
		self.colorPicker.colors = newColors
	}
	
	@IBAction func startAngleChanged(sender: UISlider) {
		let value = Int(sender.value).roundToFive()
		self.colorPicker.startAngle = value
		startAngleLabel.text = "\(value)"
	}
	
	@IBAction func totalAngleChanged(sender: UISlider) {
		let value = Int(sender.value).roundToFive()
		self.colorPicker.angleOfDisplay = value
		totalAngleLabel.text = "\(value)"
	}
	
	@IBAction func clockwiseButtonTapped(sender: UISwitch) {
		self.colorPicker.clockwise = sender.on		
	}
	
	//MARK: - ColorPickerDelegate Methods
	func colorPickerDidSelectColor(picker: ColorPicker, color: UIColor) {
		self.view.backgroundColor = color
	}
	
	func colorPickerDidCancel(picker: ColorPicker) {
		
	}
}

extension Int {
	func roundToFive() -> Int {
		return 5 * Int(round(Double(self) / 5.0))
	}
}

