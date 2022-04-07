//
//  CornerView.swift
//  PhotoAndSelfie
//
//  Created by alifu on 05/04/22.
//

import UIKit
import CoreGraphics

class CornerView: UIView {

    @IBInspectable
    var sizeMultiplier : CGFloat = 0.2{
        didSet{
            self.draw(self.bounds)
        }
    }

    @IBInspectable
    var lineWidth : CGFloat = 2{
        didSet{
            self.draw(self.bounds)
        }
    }

    @IBInspectable
    var lineColor : UIColor = UIColor.black{
        didSet{
            self.draw(self.bounds)
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }

    func drawCorners()
    {
        let currentContext = UIGraphicsGetCurrentContext()
        
        

        currentContext?.setLineWidth(lineWidth)
        currentContext?.setStrokeColor(lineColor.cgColor)

        //first part of top left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: 0, y: 0))
        currentContext?.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: self.bounds.size.width * sizeMultiplier, y: 0), radius: 20)
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: 10))
        currentContext?.strokePath()

        //top rigth corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height*sizeMultiplier))
        currentContext?.strokePath()

        //bottom rigth corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        currentContext?.strokePath()

        //bottom left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        currentContext?.strokePath()

        //second part of top left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: 0, y: self.bounds.size.height*sizeMultiplier))
        currentContext?.addLine(to: CGPoint(x: 0, y: 0))
        currentContext?.strokePath()
        
        
    }


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
//        self.drawCorners()
        let cgPath = CGMutablePath()
        
        cgPath.move(to: CGPoint(x: 50, y: 4))
        cgPath.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: 4, y: 50), radius: 20)
        cgPath.addLine(to: CGPoint(x: 4, y: 50))
        
        cgPath.move(to: CGPoint(x: self.bounds.size.width - 50, y: 4))
        cgPath.addArc(tangent1End: CGPoint(x: self.bounds.size.width - 4, y: 4), tangent2End: CGPoint(x: self.bounds.size.width - 4, y: self.bounds.size.height - 50), radius: 20)
        cgPath.addLine(to: CGPoint(x: self.bounds.size.width - 4, y: 50))
        
        cgPath.move(to: CGPoint(x: self.bounds.size.width - 4, y: self.bounds.size.height - 50))
        cgPath.addArc(tangent1End: CGPoint(x: self.bounds.size.width - 4, y: self.bounds.size.height - 4), tangent2End: CGPoint(x: self.bounds.size.width - 50, y: self.bounds.size.height - 4), radius: 20)
        cgPath.addLine(to: CGPoint(x: self.bounds.size.width - 50, y: self.bounds.size.height - 4))
          
        cgPath.move(to: CGPoint(x: 50, y: self.bounds.size.height - 4))
        cgPath.addArc(tangent1End: CGPoint(x: 4, y: self.bounds.size.height - 4), tangent2End: CGPoint(x: 4, y: self.bounds.size.height - 50), radius: 20)
        cgPath.addLine(to: CGPoint(x: 4, y: self.bounds.size.height - 50))
        
        
        let bezierPath = UIBezierPath(cgPath: cgPath)
        bezierPath.lineWidth = 5
        UIColor.black.set()
        bezierPath.stroke()
        
        
    }


}
