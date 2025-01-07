//
//  PhotoGalleryCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//
import UIKit

class PhotoGalleryCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with imageURL: String) {
        print("Configuring cell with URL: \(imageURL)") // Add this debug print
        Task {
            do {
                let data = try await SupabaseManager.shared.client.storage
                    .from("report-images")
                    .download(path: imageURL)
                
                DispatchQueue.main.async { [weak self] in
                    if let image = UIImage(data: data) {
                        self?.imageView.image = image
                        print("Image loaded successfully") // Add this debug print
                    } else {
                        print("Failed to create UIImage from data") // Add this debug print
                    }
                }
            } catch {
                print("Error loading image: \(error)") // Add this debug print
            }
        }
    }}
