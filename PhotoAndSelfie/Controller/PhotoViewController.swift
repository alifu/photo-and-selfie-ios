//
//  PhotoViewController.swift
//  PhotoAndSelfie
//
//  Created by alifu on 29/03/22.
//

import AVFoundation
import UIKit

protocol PhotoViewControllerDelegate {
    func grabPhoto(image: UIImage?)
}

final class PhotoViewController: UIViewController {
    
    // MARK: - UI
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var guideView: UIView!
    
    // MARK: - Accessable
    
    var delegate: PhotoViewControllerDelegate?
    
    // MARK: - Private
    
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var isTorchOff: Bool = true
    private var holeView: CGRect = .zero
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        lightButton.addTarget(self, action: #selector(lightAction), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(takePhotoAction), for: .touchUpInside)
        captureButton.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configGuideView()
//        configLivePreview()
    }
    
    
    
    // MARK: - Setup Camera
    
    private func configLivePreview() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            self.captureSession.startRunning()
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                    isTorchOff = false
                } else {
                    device.torchMode = .off
                    isTorchOff = true
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    private func configGuideView() {
        let sampleMask = UIView()
        sampleMask.frame = guideView.bounds
        sampleMask.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        guideView.addSubview(sampleMask)
        let maskLayer = CALayer()
        maskLayer.frame = sampleMask.bounds
        let circleLayer = CAShapeLayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: sampleMask.frame.size.width,height: sampleMask.frame.size.height)
        let finalPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: sampleMask.frame.size.width, height: sampleMask.frame.size.height), cornerRadius: 0)
        holeView = CGRect(x: sampleMask.center.x - 150, y: sampleMask.center.y - 300, width: 300, height: 200)
        let cornerViewCode = CornerView(frame: holeView)
        guideView.addSubview(cornerViewCode)
        cornerViewCode.lineWidth = 5
        let circlePath = UIBezierPath(roundedRect: holeView, cornerRadius: 20)
        finalPath.append(circlePath.reversing())
        circleLayer.path = finalPath.cgPath
        circleLayer.borderColor = UIColor.red.cgColor
        circleLayer.borderWidth = 2
        maskLayer.addSublayer(circleLayer)
        sampleMask.layer.mask = maskLayer
    }
    
    func fixOrientation(image: UIImage, completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .background).async {
            if (image.imageOrientation == .up) {
                completion(image)
            }
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: rect)
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            completion(normalizedImage)
        }
    }
    
    private func makeImageCroppedToRectOfInterest(from image: UIImage) -> UIImage? {
        let previewLayer = videoPreviewLayer
        let rectOfInterest = holeView
        
        let metadataOutputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        if let outputRect = previewLayer?.layerRectConverted(fromMetadataOutputRect: metadataOutputRect) {
            guard let cgImage = image.cgImage else {
                return image
            }
            
            let width = image.size.width
            let height = image.size.height
            
            let factorX = width / outputRect.width
            let factorY = height / outputRect.height
            let factor = max(factorX, factorY)
            
            let cropRect = CGRect(x: (rectOfInterest.origin.x - outputRect.origin.x) * factor,
                                  y: (rectOfInterest.origin.y - outputRect.origin.y) * factor,
                                  width: rectOfInterest.size.width * factor,
                                  height: rectOfInterest.size.height * factor)
            
            guard let cropped = cgImage.cropping(to: cropRect) else {
                return image
            }
            
            return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        }
        return nil
    }
}

extension PhotoViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        if let image = UIImage(data: imageData) {
            self.fixOrientation(image: image, completion: { [weak self] fixedImage -> Void in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.delegate?.grabPhoto(image: self.makeImageCroppedToRectOfInterest(from: fixedImage))
                    self.backAction()
                }
            })
        }
        
    }
    
    // MARK: - Actions
    
    @objc
    private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func lightAction() {
        toggleTorch(on: isTorchOff)
    }
    
    @objc
    private func takePhotoAction() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}
