# Colour-Picker
A colour selection view that allows a user to pick from a selection of different colours.

## Usage
### Initialisation
#### Interface Builder
It’s recommended that you set up an instance of ColorPicker in Interface Builder. It conforms to @IBDesignable so you will be able to see how it will appear with live updates.

The following properties are @IBInspectable:
- Border Colour: the color for the border of each colour (default .whiteColor())
- Border Width: the width of every border (default 2.0)
- Start Colour: the colour of the first colour item that will be presented to the user (default .redColor())

#### Programmatically
If for whatever reason you cannot initialise the ColourPicker in Interface Builder, there is a convenience initialiser that will set up an instance of a ColourPicker with default values, as well as two other intiialisers that allow for more fine-grained customisation:

- `init(colors: Array<UIColor>, frame: CGRect, delegate: ColorPickerDelegate?)`
- `init(colors: Array<UIColor>, startAngle: Int, angleOfDisplay: Int, frame: CGRect)`
- `init(colors: Array<UIColor>, startAngle: Int, endAngle: Int, frame: CGRect)`

An array of `UIColor` instances is always requied to set up the ColourPicker.

### Parameters
There are a number of variables that can be changed in order to cusomise the look and behaviour of the ColourPicker.

- **`colors: Array<UIColor>`** An array of UIColor instances that will be displayed when the ColourPicker is displayed (no default)
- **`startColor: UIColor`** The UIColor that will be first displayed to the user (default .redColor())
- **`startAngle: Int`** The angle that the colour picker will start at. (default 0) 
  - This should be between 0° and 359°, with 0° being at the very top of the circle (the direction of this angle is dependent on the `clockwise` variable). The ColourPicker class will automatically convert degrees into radians so angles can be expressed in a more human-readable format.
- **`angleOfDisplay: Int`** The ColourPicker will lay out the ColourPickerViews from the `startAngle` across an arc that spans the length of the `angleOfDisplay`. (default 180)
  - *Note: you only need to set one of either `endAngle` or `angleOfDisplay`. When one is set it will automatically invalidate/adjust the other.*
- **`endAngle: Int`** The ColourPicker will lay out the ColourPickerViews between the `startAngle` and `endAngle`. (default 180)
  - Useful if you know two points that you want to be able to draw between.
  - *Note: you only need to set one of either `endAngle` or `angleOfDisplay`. When one is set it will automatically invalidate/adjust the other.*
- **`clockwise: Bool`** This serves a dual purpose. It will define which direction the angles will be calculated at, as well as in which direction the ColourPickerViews will animate in from. (default: false)
- **`radius: CGFloat`** Defines how far out from the centre each button should be displayed. (default: 60.0)
- **`borderColor: UIColor`** The colour of the border surrounding each ColourPickerView. (default .whiteColor())
- **`borderWidth: CGFloat`** The width of the border surrounding each ColourPickerView. (default 2.0)
- **`currentColor: UIColor`** The colour of the centre item of the ColourPicker that will be displayed even when the ColourPicker isn't showing. (default .redColor())
- **`delegate: ColorPickerDelegate?`** the ColourPickerDelegate that will be called when a colour is picked.

## Delegate
In order for a class to receive feedback on the state of the ColourPicker, it must conform to the `ColourPickerDelegate` protocol. This contains only two methods to inform the delegate of colour selection and cancellation.
> Note: I plan to add a block-based method instead of a delegate that will allow for animations to happen in time with the dismissal of the ColourPicker. For now, if you wish the animate alongside the ColourPicker dismissing, use an animation time of 0.6 when `colourPickerDidSelectColor:` is called
- **`colourPickerDidSelectColor(picker: ColourPicker, color: UIColor)`** Calls the delegate informing that the colour was picked. Provides the ColourPicker that was used and the `UIColor` that was chosen.
- **`colourPickerDidCancel(picker: ColourPicker)`** Calls the delegate informing that the ColourPicker cancelled. Provides the ColourPicker that cancelled.
