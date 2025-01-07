//
//  ReportDetailViewControllerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//


import UIKit
import Supabase

protocol ReportDetailViewControllerDelegate: AnyObject {
    func didUpdateReport()
}

class ReportDetailViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: ReportDetailViewControllerDelegate?
    private let report: ReportData
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - UI Components
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
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reportIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusView: UIView = {
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
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Status"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusSegmentedControl: UISegmentedControl = {
        let items = ["Pending", "In Progress", "Resolved", "Rejected"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentTintColor = .systemRed
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.addTarget(self, action: #selector(statusChanged(_:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let detailsView: UIView = {
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
    
    private let issueTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let parkingSpotLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoGalleryView: UIView = {
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

    private let photoGalleryLabel: UILabel = {
        let label = UILabel()
        label.text = "Photos"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 120, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var reportImages: [String] = []
    
    // MARK: - Initialization
    init(report: ReportData) {
        self.report = report
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureWithReport()
        fetchReportImages()
        print("viewDidLoad completed")
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(reportIdLabel)
        headerView.addSubview(dateLabel)
        
        contentView.addSubview(statusView)
        statusView.addSubview(statusLabel)
        statusView.addSubview(statusSegmentedControl)
        
        contentView.addSubview(detailsView)
        detailsView.addSubview(issueTypeLabel)
        detailsView.addSubview(descriptionLabel)
        detailsView.addSubview(parkingSpotLabel)
        
        contentView.addSubview(photoGalleryView)
        photoGalleryView.addSubview(photoGalleryLabel)
        photoGalleryView.addSubview(photoCollectionView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            reportIdLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            reportIdLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: reportIdLabel.bottomAnchor, constant: 8),
            
            statusView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 16),
            
            statusSegmentedControl.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            statusSegmentedControl.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 16),
            statusSegmentedControl.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -16),
            statusSegmentedControl.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -16),
            
            detailsView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            detailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            
            issueTypeLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 16),
            issueTypeLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            issueTypeLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: issueTypeLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            parkingSpotLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            parkingSpotLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            parkingSpotLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            parkingSpotLabel.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: -16),
            
            photoGalleryView.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 16),
            photoGalleryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoGalleryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoGalleryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            photoGalleryLabel.topAnchor.constraint(equalTo: photoGalleryView.topAnchor, constant: 16),
            photoGalleryLabel.leadingAnchor.constraint(equalTo: photoGalleryView.leadingAnchor, constant: 16),
            
            photoCollectionView.topAnchor.constraint(equalTo: photoGalleryLabel.bottomAnchor, constant: 12),
            photoCollectionView.leadingAnchor.constraint(equalTo: photoGalleryView.leadingAnchor, constant: 16),
            photoCollectionView.trailingAnchor.constraint(equalTo: photoGalleryView.trailingAnchor, constant: -16),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 120),
            photoCollectionView.bottomAnchor.constraint(equalTo: photoGalleryView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Report Details"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(PhotoGalleryCell.self, forCellWithReuseIdentifier: "PhotoGalleryCell")
    }

    private func fetchReportImages() {
        Task {
            do {
                let images: [ImageRecord] = try await supabase
                    .from("report_images")
                    .select("*")
                    .eq("report_id", value: report.id?.uuidString ?? "")
                    .execute()
                    .value
                
                print("Fetched image records: \(images)") // Add this debug print
                
                self.reportImages = images.map { $0.imageURL }
                print("Mapped image URLs: \(self.reportImages)") // Add this debug print
                
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                    print("Collection view reloaded") // Add this debug print
                }
            } catch {
                print("Error fetching images: \(error)")
            }
        }
    }
    private func configureWithReport() {
        reportIdLabel.text = "Report #\(report.id?.uuidString.prefix(8) ?? "")"
        dateLabel.text = formatDate(report.date ?? "")
        issueTypeLabel.text = "Issue: \(report.issueType)"
        descriptionLabel.text = report.description
        parkingSpotLabel.text = "Parking Spot ID: \(report.parkingSpotID)"
        
        // Set initial status in segmented control
        switch report.status.lowercased() {
        case "pending":
            statusSegmentedControl.selectedSegmentIndex = 0
        case "in progress":
            statusSegmentedControl.selectedSegmentIndex = 1
        case "resolved":
            statusSegmentedControl.selectedSegmentIndex = 2
        case "rejected":
            statusSegmentedControl.selectedSegmentIndex = 3
        default:
            statusSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Actions
    @objc private func statusChanged(_ sender: UISegmentedControl) {
        let statuses = ["Pending", "In Progress", "Resolved", "Rejected"]
        let newStatus = statuses[sender.selectedSegmentIndex]
        
        Task {
            do {
                try await supabase
                    .from("reports")
                    .update(["status": newStatus])
                    .eq("id", value: report.id?.uuidString ?? "")
                    .execute()
                
                DispatchQueue.main.async {
                    self.delegate?.didUpdateReport()
                }
            } catch {
                print("Error updating status: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to update status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showFullScreenImage(imageURL: String) {
        let fullScreenVC = FullScreenImageViewController(imageURL: imageURL)
        present(fullScreenVC, animated: true)
    }
}

extension ReportDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of images: \(reportImages.count)") // Add this debug print
        return reportImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGalleryCell", for: indexPath) as! PhotoGalleryCell
        let imageURL = reportImages[indexPath.row]
        print("Setting up cell at index \(indexPath.row) with URL: \(imageURL)") // Add this debug print
        cell.configure(with: imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Show full-screen image viewer
        let imageURL = reportImages[indexPath.row]
        showFullScreenImage(imageURL: imageURL)
    }
}
