//
//  DetailsAppointmentViewController.swift
//  No-MakeUp
//
//  Created by Димон on 1.12.23.
//

import UIKit

final class DetailsAppointmentViewController: UIViewController {
    
    var client: Client?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let textSectionView = UIView()
    private let nameLabel = UILabel()
    private let instagramLabel = UILabel()
    private let notesLabel = UILabel()
    private let notesTitleLabel = UILabel()
    
    private let dateTimeSectionView = UIView()
    private let dateTitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let timeTitleLabel = UILabel()
    private let timeLabel = UILabel()
    
    private let notificationSectionView = UIView()
    private let notificationTitleLabel = UILabel()
    private let notificationLabel = UILabel()
    private let notificationImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupToolbar()
        configureLayout()
        prepareLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setupToolbar(false)
    }
}

extension DetailsAppointmentViewController {
    
    func setupNavigationBar() {
        navigationItem.title = localized(of: .appointment)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle")?.withTintColor(.systemBlue),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(editAppointment))
    }
    
    func setupToolbar(_ hidden: Bool = true) {
        navigationController?.setToolbarHidden(hidden, animated: true)
    }
}

extension DetailsAppointmentViewController {
    
    @objc private func editAppointment() {
        let controller = EditAppointmentViewController()
        controller.client = client
        controller.updateClientClosure = updateClient
        push(of: controller)
    }
    
    @objc private func handleInstagramLink() {
        print(#function)
        guard let username = client?.instagram else { return }
        guard let url = URL(string: "https://instagram.com/\(username)") else { return }
        print(url)
        UIApplication.shared.open(url)
    }
    
    private func createSeparatedView() -> UIView {
        let separate = UIView()
        separate.translatesAutoresizingMaskIntoConstraints = false
        separate.backgroundColor = .darkGray
        
        return separate
    }
    
    private func updateClient(updatedClient: Client) {
        nameLabel.text = updatedClient.name
        
        if let instagram = updatedClient.instagram {
            instagramLabel.text = "@\(instagram)".lowercased()
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(handleInstagramLink))
            instagramLabel.addGestureRecognizer(recognizer)
        }
        if let notes = updatedClient.notes {
            notesLabel.text = notes
        }
        
        dateLabel.text = updatedClient.makeUpAppointmentDate?.dateFormat
        timeLabel.text = updatedClient.makeUpAppointmentTime?.timeFormat
        
        if !updatedClient.notificationsArray.isEmpty {
            guard let type = updatedClient.notificationsArray.first?.notificationType else { return }
            notificationLabel.text = NotificationsManager().fetchNotificationSubtitle(of: type)
        } else {
            notificationLabel.text = localized(of: .notificationsIsAbsent)
        }
        
        if !updatedClient.notificationsArray.isEmpty {
            let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
            let image = UIImage(systemName: "bell.badge", withConfiguration: configuration)
            notificationImageView.image = image
        } else {
            let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
            let image = UIImage(systemName: "bell.badge.slash", withConfiguration: configuration)
            notificationImageView.image = image
        }
    }
}

extension DetailsAppointmentViewController {
    
    func configureLayout() {
        configureSuperView()
        configureScrollView()
        configureContentView()
        configureTextSectionView()
        configureTextSectionLabels()
        configureDateTimeSectionView()
        configureDateTimeSectionLabels()
        configureNotificationSectionView()
        configureNotificationSectionLabels()
        configureNotificationSectionImageView()
    }
    
    func prepareLayout() {
        prepareScrollView()
        prepareTextSectionView()
        prepareTextSectionLabels()
        prepareDateTimeSectionView()
        prepareDateTimeSectionLabels()
        prepareNotificationSectionView()
        prepareNotificationSectionLabels()
        prepareNotificationSectionImageView()
    }
    
    func configureSuperView() {
        view.backgroundColor = .background
    }
    
