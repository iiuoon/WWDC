//
//  LiveTextEnableViewController.swift
//  WWDC
//
//  Created by 박지윤 on 1/24/24.
//

import UIKit
import SnapKit
import Then
import Photos
import VisionKit

class LiveTextEnableViewController: UIViewController {
    
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

    private let textSelectionButton = UIButton().then {
        $0.setTitle("textSelection", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 10
    }

    private let dataDetectorsButton = UIButton().then {
        $0.setTitle("dataDetectors", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 10
    }

    private let defaultButton = UIButton().then {
        $0.setTitle("default", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 10
    }

    private let imagePickerController = UIImagePickerController().then {
        $0.sourceType = .photoLibrary
        $0.modalPresentationStyle = .currentContext
    }

    // MARK: Live Text Properties
    // MARK: - Live Text 기능을 사용하기 위해 필요한 두 가지
    private let imageAnalyzer = ImageAnalyzer()
    private lazy var interaction = ImageAnalysisInteraction()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Live Text is enable"
        // MARK: - UIImageView에 상호 작용 추가
        albumImageView.addInteraction(interaction)
 
        configureSubviews()
        makeConstraints()
    }

    // MARK: Configuration
    private func configureSubviews() {
        view.addSubview(albumButton)
        view.addSubview(albumImageView)
        view.addSubview(textSelectionButton)
        view.addSubview(dataDetectorsButton)
        view.addSubview(defaultButton)

        imagePickerController.delegate = self

        albumButton.addTarget(self, action: #selector(albumButtonTapped), for: .touchUpInside)
        textSelectionButton.addTarget(self, action: #selector(textSelectionButtonTapped), for: .touchUpInside)
        dataDetectorsButton.addTarget(self, action: #selector(dataDetectorsButtonTapped), for: .touchUpInside)
        defaultButton.addTarget(self, action: #selector(defaultButtonTapped), for: .touchUpInside)
    }

    // MARK: Tap Event
    @objc private func textSelectionButtonTapped() {
        interaction.preferredInteractionTypes = .textSelection
    }

    @objc private func dataDetectorsButtonTapped() {
        interaction.preferredInteractionTypes = .dataDetectors
    }

    @objc private func defaultButtonTapped() {
        interaction.preferredInteractionTypes = .automatic
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

        textSelectionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(47)
            $0.top.equalTo(albumImageView.snp.bottom).offset(20)
            $0.width.equalTo(142)
            $0.height.equalTo(30)
        }

        dataDetectorsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(47)
            $0.top.equalTo(albumImageView.snp.bottom).offset(20)
            $0.width.equalTo(142)
            $0.height.equalTo(30)
        }

        defaultButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dataDetectorsButton.snp.bottom).offset(20)
            $0.width.equalTo(300)
            $0.height.equalTo(30)
        }
    }
}

extension LiveTextEnableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

        showLiveText()
    }
}

extension LiveTextEnableViewController: ImageAnalysisInteractionDelegate, UIGestureRecognizerDelegate {
    private func showLiveText() {
        // MARK: - 1. 분석할 이미지가 있는지 확인
        guard let image = albumImageView.image else {
            return
        }

        Task {
            // MARK: - 2. 분석할 종류 선택하기
            let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
            do {
                // MARK: - 3. 이미지 분석
                let analysis = try await imageAnalyzer.analyze(image, configuration: configuration)

                DispatchQueue.main.async {
                    // MARK: - 4. 예전 이미지에 대한 분석 초기화
                    self.interaction.analysis = nil
                    self.interaction.preferredInteractionTypes = []

                    // MARK: - 5. 새로운 이미지를 위한 분석 설정
                    self.interaction.analysis = analysis
                    self.interaction.preferredInteractionTypes = .automatic
                }
            } catch {
                // MARK: - 6. 에러 처리
                print(error.localizedDescription)
            }
        }
    }
}
