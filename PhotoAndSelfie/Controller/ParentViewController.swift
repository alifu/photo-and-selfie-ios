//
//  ParentViewController.swift
//  PhotoAndSelfie
//
//  Created by alifu on 29/03/22.
//

import UIKit

final class ParentViewController: UIViewController {
    
    // MARK: - UI
    
    @IBOutlet private weak var photomImageView: UIImageView!
    @IBOutlet private weak var selfiImageView: UIImageView!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var selfieButton: UIButton!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoButton.addTarget(self, action: #selector(navigateToPhoto), for: .touchUpInside)
        selfieButton.addTarget(self, action: #selector(navigateToSelfie), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc
    private func navigateToPhoto() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let photo = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
            photo.delegate = self
            self.navigationController?.pushViewController(photo, animated: true)
        }
    }
    
    @objc
    private func navigateToSelfie() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let photo = storyboard.instantiateViewController(withIdentifier: "SelfieViewController") as? SelfieViewController {
            self.navigationController?.pushViewController(photo, animated: true)
        }
    }
}

extension ParentViewController: PhotoViewControllerDelegate {
    
    func grabPhoto(image: UIImage?) {
        photomImageView.image = image
    }
}
