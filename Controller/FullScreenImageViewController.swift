//
//  FullScreenImageViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//
import UIKit

class FullScreenImageViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageURL: String
    
    init(imageURL: String) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func loadImage() {
        Task {
            do {
                let data = try await SupabaseManager.shared.client.storage
                    .from("report-images")
                    .download(path: imageURL)
                
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = UIImage(data: data)
                }
            } catch {
                print("Error loading full-screen image: \(error)")
                dismiss(animated: true)
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
