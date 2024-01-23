//
//  EditAppointmentViewController.swift
//  No-MakeUp
//
//  Created by Димон on 10.12.23.
//

import UIKit
import CoreData

final class EditAppointmentViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    private var viewModel: EditAppointmentViewModelProtocol!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameTextField = AppField()
    private let instagramTextField = AppField()
    private let notesTextView = UITextView()
    
    private let countNotesLabel = UILabel()
    private let notesPlaceholderLabel = UILabel()
    
    private let dateView = UIView()
    private let dateLabel = UILabel()
    private let timeView = UIView()
    private let timeLabel = UILabel()
    private let backgroundCalendarView = UIView()
    private let calendar = UICalendarView()
    
    private let backgroundTimeView = UIView()
    private let timePicker = UIDatePicker()
    
    private let notificationButton = UIButton()
    
    private let notificationView = UIView()
    private let notificationTitleLabel = UILabel()
    private let notificationSubtitleLabel = UILabel()
    private let notificationImageView = UIImageView()
    
    private var appointmentDate: Date?
    private var appointmentTime: Date?
    
    private var notification: LocalNotification?
    
    private var calendarConstraint: NSLayoutConstraint!
    private var timeConstraint: NSLayoutConstraint!
    private var showCalendar = false
    private var showTime = false
    private var keyboardShow = false
    
    var client: Client!
    
    var updateClientClosure: ((Client) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = EditAppointmentViewModel()
        
        setupNavigationBar()
        setupToolbar()
        setupKeyboardListener()
        configureLayout()
        prepareLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setupToolbar(false)
    }
    
    private func setupKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let hideKeyboardRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(discardFocus))
        contentView.addGestureRecognizer(hideKeyboardRecognizer)
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        if !keyboardShow {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + keyboardFrame.height)
        }
        keyboardShow = true
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        contentView.gestureRecognizers?.removeAll()
        if keyboardShow {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height - keyboardFrame.height)
        }
        keyboardShow = false
    }
    
    @objc private func saveNewAppointment() {
        guard let name = nameTextField.text, !name.isEmpty,
              let date = appointmentDate,
              let time = appointmentTime else { return validate() }
        let instagram = instagramTextField.text?.trimmingCharacters(in: .whitespaces)
        let notes = notesTextView.text?.trimmingCharacters(in: .whitespaces)
        let content = NotificationsManager().fetchNotificationContent(of: notification?.notificationType ?? .fiveMinutes,
                                                                      clientName: name.trimmingCharacters(in: .whitespaces))
        notification?.notificationDate = date.dateWithTime(with: time)
        notification?.title = content.title
        notification?.body = content.body
        viewModel.editAppointment(date: date.dateAppointment,
                                    time: time,
                                    name: name.trimmingCharacters(in: .whitespaces),
                                    instagram: instagram,
                                    notes: notes,
                                    notification: notification,
                                    client: client) { client in
            self.updateClientClosure?(client)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func discardFocus() {
        nameTextField.resignFirstResponder()
        instagramTextField.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
    
    @objc private func showHideCalendar() {
        discardFocus()

        UIView.animate(withDuration: 0.3) { [unowned self] in
            if showCalendar {
                calendarConstraint = backgroundCalendarView.heightAnchor.constraint(equalToConstant: 0)
                NSLayoutConstraint.activate([calendarConstraint])
                showCalendar = false
            } else {
                backgroundCalendarView.removeConstraint(calendarConstraint)
                showCalendar = true
                dateView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                .layerMaxXMinYCorner]
                backgroundCalendarView.layer.cornerRadius = 10
                backgroundCalendarView.layer.maskedCorners = [.layerMinXMaxYCorner,
                                                              .layerMaxXMaxYCorner]
            }
            view.layoutIfNeeded()
        } completion: { [unowned self] isCompleted in
            if !showCalendar {
                dateView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                .layerMaxXMinYCorner,
                                                .layerMinXMaxYCorner,
                                                .layerMaxXMaxYCorner]
                backgroundCalendarView.layer.maskedCorners = []
            }
        }
    }
    
    @objc private func showHideTime() {
        discardFocus()
        UIView.animate(withDuration: 0.3) { [unowned self] in
            if showTime {
                timeConstraint.constant = 0
                timePicker.isHidden = true
                showTime = false
            } else {
                timeConstraint.constant = 200
                timePicker.isHidden = false
                showTime = true
                timeView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                .layerMaxXMinYCorner]
                backgroundTimeView.layer.cornerRadius = 10
                backgroundTimeView.layer.maskedCorners = [.layerMinXMaxYCorner,
                                                              .layerMaxXMaxYCorner]
            }
            view.layoutIfNeeded()
        } completion: { [unowned self] isCompleted in
            if !showTime {
                timeView.layer.maskedCorners = [.layerMinXMinYCorner,
                                                .layerMaxXMinYCorner,
                                                .layerMinXMaxYCorner,
                                                .layerMaxXMaxYCorner]
                backgroundTimeView.layer.maskedCorners = []
            }
        }
    }
    
    @objc private func onChangeTime(sender: UIDatePicker) {
        timeLabel.fadeTransition()
        timeLabel.text = sender.date.timeFormat
        appointmentTime = sender.date
    }
    
    private func storeNotifications(of type: NotificationType) {
        let content = NotificationsManager().fetchNotificationContent(of: type,
                                                                      clientName: nameTextField.text ?? "")
        let subtitle = NotificationsManager().fetchNotificationSubtitle(of: type)
        notification = LocalNotification(title: content.title,
                                             body: content.body,
                                             notificationType: type)
        notificationSubtitleLabel.text = subtitle
    }
    
    private func validate() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if name.isEmpty {
            nameTextField.fadeTransition()
            nameTextField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if appointmentDate == nil {
            dateView.fadeTransition()
            dateView.layer.borderWidth = 0.5
            dateView.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        showValidationAlert()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension EditAppointmentViewController {
    
    func setupNavigationBar() {
        navigationItem.title = localized(of: .editing)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveNewAppointment))
    }
    
    func setupToolbar(_ hidden: Bool = true) {
        navigationController?.setToolbarHidden(hidden, animated: true)
    }
    
    func configureLayout() {
        configureSuperView()
        configureScrollView()
        configureContentView()
        configureNameTextField()
        configureInstagramTextField()
        configureNotesTextView()
        configureNotesPlaceholderLabel()
        configureDateView()
        configureCalendarView()
        configureTimeView()
        configureTimePicker()
        configureNotificationView()
        configureNotificationButton()
    }
    
    func prepareLayout() {
        prepareScrollView()
        prepareNameTextField()
        prepareInstagramTextField()
        prepareNotesTextView()
        prepareNotesPlaceholderLabel()
        prepareDataView()
        prepareCalendarView()
        prepareTimeView()
        prepareTimePicker()
        prepareNotificationView()
        prepareNotificationButton()
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
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .background
    }
    
    func configureNameTextField() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.delegate = self
        nameTextField.placeholder = localized(of: .name)
        nameTextField.returnKeyType = .done
        
        nameTextField.text = client?.name
    }
    
    func configureInstagramTextField() {
        instagramTextField.translatesAutoresizingMaskIntoConstraints = false
        instagramTextField.delegate = self
        instagramTextField.placeholder = localized(of: .instagram)
        instagramTextField.returnKeyType = .done
        instagramTextField.autocapitalizationType = .none
        
        instagramTextField.text = client?.instagram
    }
    
    func configureNotesTextView() {
        notesTextView.delegate = self
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.textContainer.maximumNumberOfLines = 0
        notesTextView.textContainer.lineBreakMode = .byWordWrapping
        notesTextView.returnKeyType = .done
        notesTextView.font = .systemFont(ofSize: 17)
        notesTextView.contentInset = .init(top: 5, left: 10, bottom: 0, right: 10)
        
        notesTextView.text = client?.notes
    }
    
    func configureNotesPlaceholderLabel() {
        notesPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        notesPlaceholderLabel.text = localized(of: .notes)
        notesPlaceholderLabel.textColor = .darkGray.withAlphaComponent(0.8)
        notesPlaceholderLabel.font = .systemFont(ofSize: 17)
        
        if client?.notes != nil {
            notesPlaceholderLabel.isHidden = true
        }
    }
    
    func configureCalendarView() {
        backgroundCalendarView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCalendarView.backgroundColor = .sectionBackground
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.locale = Locale(identifier: "ru")
        
        let endYear = (Date.now.dateOnly.year ?? 2060) + 20
        let endDate = DateComponents(calendar: .current, year: endYear, month: 1, day: 1).date ?? .now
        
        calendar.availableDateRange = DateInterval(start: .now, end: endDate)
        calendar.fontDesign = .rounded
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        dateSelection.setSelected(client?.makeUpAppointmentDate?.fullDate, animated: false)
        appointmentDate = client?.makeUpAppointmentDate
        calendar.selectionBehavior = dateSelection
        
        calendar.delegate = self
        calendar.calendar = .current
    }
    
    func configureDateView() {
        dateView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateView.backgroundColor = .sectionBackground
        
        dateView.layer.cornerRadius = 10
        dateView.layer.maskedCorners = [.layerMinXMinYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMaxYCorner]
        
        dateLabel.text = client?.makeUpAppointmentDate?.dateFormat
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showHideCalendar))
        dateView.addGestureRecognizer(recognizer)
    }
    
    func configureTimeView() {
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeView.backgroundColor = .sectionBackground
        
        timeView.layer.cornerRadius = 10
        timeView.layer.maskedCorners = [.layerMinXMinYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMaxYCorner]
        
        timeLabel.text = client?.makeUpAppointmentTime?.timeFormat
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showHideTime))
        timeView.addGestureRecognizer(recognizer)
    }
    
    func configureTimePicker() {
        backgroundTimeView.translatesAutoresizingMaskIntoConstraints = false
        backgroundTimeView.backgroundColor = .sectionBackground
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.setDate(client?.makeUpAppointmentTime ?? .now, animated: false)
        appointmentTime = client?.makeUpAppointmentTime
        timePicker.addTarget(self, action: #selector(onChangeTime), for: .valueChanged)
    }
    
    func configureMenuItems(title: String, of type: NotificationType) -> UIAction {
        let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
        let image = UIImage(systemName: "bell.badge", withConfiguration: configuration)
        
        return UIAction(title: title,
                        image: image,
                        handler: { [weak self] action in
            self?.storeNotifications(of: type)
        })
    }
    
    func configureNotificationButton() {
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.setTitle("", for: [])
        
        let menuElements: [UIMenuElement] = [
            configureMenuItems(title: localized(of: .notificationsMenuOneDay), of: .oneDay),
            configureMenuItems(title: localized(of: .notificationsMenuTwoHour), of: .twoHour),
            configureMenuItems(title: localized(of: .notificationsMenuOneHour), of: .oneHour),
            configureMenuItems(title: localized(of: .notificationsMenuThirtyMinutes), of: .thirtyMinutes),
            configureMenuItems(title: localized(of: .notificationsMenuFiveMinutes), of: .fiveMinutes),
        ]
        
        let menuNotifications = UIMenu(title: localized(of: .notificationsMenuTitle),
                                       identifier: UIMenu.Identifier.application,
                                       children: menuElements)
        notificationButton.addAction(UIAction { _ in
            self.viewModel.requestAuthNotifications()
            self.discardFocus()
        }, for: .menuActionTriggered)
        notificationButton.menu = menuNotifications
        notificationButton.showsMenuAsPrimaryAction = true
    }
    
    func configureNotificationView() {
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        notificationView.backgroundColor = .sectionBackground
        
        notificationView.layer.cornerRadius = 10
        notificationView.layer.maskedCorners = [.layerMinXMinYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMaxYCorner]
        
        let interaction = UIContextMenuInteraction(delegate: self)
        notificationView.addInteraction(interaction)
        
        notificationTitleLabel.text = localized(of: .notificationsMenuButtonTitle)
        if let notifications = client?.notificationsArray {
            storeNotifications(of: notifications.first?.notificationType ?? .fiveMinutes)
        } else {
            notificationSubtitleLabel.text = localized(of: .notificationsMenuButtonNoTitle)
        }
        notificationImageView.image = UIImage(systemName: "chevron.up.chevron.down")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.darkGray)
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
    
    func prepareNameTextField() {
        contentView.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    func prepareInstagramTextField() {
        contentView.addSubview(instagramTextField)
        
        NSLayoutConstraint.activate([
            instagramTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            instagramTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            instagramTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
        ])
    }
    
    func prepareNotesTextView() {
        contentView.addSubview(notesTextView)
        
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(equalTo: instagramTextField.bottomAnchor, constant: 10),
            notesTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            notesTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            notesTextView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func prepareNotesPlaceholderLabel() {
        notesTextView.addSubview(notesPlaceholderLabel)
        
        NSLayoutConstraint.activate([
            notesPlaceholderLabel.topAnchor.constraint(equalTo: notesTextView.topAnchor, constant: 5),
            notesPlaceholderLabel.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 5),
            notesPlaceholderLabel.trailingAnchor.constraint(equalTo: notesTextView.trailingAnchor),
        ])
    }
    
    func prepareDataView() {
        contentView.addSubview(dateView)
        dateView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateView.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 10),
            dateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            dateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateView.heightAnchor.constraint(equalToConstant: 50),
            
            dateLabel.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: dateView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: dateView.trailingAnchor, constant: -10),
            dateLabel.bottomAnchor.constraint(equalTo: dateView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareCalendarView() {
        contentView.addSubview(backgroundCalendarView)
        backgroundCalendarView.addSubview(calendar)
        
        calendarConstraint = backgroundCalendarView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            backgroundCalendarView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 0),
            backgroundCalendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            backgroundCalendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            calendarConstraint,
            
            calendar.topAnchor.constraint(equalTo: backgroundCalendarView.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: backgroundCalendarView.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: backgroundCalendarView.trailingAnchor),
            calendar.bottomAnchor.constraint(equalTo: backgroundCalendarView.bottomAnchor),
        ])
    }
    
    func prepareTimeView() {
        contentView.addSubview(timeView)
        timeView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeView.topAnchor.constraint(equalTo: backgroundCalendarView.bottomAnchor, constant: 10),
            timeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            timeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeView.heightAnchor.constraint(equalToConstant: 50),
            
            timeLabel.topAnchor.constraint(equalTo: timeView.topAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: timeView.leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: timeView.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: timeView.bottomAnchor, constant: -10),
        ])
    }
    
    func prepareTimePicker() {
        contentView.addSubview(backgroundTimeView)
        backgroundTimeView.addSubview(timePicker)
        
        timeConstraint = backgroundTimeView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            backgroundTimeView.topAnchor.constraint(equalTo: timeView.bottomAnchor),
            backgroundTimeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            backgroundTimeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeConstraint,
            
            timePicker.topAnchor.constraint(equalTo: backgroundTimeView.topAnchor),
            timePicker.leadingAnchor.constraint(equalTo: backgroundTimeView.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: backgroundTimeView.trailingAnchor),
            timePicker.bottomAnchor.constraint(equalTo: backgroundTimeView.bottomAnchor),
        ])
    }
    
    func prepareNotificationView() {
        contentView.addSubview(notificationView)
        notificationView.addSubview(notificationTitleLabel)
        notificationView.addSubview(notificationSubtitleLabel)
        notificationView.addSubview(notificationImageView)
        
        NSLayoutConstraint.activate([
            notificationView.topAnchor.constraint(equalTo: backgroundTimeView.bottomAnchor, constant: 30),
            notificationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            notificationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            notificationView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            notificationView.heightAnchor.constraint(equalToConstant: 50),
            
            notificationTitleLabel.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10),
            notificationTitleLabel.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor, constant: 10),
            notificationTitleLabel.bottomAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: -10),
            
            notificationSubtitleLabel.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10),
            notificationSubtitleLabel.leadingAnchor.constraint(equalTo: notificationTitleLabel.trailingAnchor),
            notificationSubtitleLabel.trailingAnchor.constraint(equalTo: notificationImageView.leadingAnchor, constant: -10),
            notificationSubtitleLabel.bottomAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: -10),
            
            notificationImageView.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10),
            notificationImageView.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor, constant: -10),
            notificationImageView.bottomAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: -10)
        ])
    }
    
    func prepareNotificationButton() {
        notificationView.addSubview(notificationButton)
        notificationView.sendSubviewToBack(notificationButton)
        
        NSLayoutConstraint.activate([
            notificationButton.topAnchor.constraint(equalTo: notificationView.topAnchor),
            notificationButton.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor),
            notificationButton.bottomAnchor.constraint(equalTo: notificationView.bottomAnchor),
        ])
    }
}

