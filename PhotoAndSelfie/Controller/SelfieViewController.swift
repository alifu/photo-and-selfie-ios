//
//  SelfieViewController.swift
//  PhotoAndSelfie
//
//  Created by alifu on 29/03/22.
//

import UIKit

class SelfieViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    func configGuideView() {
//        let sampleMask = UIView()
//        sampleMask.frame = self.view.frame
//        sampleMask.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
//        //assume you work in UIViewcontroller
//        guideView.addSubview(sampleMask)
//        let maskLayer = CALayer()
//        maskLayer.frame = sampleMask.bounds
//        let circleLayer = CAShapeLayer()
//        //assume the circle's radius is 150
//        circleLayer.frame = CGRect(x:0 , y:0,width: sampleMask.frame.size.width,height: sampleMask.frame.size.height)
//        let finalPath = UIBezierPath(roundedRect: CGRect(x:0 , y:0,width: sampleMask.frame.size.width,height: sampleMask.frame.size.height), cornerRadius: 0)
//        let circlePath = UIBezierPath(ovalIn: CGRect(x:sampleMask.center.x - 150, y:sampleMask.center.y - 150, width: 300, height: 300))
//        finalPath.append(circlePath.reversing())
//        circleLayer.path = finalPath.cgPath
//        circleLayer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
//        circleLayer.borderWidth = 1
//        maskLayer.addSublayer(circleLayer)
//        
//        sampleMask.layer.mask = maskLayer
//    }
}
