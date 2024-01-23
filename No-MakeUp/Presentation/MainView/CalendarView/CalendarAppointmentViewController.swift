//
//  CalendarAppointmentViewController.swift
//  No-MakeUp
//
//  Created by Димон on 11.12.23.
//

import UIKit
import FSCalendar
import CoreData

final class CalendarAppointmentViewController: UIViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Client>!
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(ClientTableViewCell.self,
                           forCellReuseIdentifier: ClientTableViewCell.identifier)
        
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background
        tableView.sectionHeaderTopPadding = 20
        tableView.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray.withAlphaComponent(0.5)
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return tableView
    }()
    
    private var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.formatter.dateFormat = "dd MMMM, yyyy"
        
        // MARK: Header settings
        calendar.appearance.headerDateFormat = "yyyy MMM"
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 22, weight: .medium)
        calendar.appearance.headerTitleColor = .white
        
        // MARK: Days settings
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleFont = .systemFont(ofSize: 20, weight: .bold)
        
        // MARK: Weekday settings
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.weekdayFont = .systemFont(ofSize: 18, weight: .medium)
        
        calendar.select(.now)
        
        return calendar
    }()
    
    private var countAppointments: Int = 0 {
        didSet {
            if countAppointments == 0 {
                tableView.setEmptyView()
            } else {
                tableView.backgroundView = nil
            }
        }
    }
    
    private var calendarHeight: Double = 0.0
    
    private var selectedDate: Date?
    
    private var calendarHeightConstraint: NSLayoutConstraint!
    
    private var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate = delegate
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupNavigationBar()
        setupLayout()
        
        setupFetchResultsController(from: .now.oldDate)
        
        countAppointments = fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupToolbar(_ hidden: Bool = true) {
        navigationController?.setToolbarHidden(hidden, animated: false)
    }
    
    @objc private func hideCalendarView() {
        pop(animationType: .fade)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    private func configureClientCellModel(client: Client) -> ClientTableViewCellModel {
        let dateClient = client.makeUpAppointmentDate ?? .now
        let timeClient = client.makeUpAppointmentTime ?? .now
        
        return ClientTableViewCellModel(time: timeClient.timeFormat,
                                        date: dateClient.dateFormat,
                                        name: client.name ?? "Маша")
    }
    
    private func receiveClient(indexPath: IndexPath) -> Client? {
        guard let sections = fetchedResultsController.sections else { return nil }
        let sectionInfo = sections[indexPath.section]
        guard let client = sectionInfo.objects?[indexPath.row] as? Client else { return nil }
        return client
    }
    
    private func deleteClient(indexPath: IndexPath) {
        guard let client = receiveClient(indexPath: indexPath) else { return }
        appDelegate.coreDataService.deleteClient(object: client)
    }
}

extension CalendarAppointmentViewController {
    
    func setupNavigationBar() {
        navigationItem.title = localized(of: .myAppointments)
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        let configuration = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .white])
        let image = UIImage(systemName: "calendar.day.timeline.left", withConfiguration: configuration)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(hideCalendarView))
    }
    
    func setupLayout() {
        configureLayout()
        prepareLayout()
    }
    
    func configureLayout() {
        configureSuperView()
        configureCalendar()
    }
    
    func prepareLayout() {
        prepareCalendarView()
        prepareTableView()
    }
    
    func configureSuperView() {
        view.backgroundColor = .background
    }
    
    func configureCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
    }
    
    func prepareCalendarView() {
        view.addSubview(calendar)
        
        calendarHeightConstraint = NSLayoutConstraint(item: calendar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        
        calendar.addConstraint(calendarHeightConstraint)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func prepareTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CalendarAppointmentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.identifier, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let client = receiveClient(indexPath: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] action, view, completion in
            deleteClientAlert(of: client,
                              index: indexPath,
                              deleteAction: deleteClient)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let editAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] action, view, completion in
            let controller = EditAppointmentViewController()
            controller.client = client
            push(of: controller)
            completion(true)
        }
        editAction.backgroundColor = .systemPurple
        let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
        editAction.image = UIImage(systemName: "list.bullet.clipboard", withConfiguration: configuration)

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ClientTableViewCell else { return }
        
        guard let sections = fetchedResultsController.sections else { return }
        let sectionInfo = sections[indexPath.section]
        guard let client = sectionInfo.objects?[indexPath.row] as? Client else { return }
        
        let model = configureClientCellModel(client: client)
        
        cell.setupCell(model: model)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = TableViewHeader()
        
        guard let clientHeader = fetchedResultsController.sections?[section] else { return viewHeader }
        
        viewHeader.configure(with: TableHeaderViewModel(title: clientHeader.name))
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sections = fetchedResultsController.sections else { return }
        let sectionInfo = sections[indexPath.section]
        guard let client = sectionInfo.objects?[indexPath.row] as? Client else { return }
        
        let controller = DetailsAppointmentViewController()
        controller.client = client
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.push(of: controller)
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
}

extension CalendarAppointmentViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if selectedDate?.dateFormat == date.dateFormat {
            calendar.deselect(date)
            selectedDate = nil
            calendar.setScope(.month, animated: true)
        } else {
            selectedDate = date
            calendar.setScope(.week, animated: true)
            setupFetchResultsController(from: date.dateAppointment)
        }
    }
}

extension CalendarAppointmentViewController: NSFetchedResultsControllerDelegate {
    
    private func setupFetchResultsController(from date: Date) {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()
        let rowsSort = NSSortDescriptor(key: #keyPath(Client.makeUpAppointmentTime), ascending: true)
        let predicate = NSPredicate(format: "makeUpAppointmentDate == %@", date as CVarArg)
        
        fetchRequest.sortDescriptors = [rowsSort]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: appDelegate.coreDataService.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            countAppointments = fetchedResultsController.fetchedObjects?.count ?? 0
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                break
        }
        countAppointments = fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .bottom)
            case .delete:
                tableView.deleteSections(indexSet, with: .top)
            case .update:
                tableView.reloadSections(indexSet, with: .fade)
            case .move:
                break
            default:
                break
        }
        countAppointments = fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension CalendarAppointmentViewController: UIContextMenuInteractionDelegate {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let client = receiveClient(indexPath: indexPath) else { return nil }
        
        let controller = DetailsAppointmentViewController()
        controller.client = client
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: { controller }) { element in
            let edit = UIAction(title: self.localized(of: .edit),
                                image: UIImage(systemName: "list.bullet.clipboard")?.withRenderingMode(.alwaysOriginal)) { action in
                let controller = EditAppointmentViewController()
                controller.client = client
                self.push(of: controller)
            }

            let delete = UIAction(title: self.localized(of: .delete),
                                  image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                                  attributes: .destructive) { action in
                self.deleteClientAlert(of: client,
                                       index: indexPath,
                                       deleteAction: self.deleteClient)
            }

            return UIMenu(title: self.localized(of: .tableViewMenuActionsTitle), children: [edit, delete])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                self.show(viewController, sender: self)
            }
        }
    }
}
