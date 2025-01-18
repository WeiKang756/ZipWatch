//
//  SessionDetailViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//


import UIKit

class SessionDetailViewController: UIViewController {
    // MARK: - Properties
    private let session: ParkingSession
    private var timer: Timer?
    
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
    
    private let plateNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLeftContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoCard: UIView = {
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
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let spotLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sessionCard: UIView = {
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
    
    private let sessionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Details"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    init(session: ParkingSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithSession()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Session Details"
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(plateNumberLabel)
        headerView.addSubview(timeLeftContainer)
        timeLeftContainer.addSubview(timeLeftLabel)
        
        contentView.addSubview(infoCard)
        infoCard.addSubview(locationTitleLabel)
        infoCard.addSubview(spotLabel)
        infoCard.addSubview(streetLabel)
        infoCard.addSubview(areaLabel)
        
        contentView.addSubview(sessionCard)
        sessionCard.addSubview(sessionTitleLabel)
        sessionCard.addSubview(startTimeLabel)
        sessionCard.addSubview(endTimeLabel)
        sessionCard.addSubview(durationLabel)
        sessionCard.addSubview(costLabel)
        
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
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            plateNumberLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            plateNumberLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            timeLeftContainer.topAnchor.constraint(equalTo: plateNumberLabel.bottomAnchor, constant: 12),
            timeLeftContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            timeLeftLabel.topAnchor.constraint(equalTo: timeLeftContainer.topAnchor, constant: 6),
            timeLeftLabel.bottomAnchor.constraint(equalTo: timeLeftContainer.bottomAnchor, constant: -6),
            timeLeftLabel.leadingAnchor.constraint(equalTo: timeLeftContainer.leadingAnchor, constant: 12),
            timeLeftLabel.trailingAnchor.constraint(equalTo: timeLeftContainer.trailingAnchor, constant: -12),
            
            infoCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationTitleLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            locationTitleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            spotLabel.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 12),
            spotLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            streetLabel.topAnchor.constraint(equalTo: spotLabel.bottomAnchor, constant: 8),
            streetLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            
            areaLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 8),
            areaLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            areaLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),
            
            sessionCard.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 20),
            sessionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sessionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sessionCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            sessionTitleLabel.topAnchor.constraint(equalTo: sessionCard.topAnchor, constant: 20),
            sessionTitleLabel.leadingAnchor.constraint(equalTo: sessionCard.leadingAnchor, constant: 20),
            
            startTimeLabel.topAnchor.constraint(equalTo: sessionTitleLabel.bottomAnchor, constant: 12),
            startTimeLabel.leadingAnchor.constraint(equalTo: sessionCard.leadingAnchor, constant: 20),
            
            endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 8),
            endTimeLabel.leadingAnchor.constraint(equalTo: sessionCard.leadingAnchor, constant: 20),
            
            durationLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: sessionCard.leadingAnchor, constant: 20),
            
            costLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            costLabel.leadingAnchor.constraint(equalTo: sessionCard.leadingAnchor, constant: 20),
            costLabel.bottomAnchor.constraint(equalTo: sessionCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureWithSession() {
        plateNumberLabel.text = session.plateNumber
        updateTimeLeft()
        
        spotLabel.text = "Spot #\(session.parkingSpot.parkingSpotID)"
        streetLabel.text = "Street: \(session.parkingSpot.street.streetName)"
        areaLabel.text = "Area: \(session.parkingSpot.street.area.areaName)"
        
        startTimeLabel.text = "Start Time: \(DateFormatterUtility.shared.formatTime(session.startTime))"
        endTimeLabel.text = "End Time: \(DateFormatterUtility.shared.formatDate(session.endTime, to: .time))"
        durationLabel.text = "Duration: \(session.duration)"
        costLabel.text = String(format: "Cost: RM %.2f", session.totalCost)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateTimeLeft()
        }
    }
    
    private func updateTimeLeft() {
        let timeLeft = session.calculateTimeLeft()
        timeLeftLabel.text = timeLeft
        
        // Update UI based on time left
        if timeLeft == "Expired" {
            timeLeftContainer.backgroundColor = .systemRed.withAlphaComponent(0.2)
            timeLeftLabel.textColor = .white
        } else {
            timeLeftContainer.backgroundColor = .white.withAlphaComponent(0.1)
            timeLeftLabel.textColor = .white
        }
    }
}
