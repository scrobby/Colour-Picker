//
//  ViewController.swift
//  Colour Picker
//
//  Created by Carl Goldsmith on 27/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var colourPicker: ColourPicker!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.colourPicker.setCurrentColour(.redColor(), animated: false)
		self.colourPicker.colours = [.redColor(), .greenColor(), .blueColor(), .purpleColor(), .yellowColor(), .orangeColor(), .cyanColor(), .magentaColor(), .grayColor(), .blackColor()]
		self.colourPicker.startAngle = 0
		self.colourPicker.angleOfDisplay = 360

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func buttonPressed(sender: AnyObject) {
		
	}
	
}

