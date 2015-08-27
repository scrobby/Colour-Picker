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
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func buttonPressed(sender: AnyObject) {
		self.colourPicker.setCurrentColour(.greenColor(), animated: false)
		self.colourPicker.colours = [.redColor(), .greenColor(), .blueColor(), .yellowColor(), .purpleColor()]
	}
	
}