    func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.backgroundColor = .background
    }
    
    func configureContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .background
    }
    
    func configureTextSectionView() {
        textSectionView.translatesAutoresizingMaskIntoConstraints = false
        textSectionView.backgroundColor = .sectionBackground
        textSectionView.layer.cornerRadius = 20
    }
    
    func configureTextSectionLabels() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        instagramLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .medium)
        instagramLabel.font = .systemFont(ofSize: 20, weight: .medium)
        notesLabel.font = .systemFont(ofSize: 18, weight: .medium)
        notesTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        instagramLabel.textColor = .systemBlue
        instagramLabel.isUserInteractionEnabled = true
        notesLabel.numberOfLines = 0
        
        guard let client = client else { return }
        
        nameLabel.text = client.name
        
        if let instagram = client.instagram {
            instagramLabel.text = "@\(instagram)".lowercased()
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(handleInstagramLink))
            instagramLabel.addGestureRecognizer(recognizer)
        }
        if let notes = client.notes {
            notesTitleLabel.text = "\(localized(of: .notes)):"
            notesLabel.text = notes
        }
    }
    
    func configureDateTimeSectionView() {
        dateTimeSectionView.translatesAutoresizingMaskIntoConstraints = false
        dateTimeSectionView.backgroundColor = .sectionBackground
        dateTimeSectionView.layer.cornerRadius = 20
    }
    
    func configureDateTimeSectionLabels() {
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        timeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        dateLabel.font = .systemFont(ofSize: 18, weight: .regular)
        timeTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        timeLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        guard let client = client else { return }
        
        dateTitleLabel.text = "\(localized(of: .date)):"
        dateLabel.text = client.makeUpAppointmentDate?.dateFormat
        timeTitleLabel.text = "\(localized(of: .time)):"
        timeLabel.text = client.makeUpAppointmentTime?.timeFormat
    }
    
    func configureNotificationSectionView() {
        notificationSectionView.translatesAutoresizingMaskIntoConstraints = false
        notificationSectionView.backgroundColor = .sectionBackground
        notificationSectionView.layer.cornerRadius = 20
    }
    
    func configureNotificationSectionLabels() {
        notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        notificationTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        notificationLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        guard let client = client else { return }
        
        notificationTitleLabel.text = localized(of: .reminder)
        
        if !client.notificationsArray.isEmpty {
            guard let type = client.notificationsArray.first?.notificationType else { return }
            notificationLabel.text = NotificationsManager().fetchNotificationSubtitle(of: type)
        } else {
            notificationLabel.text = localized(of: .notificationsIsAbsent)
        }
    }
    
    func configureNotificationSectionImageView() {
        notificationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let client = client else { return }
        
        if !client.notificationsArray.isEmpty {
            let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
            let image = UIImage(systemName: "bell.badge", withConfiguration: configuration)
            notificationImageView.image = image
        } else {
            let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
            let image = UIImage(systemName: "bell.badge.slash", withConfiguration: configuration)
            notificationImageView.image = image
        }
    }
    
    func prepareScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func prepareTextSectionView() {
        contentView.addSubview(textSectionView)
        
        NSLayoutConstraint.activate([
            textSectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            textSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    func prepareTextSectionLabels() {
        let nameSeparate = createSeparatedView()
        let instagramSeparate = createSeparatedView()
        textSectionView.addSubview(nameSeparate)
        textSectionView.addSubview(instagramSeparate)
        textSectionView.addSubview(nameLabel)
        textSectionView.addSubview(instagramLabel)
        textSectionView.addSubview(notesTitleLabel)
        textSectionView.addSubview(notesLabel)
        
        NSLayoutConstraint.activate([
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: textSectionView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            
            // Separated View
            nameSeparate.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameSeparate.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            nameSeparate.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            nameSeparate.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Instagram Label
            instagramLabel.topAnchor.constraint(equalTo: nameSeparate.bottomAnchor, constant: 10),
            instagramLabel.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            instagramLabel.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            
            // Separated View
            instagramSeparate.topAnchor.constraint(equalTo: instagramLabel.bottomAnchor, constant: 10),
            instagramSeparate.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            instagramSeparate.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            instagramSeparate.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Notes Title Label
            notesTitleLabel.topAnchor.constraint(equalTo: instagramSeparate.bottomAnchor, constant: 10),
            notesTitleLabel.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            notesTitleLabel.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            
            // Notes Label
            notesLabel.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 5),
            notesLabel.leadingAnchor.constraint(equalTo: textSectionView.leadingAnchor, constant: 10),
            notesLabel.trailingAnchor.constraint(equalTo: textSectionView.trailingAnchor, constant: -10),
            notesLabel.bottomAnchor.constraint(equalTo: textSectionView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareDateTimeSectionView() {
        contentView.addSubview(dateTimeSectionView)
        
        NSLayoutConstraint.activate([
            dateTimeSectionView.topAnchor.constraint(equalTo: textSectionView.bottomAnchor, constant: 30),
            dateTimeSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            dateTimeSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    func prepareDateTimeSectionLabels() {
        let separate = createSeparatedView()
        dateTimeSectionView.addSubview(separate)
        dateTimeSectionView.addSubview(dateTitleLabel)
        dateTimeSectionView.addSubview(dateLabel)
        dateTimeSectionView.addSubview(timeTitleLabel)
        dateTimeSectionView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            // Date Title Label
            dateTitleLabel.topAnchor.constraint(equalTo: dateTimeSectionView.topAnchor, constant: 10),
            dateTitleLabel.leadingAnchor.constraint(equalTo: dateTimeSectionView.leadingAnchor, constant: 10),
            dateTitleLabel.trailingAnchor.constraint(equalTo: dateTimeSectionView.trailingAnchor, constant: -10),
            
            // Date Label
            dateLabel.topAnchor.constraint(equalTo: dateTitleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: dateTimeSectionView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: dateTimeSectionView.trailingAnchor, constant: -10),
            
            // Separated View
            separate.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            separate.leadingAnchor.constraint(equalTo: dateTimeSectionView.leadingAnchor, constant: 10),
            separate.trailingAnchor.constraint(equalTo: dateTimeSectionView.trailingAnchor, constant: -10),
            separate.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Time Title Label
            timeTitleLabel.topAnchor.constraint(equalTo: separate.bottomAnchor, constant: 10),
            timeTitleLabel.leadingAnchor.constraint(equalTo: dateTimeSectionView.leadingAnchor, constant: 10),
            timeTitleLabel.trailingAnchor.constraint(equalTo: dateTimeSectionView.trailingAnchor, constant: -10),
            
            // Time Label
            timeLabel.topAnchor.constraint(equalTo: timeTitleLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: dateTimeSectionView.leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: dateTimeSectionView.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: dateTimeSectionView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareNotificationSectionView() {
        contentView.addSubview(notificationSectionView)
        
        NSLayoutConstraint.activate([
            notificationSectionView.topAnchor.constraint(equalTo: dateTimeSectionView.bottomAnchor, constant: 30),
            notificationSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            notificationSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            notificationSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:  -30),
        ])
    }
    
    func prepareNotificationSectionLabels() {
        notificationSectionView.addSubview(notificationTitleLabel)
        notificationSectionView.addSubview(notificationLabel)
        
        NSLayoutConstraint.activate([
            notificationTitleLabel.topAnchor.constraint(equalTo: notificationSectionView.topAnchor, constant: 10),
            notificationTitleLabel.leadingAnchor.constraint(equalTo: notificationSectionView.leadingAnchor, constant: 10),
            
            notificationLabel.topAnchor.constraint(equalTo: notificationTitleLabel.bottomAnchor, constant: 10),
            notificationLabel.leadingAnchor.constraint(equalTo: notificationSectionView.leadingAnchor, constant: 10),
            notificationLabel.trailingAnchor.constraint(equalTo: notificationSectionView.trailingAnchor, constant: -10),
            notificationLabel.bottomAnchor.constraint(equalTo: notificationSectionView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareNotificationSectionImageView() {
        notificationSectionView.addSubview(notificationImageView)
        
        NSLayoutConstraint.activate([
            notificationImageView.topAnchor.constraint(equalTo: notificationSectionView.topAnchor, constant: 10),
            notificationImageView.leadingAnchor.constraint(greaterThanOrEqualTo: notificationTitleLabel.trailingAnchor),
            notificationImageView.trailingAnchor.constraint(equalTo: notificationSectionView.trailingAnchor, constant: -20),
        ])
    }
}
