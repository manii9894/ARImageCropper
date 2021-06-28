//
//  CornerPointView.swift
//  ImageCropper
//
//  Created by Abdul Rehman on 1/19/21.
//

import UIKit

class CornerpointView: UIView {
    
    // MARK: - PROPERTIES
    var delegate: CornerpointProtocol?
    private var dragger: UIPanGestureRecognizer!
    private var dragStart: CGPoint!
    var centerPoint: CGPoint? {
        didSet(oldPoint) {
            if let newCenter = centerPoint {
                isHidden = false
                center = newCenter
            } else {
                isHidden = true
            }
        }
    }
    
    // MARK: - METHODS
    
    init(color: CGColor, cornersSize: CGSize) {
        super.init(frame:CGRect.zero)
        setupViews(color: color, cornersSize: cornersSize)
    }
    
    init(color: CGColor, cornersSize: CGSize, cornersLineWidth: CGFloat, cornerPosition: CornerPosition) {
        super.init(frame:CGRect.zero)
        setupViews(color: color, cornersSize: cornersSize, cornersLineWidth: cornersLineWidth, cornerPosition: cornerPosition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    private func setupViews(color: CGColor, cornersSize: CGSize) {
        
        dragger = UIPanGestureRecognizer(target: self as AnyObject,
                                         action: #selector(handleCornerDrag(_:)))
        addGestureRecognizer(dragger)
        //Make the corner point view big enough to drag with a finger.
        bounds.size = CGSize(width: 30, height: 30)
        
        //Add a layer to the view to draw an outline for this corner point.
        
        let newLayer = CALayer()
        newLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        newLayer.bounds.size = cornersSize
        newLayer.borderWidth = 1.0
        newLayer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        newLayer.backgroundColor = color
        
        layer.addSublayer(newLayer)
    }
    
    private func setupViews(color: CGColor, cornersSize: CGSize, cornersLineWidth: CGFloat, cornerPosition: CornerPosition) {
        
        dragger = UIPanGestureRecognizer(target: self as AnyObject,
                                         action: #selector(handleCornerDrag(_:)))
        addGestureRecognizer(dragger)
        //Make the corner point view big enough to drag with a finger.
        bounds.size = CGSize(width: 30, height: 30)
        
        //Add a layer to the view to draw an outline for this corner point.
        
        let newLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        switch cornerPosition {
        case .topLeft:
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX + cornersSize.width, y: layer.bounds.midY))
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY + cornersSize.height))
        case .topRight:
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX - cornersSize.width, y: layer.bounds.midY))
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY + cornersSize.height))
        case .bottomLeft:
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX + cornersSize.width, y: layer.bounds.midY))
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY - cornersSize.height))
        case .bottomRight:
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX - cornersSize.width, y: layer.bounds.midY))
            linePath.move(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
            linePath.addLine(to: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY - cornersSize.height))
        }
        newLayer.lineWidth = cornersLineWidth
        newLayer.strokeColor = color
        newLayer.path = linePath.cgPath
        
        layer.addSublayer(newLayer)
    }
    
    //-------------------------------------------------------------------------------------------------------
    
    @objc func handleCornerDrag(_ thePanner: UIPanGestureRecognizer) {
        switch thePanner.state {
        case .began:
            dragStart = centerPoint
            thePanner.setTranslation(CGPoint.zero,
                                     in: self)
        
        case .changed:
            //println("In view dragger changed at \(newPoint)")
            centerPoint = CGPoint(x: dragStart.x + thePanner.translation(in: self).x,
                                  y: dragStart.y + thePanner.translation(in: self).y)
            
            //If we have a delegate, notify it that this corner has moved.
            //This code uses "optional binding" to convert the optional "cornerpointDelegate" to a required
            //variable "theDelegate". If cornerpointDelegate == nil, the code that follows is skipped.
            if let theDelegate = delegate {
                theDelegate.cornerHasChanged(self)
            }
        default:
            break;
        }
    }
}

protocol CornerpointProtocol {
  func cornerHasChanged(_: CornerpointView)
}

enum CornerPosition: Int {
    case topLeft = 0, topRight, bottomRight, bottomLeft
}

public enum CornerShape {
    case square, line
}
