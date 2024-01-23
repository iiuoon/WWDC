//
//  LiveTextDisableViewController.swift
//  WWDC
//
//  Created by 박지윤 on 1/24/24.
//

import UIKit
import SnapKit
import Then
import Photos

class LiveTextDisableViewController: UIViewController {

    // MARK: UI Component
    private let albumButton = UIButton().then {
        $0.setTitle("go to album", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemYellow
        $0.layer.cornerRadius = 10
    }

    private let albumImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFit
    }

    private let imagePickerController = UIImagePickerController().then {
        $0.sourceType = .photoLibrary
        $0.modalPresentationStyle = .currentContext
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Live Text is disable"
        
        configureSubviews()
        makeConstraints()
    }

    // MARK: Configuration
    private func configureSubviews() {
        view.addSubview(albumButton)
        view.addSubview(albumImageView)

        imagePickerController.delegate = self

        albumButton.addTarget(self, action: #selector(albumButtonTapped), for: .touchUpInside)
    }

    // MARK: Layout
    private func makeConstraints() {
        albumButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
            $0.width.equalTo(300)
            $0.height.equalTo(30)
        }

        albumImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(albumButton.snp.bottom).offset(20)
            $0.width.equalTo(300)
            $0.height.equalTo(500)
        }
    }
}

extension LiveTextDisableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Tap Event
    @objc private func albumButtonTapped() {
        PHPhotoLibrary.requestAuthorization( { [self] status in
            switch status {
            case .authorized:
                presentAlbum()
            case .notDetermined:
                DispatchQueue.main.async {
                    print("notDetermined")
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    print("denied/restricted")
                }
            default:
                break
            }
        })
    }

    private func presentAlbum() {
        DispatchQueue.main.async {
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
    }

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            albumImageView.image = image
        }

        dismiss(animated: true, completion: nil)
    }
}
