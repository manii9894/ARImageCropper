# ARImageCropper

ARImageCropper is a Swift library for cropping images. User can crop images according to the aspect ratio. User can also customize the color of cropper.

#### Key Features

1) `Cropping according to the aspect ratio`

2) `Color customization`

## Screenshot
![ARImagePicker](https://github.com/manii9894/ARImageCropper/blob/master/Screenshot/demo.gif)

Installation
==========================

#### Installation with CocoaPods

ARImageCropper is available through [CocoaPods](https://cocoapods.org/pods/ARImageCropper). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ARImageCropper'
```

Just drag a view in your view controller and assign it 'ARImageCropper' class. Just make an outlet of in it in your view controller class.
In your view controller just import ARImageCropper framework.

```swift
import ARImageCropper

class ImageCropViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var cropView: ARImageCropper!
    
}
```

Just set the image property of your 'ARImageCropper' view
```swift
cropView.image = yourImage
```

You can easily get the cropped image using this method
```swift
cropView.croppedImage()
```

You can also reset the crop area to default
```swift
cropView.resetCropperArea()
```

You can update the crop area on runtime
```swift
cropView.updateCropperArea(size: CGSize(width: 150, height: 100))
```

You can set the aspect ratio you want for the cropped image by setting this property
```swift
cropView.croppedImageSize = CGSize(width: 100, height: 150)
```

You can set the corner shape
```swift
cropView.cornerShape = .line
```

You can set the border color and corners color of the cropper
```swift
cropView.cornersColor = .green
cropView.borderColor = .blue
```

You can set the border width
```swift
cropView.borderWidth = 2.0
```

You can set the corners size
```swift
cropView.cornersSize = CGSize(width: 12, height: 12)
```

You can set the corners line width
```swift
cropView.cornersLineWidth = 2
```

LICENSE
---
Distributed under the MIT License.

Contributions
---
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

Author
---
If you wish to contact me, email at: a.rehman9894@gmail.com