extension EditAppointmentViewController: UICalendarViewDelegate {
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        print(previousDateComponents)
    }
}

extension EditAppointmentViewController: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        dateLabel.fadeTransition()
        dateLabel.text = dateComponents?.date?.dateFormat ?? Date.now.dateFormat
        appointmentDate = dateComponents?.date
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}

extension EditAppointmentViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholderLabel.isHidden = !notesTextView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        notesPlaceholderLabel.isHidden = !notesTextView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        notesPlaceholderLabel.isHidden = !notesTextView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            notesTextView.resignFirstResponder()
        }
        return true
    }
}

extension EditAppointmentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension EditAppointmentViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [unowned self] suggestedActions in
            let menuElements: [UIMenuElement] = [
                configureMenuItems(title: localized(of: .notificationsMenuOneDay), of: .oneDay),
                configureMenuItems(title: localized(of: .notificationsMenuTwoHour), of: .twoHour),
                configureMenuItems(title: localized(of: .notificationsMenuOneHour), of: .oneHour),
                configureMenuItems(title: localized(of: .notificationsMenuThirtyMinutes), of: .thirtyMinutes),
                configureMenuItems(title: localized(of: .notificationsMenuFiveMinutes), of: .fiveMinutes),
            ]
            
            return UIMenu(title: localized(of: .notificationsMenuTitle), children: menuElements)
        })
    }
}
