//
//  ParkingDetailViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 07/01/2025.
//


import UIKit
import CoreImage
import MapKit
import Photos

class ParkingDetailViewController: UIViewController {
    // MARK: - Properties
    private let parkingSpot: ParkingSpotModel
    private var qrCodeImage: UIImage?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let parkingInfoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spotIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrCodeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let qrCodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Parking QR Code"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let saveQRButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save QR Code", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(parkingSpot: ParkingSpotModel) {
        self.parkingSpot = parkingSpot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithParkingSpot()
        generateQRCode()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Parking Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(parkingInfoCard)
        parkingInfoCard.addSubview(spotIdLabel)
        parkingInfoCard.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)
        parkingInfoCard.addSubview(typeLabel)
        
        contentView.addSubview(locationContainer)
        locationContainer.addSubview(locationTitleLabel)
        locationContainer.addSubview(streetLabel)
        locationContainer.addSubview(areaLabel)
        
        contentView.addSubview(qrCodeContainer)
        qrCodeContainer.addSubview(qrCodeTitleLabel)
        qrCodeContainer.addSubview(qrCodeImageView)
        qrCodeContainer.addSubview(saveQRButton)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Parking Info Card
            parkingInfoCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            parkingInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            parkingInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            spotIdLabel.topAnchor.constraint(equalTo: parkingInfoCard.topAnchor, constant: 16),
            spotIdLabel.leadingAnchor.constraint(equalTo: parkingInfoCard.leadingAnchor, constant: 16),
            
            statusContainer.centerYAnchor.constraint(equalTo: spotIdLabel.centerYAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: parkingInfoCard.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 28),
            
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 6),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -6),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            
            typeLabel.topAnchor.constraint(equalTo: spotIdLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: parkingInfoCard.leadingAnchor, constant: 16),
            typeLabel.bottomAnchor.constraint(equalTo: parkingInfoCard.bottomAnchor, constant: -16),
            
            // Location Container
            locationContainer.topAnchor.constraint(equalTo: parkingInfoCard.bottomAnchor, constant: 16),
            locationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationTitleLabel.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 16),
            locationTitleLabel.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 16),
            
            streetLabel.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 8),
            streetLabel.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 16),
            
            areaLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 8),
            areaLabel.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 16),
            
            // QR Code Container
            qrCodeContainer.topAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 16),
            qrCodeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            qrCodeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            qrCodeContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            qrCodeTitleLabel.topAnchor.constraint(equalTo: qrCodeContainer.topAnchor, constant: 16),
            qrCodeTitleLabel.leadingAnchor.constraint(equalTo: qrCodeContainer.leadingAnchor, constant: 16),
            
            qrCodeImageView.topAnchor.constraint(equalTo: qrCodeTitleLabel.bottomAnchor, constant: 16),
            qrCodeImageView.centerXAnchor.constraint(equalTo: qrCodeContainer.centerXAnchor),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 200),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 200),
            
            saveQRButton.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 16),
            saveQRButton.leadingAnchor.constraint(equalTo: qrCodeContainer.leadingAnchor, constant: 16),
            saveQRButton.trailingAnchor.constraint(equalTo: qrCodeContainer.trailingAnchor, constant: -16),
            saveQRButton.heightAnchor.constraint(equalToConstant: 50),
            saveQRButton.bottomAnchor.constraint(equalTo: qrCodeContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        saveQRButton.addTarget(self, action: #selector(saveQRCodeTapped), for: .touchUpInside)
    }
    
    private func configureWithParkingSpot() {
        spotIdLabel.text = "Spot #\(parkingSpot.parkingSpotID)"
        typeLabel.text = "Type: \(parkingSpot.type.capitalized)"
        streetLabel.text = "Street: \(parkingSpot.streetName)"
        areaLabel.text = "Area: \(parkingSpot.areaName)"
        
        statusLabel.text = parkingSpot.isAvailable ? "AVAILABLE" : "OCCUPIED"
        if parkingSpot.isAvailable {
            statusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        } else {
            statusContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            statusLabel.textColor = .systemRed
        }
        
        // Configure colors based on type
        switch parkingSpot.type.lowercased() {
        case "green":
            typeLabel.textColor = .systemGreen
        case "yellow":
            typeLabel.textColor = .systemYellow
        case "red":
            typeLabel.textColor = .systemRed
        case "disable":
            typeLabel.textColor = .systemBlue
        default:
            typeLabel.textColor = .label
        }
    }
    
    private var photoLibraryAuthStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }

    private func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }


    private func generateQRCode() {
        // Generate QR code with prefix
        let qrString = "PARKING_SPOT:\(parkingSpot.parkingSpotID)"
        
        if let qrFilter = CIFilter(name: "CIQRCodeGenerator") {
            let data = qrString.data(using: .utf8)
            qrFilter.setValue(data, forKey: "inputMessage")
            
            if let qrImage = qrFilter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledQrImage = qrImage.transformed(by: transform)
                
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) {
                    let processedImage = UIImage(cgImage: cgImage)
                    qrCodeImage = processedImage // Store for saving later
                    qrCodeImageView.image = processedImage
                }
            }
        }
    }
    
    @objc private func saveQRCodeTapped() {
        guard let qrImage = qrCodeImage else {
            showAlert(title: "Error", message: "Unable to generate QR code")
            return
        }
        
        switch photoLibraryAuthStatus {
        case .notDetermined:
            requestPhotoLibraryAccess { [weak self] granted in
                if granted {
                    self?.saveImage(qrImage)
                } else {
                    self?.showPhotoLibraryAccessDeniedAlert()
                }
            }
        case .restricted, .denied:
            showPhotoLibraryAccessDeniedAlert()
        case .authorized, .limited:
            saveImage(qrImage)
        @unknown default:
            showAlert(title: "Error", message: "Unknown photo library access status")
        }
    }

    private func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    private func showPhotoLibraryAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Photo Library Access Required",
            message: "Please enable photo library access in Settings to save the QR code.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(
                title: "Save Failed",
                message: "Failed to save QR code: \(error.localizedDescription)"
            )
        } else {
            // Add haptic feedback for success
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            showAlert(
                title: "Success",
                message: "QR code has been saved to your photos"
            )
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
