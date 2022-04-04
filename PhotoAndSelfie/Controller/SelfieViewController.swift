//
//  SelfieViewController.swift
//  PhotoAndSelfie
//
//  Created by alifu on 29/03/22.
//

import AVFoundation
import UIKit
import Vision

protocol SelfieViewControllerDelegate {
    func grabSelfie(image: UIImage?)
}

class SelfieViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - UI
    
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet weak var guideView: UIView!
    
    // MARK: - Private
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLayers: [CAShapeLayer] = []
    private let photoOutput = AVCapturePhotoOutput()
    private var holeView: CGRect = .zero
    private var circularProgressBarView: CircularProgressBarView!
    private var circularViewDuration: TimeInterval = 2
    private var circleCGPath: CGPath? = nil
    private var processingImage = false
    
    // MARK: - Accessable
    
    var delegate: SelfieViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCircularProgressBarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCamera()
        captureSession.startRunning()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        configGuideView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Setup Camera
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(previewLayer)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            
            self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
            self.captureSession.addOutput(self.videoDataOutput)
            
            let videoConnection = self.videoDataOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.previewLayer.frame = self.previewView.bounds
            }
        }
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
        let rectOfInterest = holeView
        
        let metadataOutputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let outputRect = previewLayer.layerRectConverted(fromMetadataOutputRect: metadataOutputRect)
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
    
    func configGuideView() {
        let sampleMask = UIView()
        sampleMask.frame = self.view.frame
        sampleMask.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        guideView.addSubview(sampleMask)
        let maskLayer = CALayer()
        maskLayer.frame = sampleMask.bounds
        let circleLayer = CAShapeLayer()
        circleLayer.frame = CGRect(x:0 , y:0,width: sampleMask.frame.size.width,height: sampleMask.frame.size.height)
        let finalPath = UIBezierPath(roundedRect: CGRect(x:0 , y:0,width: sampleMask.frame.size.width,height: sampleMask.frame.size.height), cornerRadius: 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x:sampleMask.center.x - 150, y:sampleMask.center.y - 150, width: 300, height: 300))
        holeView = CGRect(x: sampleMask.center.x - 150, y: sampleMask.center.y - 150, width: 300, height: 300)
        
        finalPath.append(circlePath.reversing())
        circleCGPath = finalPath.cgPath
        circleLayer.path = finalPath.cgPath
        circleLayer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
        circleLayer.borderWidth = 1
        maskLayer.addSublayer(circleLayer)
        
        sampleMask.layer.mask = maskLayer
    }
    
    func setUpCircularProgressBarView() {
        circularProgressBarView = CircularProgressBarView(frame: .zero)
        circularProgressBarView.center = view.center
        circularProgressBarView.progressAnimation(duration: circularViewDuration)
        guideView.addSubview(circularProgressBarView)
    }
}

extension SelfieViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })
                
                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations)
                }
            }
        })
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func handleFaceDetectionObservations(observations: [VNFaceObservation]) {
        if !processingImage {
            for observation in observations {
                let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
                let faceRectanglePath = CGPath(rect: faceRectConverted, transform: nil)
                
                let circleBox = circleCGPath!.boundingBox
                let faceBox = faceRectanglePath.boundingBox
                
                let faceArea = faceBox.size.width * faceBox.size.height
                if(circleBox.contains(faceBox) && faceArea > 50000){
                    print("face is inside the circle")
                    self.processingImage = true
                    if captureSession.isRunning {
                        let settings = AVCapturePhotoSettings()
                        self.photoOutput.capturePhoto(with: settings, delegate: self)
                    }
                    
                }else{
                    print("face is outside the circle")
                }
                
                
                let faceLayer = CAShapeLayer()
                faceLayer.path = faceRectanglePath
                faceLayer.fillColor = UIColor.clear.cgColor
                faceLayer.strokeColor = UIColor.red.cgColor
                
                self.faceLayers.append(faceLayer)
                previewView.layer.addSublayer(faceLayer)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        self.processingImage = true
        
        if let image = UIImage(data: imageData) {
            self.fixOrientation(image: image, completion: { [weak self] fixedImage -> Void in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.delegate?.grabSelfie(image: self.makeImageCroppedToRectOfInterest(from: fixedImage))
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }
    }
}
