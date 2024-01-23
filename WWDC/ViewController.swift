//
//  ViewController.swift
//  WWDC
//
//  Created by 박지윤 on 1/24/24.
//

import UIKit
import SnapKit
import Then

class ViewController: UIViewController {

    // MARK: UI Component
    private let liveTextDisableButton = UIButton().then {
        $0.setTitle("Live Text is disable", for: .normal)
        $0.backgroundColor = .systemTeal
        $0.layer.cornerRadius = 10

    }

    private let liveTextEnableButton = UIButton().then {
        $0.setTitle("Live Text is enable", for: .normal)
        $0.backgroundColor = .systemTeal
        $0.layer.cornerRadius = 10
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "main"

        configureSubviews()
        makeConstraints()
    }

    // MARK: Configuration
    private func configureSubviews() {
        view.addSubview(liveTextDisableButton)
        view.addSubview(liveTextEnableButton)

        liveTextDisableButton.addTarget(self, action: #selector(liveTextDisableButtonTapped), for: .touchUpInside)
        liveTextEnableButton.addTarget(self, action: #selector(liveTextEnableButtonTapped), for: .touchUpInside)
    }

    // MARK: Tap Event
    @objc private func liveTextDisableButtonTapped() {
        let liveTextDisableViewController = LiveTextDisableViewController()
        self.navigationController?.pushViewController(liveTextDisableViewController, animated: true)
    }

    @objc private func liveTextEnableButtonTapped() {
        let liveTextEnableViewController = LiveTextEnableViewController()
        self.navigationController?.pushViewController(liveTextEnableViewController, animated: true)
    }

    // MARK: Layout
    private func makeConstraints() {
        liveTextDisableButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
            $0.width.equalTo(300)
            $0.height.equalTo(30)
        }

        liveTextEnableButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(190)
            $0.width.equalTo(300)
            $0.height.equalTo(30)
        }
    }
}
