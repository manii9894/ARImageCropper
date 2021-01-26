//
//  CropableImageView.swift
//  ImageCropper
//
//  Created by Abdul Rehman on 1/19/21.
//

import UIKit

public class ARImageCropper: UIView {
    
    // MARK: - PROPERTIES
    private let viewForImage: UIView
    private let overlayView: UIView
    private var imageSize: CGSize?
    private var imageRect: CGRect?
    private var aspect: CGFloat
    private var draggingRect: Bool = false
    private let dragger: UIPanGestureRecognizer
    private var cornerpoints =  [CornerpointView]()
    private var startPoint: CGPoint?
    private var xPosition: CGFloat = 0
    private var yPosition: CGFloat = 0
    private var maximumPossibleHeight: CGFloat = 0
    private var maximumPossibleWidth: CGFloat = 0
    public var croppedImageSize: CGSize = CGSize()
    public var borderColor: UIColor = UIColor.red
    public var borderWidth: CGFloat = 1.0
    public var cornersColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    private var isFirstTime = true
    fileprivate var internalCropRect: CGRect?
    private var cropRect: CGRect? {
        set {
            if let realCropRect = newValue {
                var newRect: CGRect!
                if imageRect == nil {
                    newRect =  realCropRect
                } else {
                    newRect =  realCropRect.intersection(imageRect!)
                }
                internalCropRect = newRect
                cornerpoints[0].centerPoint = newRect.origin
                cornerpoints[1].centerPoint = CGPoint(x: newRect.maxX, y: newRect.origin.y)
                cornerpoints[3].centerPoint = CGPoint(x: newRect.origin.x, y: newRect.maxY)
                cornerpoints[2].centerPoint = CGPoint(x: newRect.maxX,y: newRect.maxY)
            } else {
                internalCropRect = nil
                for aCornerpoint in cornerpoints {
                    aCornerpoint.centerPoint = nil
                }
            }
            setNeedsDisplay()
        }
        get {
            return internalCropRect
        }
    }
    public var image: UIImage? {
        didSet {
            removePreviousCornerPoints()
            imageSize = image?.size
            if (croppedImageSize.height < 10 && croppedImageSize.width < 10) || (croppedImageSize.height > frame.height || croppedImageSize.width > frame.width) {
                croppedImageSize.height = 50
                croppedImageSize.width = 50
            }
            for _ in 1...4 {
                let cornerPoint = CornerpointView(color: cornersColor.cgColor)
                cornerPoint.delegate = self
                cornerpoints.append(cornerPoint)
                addSubview(cornerPoint)
            }
            overlayView.isHidden = false
            setNeedsLayout()
        }
    }
    
    
    // MARK: - METHODS
    public required init?(coder aDecoder: NSCoder) {
        
        
        viewForImage = UIView(frame: .zero)
        viewForImage.translatesAutoresizingMaskIntoConstraints = false
        overlayView = UIView(frame: .zero)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        overlayView.isUserInteractionEnabled = false
        aspect = 1
        dragger = UIPanGestureRecognizer()
        super.init(coder: aDecoder)
        dragger.addTarget(self as AnyObject, action: #selector(handleDragInView(_:)))
        addGestureRecognizer(dragger)
        
    }
    
    private func removePreviousCornerPoints() {
        
        if cornerpoints.count != 0 {
            for i in 0..<cornerpoints.count {
                let obj = cornerpoints[i]
                obj.removeFromSuperview()
            }
            cornerpoints.removeAll()
        }
        
    }
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        superview?.insertSubview(viewForImage, belowSubview: self)
        superview?.insertSubview(overlayView, aboveSubview: self)
        overlayView.isHidden = true
        self.backgroundColor = .clear
//        Set up constraints to pin the image-containing view to the edges of this view.
        var aConstraint = NSLayoutConstraint(item: self,
                                             attribute: .top,
                                             relatedBy: .equal,
                                             toItem: viewForImage,
                                             attribute: .top,
                                             multiplier: 1.0,
                                             constant: 0)
        superview!.addConstraint(aConstraint)

        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: viewForImage,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)

        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: viewForImage,
                                         attribute: .left,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)

        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: .right,
                                         relatedBy: .equal,
                                         toItem: viewForImage,
                                         attribute: .right,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)
        
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        viewForImage.frame = frame
        overlayView.frame = frame
        //If we have an image...
        if let requiredImageSize = imageSize {
            var displaySize: CGSize = CGSize.zero
            displaySize.width = min(requiredImageSize.width, bounds.size.width)
            displaySize.height = min(requiredImageSize.height, bounds.size.height)
            let heightAsepct: CGFloat = displaySize.height/requiredImageSize.height
            let widthAsepct: CGFloat = displaySize.width/requiredImageSize.width
            aspect = min(heightAsepct, widthAsepct)
            displaySize.height = round(requiredImageSize.height * aspect)
            displaySize.width = round(requiredImageSize.width * aspect)
            
            xPosition = (frame.width - displaySize.width) / 2
            yPosition = (frame.height - displaySize.height) / 2
            
            imageRect = CGRect(x: xPosition, y: yPosition, width: displaySize.width, height: displaySize.height)
        }
        
        if image != nil {
            UIGraphicsBeginImageContextWithOptions(viewForImage.layer.bounds.size, true, 0)
            
            let path = UIBezierPath.init(rect: viewForImage.bounds)
            UIColor.white.setFill()
            path.fill()
            
            image?.draw(in: imageRect!)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext();
            
            let theImageRef = result!.cgImage
            viewForImage.layer.contents = theImageRef as AnyObject
            guard let rect = imageRect else { return }
            if rect.height > rect.width {
                maximumPossibleWidth = rect.width
                maximumPossibleHeight = rect.width * (croppedImageSize.height / croppedImageSize.width)
            } else {
                maximumPossibleWidth = rect.height * (croppedImageSize.width / croppedImageSize.height)
                maximumPossibleHeight = rect.height
            }
            cropRect = rectFromStartAndEnd(CGPoint(x: 0, y: 0), endPoint: CGPoint(x: maximumPossibleWidth, y: maximumPossibleHeight))
        }
        
    }
    
    public override func draw(_ rect: CGRect) {
        //Drawing the image in drawRect is too slow.
        //Switched to installing the image bitmap into a view layer's content
        
        if let realCropRect = internalCropRect {
            let path = UIBezierPath(rect: realCropRect)
            path.lineWidth = 3.0
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
            path.stroke()
            path.lineWidth = borderWidth
            borderColor.set()
            path.stroke()
            
            let blurPath = UIBezierPath(roundedRect: realCropRect, cornerRadius: 0)
            blurPath.append(UIBezierPath(rect: imageRect!))
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.path = blurPath.cgPath
            self.overlayView.layer.mask = maskLayer
            self.layoutIfNeeded()
            
        }
        
    }
    
    public func croppedImage() -> UIImage? {
        
        if var cropRect = internalCropRect {
            var drawRect: CGRect = CGRect.zero
            drawRect.size = imageSize!
            drawRect.origin.x = round(-(cropRect.origin.x - xPosition) / aspect)
            drawRect.origin.y = round(-(cropRect.origin.y - yPosition) / aspect)
            cropRect.size.width = round(cropRect.size.width/aspect)
            cropRect.size.height = round(cropRect.size.height/aspect)
            cropRect.origin.x = round(cropRect.origin.x) - xPosition
            cropRect.origin.y = round(cropRect.origin.y) - yPosition
            
            UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 0)
            image?.draw(in: drawRect)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            return result
        } else {
            return nil
        }
        
    }
    
    public func updateCropperArea(size: CGSize) {
        
        internalCropRect = nil
        draggingRect = false
        croppedImageSize = size
        guard let rect = imageRect else { return }
        if rect.height > rect.width {
            maximumPossibleWidth = rect.width
            maximumPossibleHeight = rect.width * (croppedImageSize.height / croppedImageSize.width)
        } else {
            maximumPossibleWidth = rect.height * (croppedImageSize.width / croppedImageSize.height)
            maximumPossibleHeight = rect.height
        }
        cropRect = rectFromStartAndEnd(CGPoint(x: 0, y: 0), endPoint: CGPoint(x: maximumPossibleWidth, y: maximumPossibleHeight))
        
    }
    
    public func resetCropperArea() {
        
        updateCropperArea(size: croppedImageSize)
        
    }
    
    private func rectFromStartAndEnd(_ startPoint:CGPoint, endPoint: CGPoint) -> CGRect {
        
        var  top, left, bottom, right: CGFloat
        top = min(startPoint.y, endPoint.y)
        bottom = max(startPoint.y, endPoint.y)
        
        left = min(startPoint.x, endPoint.x)
        right = max(startPoint.x, endPoint.x)
        
        let theHeightScaleFactor = croppedImageSize.height / croppedImageSize.width
        let theWidthScaleFactor = croppedImageSize.width / croppedImageSize.height
        let width = right - left
        let height = bottom - top
        
        if height > maximumPossibleHeight || width > maximumPossibleWidth {
            if internalCropRect != nil {
                return internalCropRect!
            }
        }
        
        if isFirstTime {
            isFirstTime = false
            return CGRect(x: xPosition, y: yPosition, width: width, height: height)
        } else {
            if left < imageRect!.minX {
                left = imageRect!.minX
            }
            if top < imageRect!.minY {
                top = imageRect!.minY
            }
            if croppedImageSize.width > croppedImageSize.height {
                return CGRect(x: left, y: top, width: width, height: width * theHeightScaleFactor)
            } else {
                if left > (imageRect!.maxX - (height * theWidthScaleFactor)) && right >= imageRect!.maxX {
                    left = imageRect!.maxX - (height * theWidthScaleFactor)
                }
                return CGRect(x: left, y: top, width: height * theWidthScaleFactor, height: height)
            }
        }
        
    }
    
    @objc private func handleDragInView(_ panGesture: UIPanGestureRecognizer) {
        
        guard imageSize != nil else { return }
        let newPoint = panGesture.location(in: self)
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            
            //if we have a crop rect and the touch is inside it, drag the entire rect.
            if let requiredCropRect = internalCropRect {
                if requiredCropRect.contains(newPoint)
                {
                    startPoint = requiredCropRect.origin
                    draggingRect = true
                    panGesture.setTranslation(CGPoint.zero, in: self)
                }
            }
            
            
        case UIGestureRecognizerState.changed:
            
            //If the user is dragging the entire rect, don't let it be draggged out-of-bounds
            if draggingRect {
                var newX = max(startPoint!.x + panGesture.translation(in: self).x,xPosition)
                if newX + internalCropRect!.size.width > (imageRect!.size.width + xPosition)
                {
                    newX = imageRect!.size.width - internalCropRect!.size.width + xPosition
                }
                var newY = max(startPoint!.y + panGesture.translation(in: self).y,yPosition)
                if newY + internalCropRect!.size.height > (imageRect!.size.height + yPosition)
                {
                    newY = imageRect!.size.height - internalCropRect!.size.height + yPosition
                }
                cropRect!.origin = CGPoint(x: newX, y: newY)
                
            }
        default:
            draggingRect = false
            break
        }
    }
    
}

// MARK: - CORNER POINT DELEGATE -
extension ARImageCropper: CornerpointProtocol {
    
    func cornerHasChanged(_ newCornerPoint: CornerpointView) {
        
        var pointIndex: Int?
        
        //Find the cornerpoint the user dragged in the array.
        for (index, aCornerpoint) in cornerpoints.enumerated() {
            if newCornerPoint == aCornerpoint {
                pointIndex = index
                break
            }
        }
        if (pointIndex == nil) {
            return
        }
        
        //Find the index of the opposite corner.
        let otherIndex:Int = (pointIndex! + 2) % 4
        
        //Calculate a new cropRect using those 2 corners
        cropRect = rectFromStartAndEnd(newCornerPoint.centerPoint!, endPoint: cornerpoints[otherIndex].centerPoint!)
        
    }
    
}
