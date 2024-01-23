//
//  ViewController.swift
//  Instaura
//
//  Created by Димон on 16.11.23.
//

import UIKit
import CoreData

final class MainViewController: UITableViewController {
    
    private var viewModel: MainViewModelProtocol!
    
    private var fetchedResultsController: NSFetchedResultsController<Client>!
    
    private var countAppointments: Int = 0 {
        didSet {
            setupToolBar()
            if countAppointments == 0 {
                tableView.setEmptyView()
            } else {
                tableView.backgroundView = nil
            }
        }
    }
    
    private var floatingButtonStatus: FloatingButtonStatus = .hide {
        didSet {
            setupToolBar()
        }
    }
    
    private var navigationBarHeight: Double = 0.0
    
    private var appDelegate: AppDelegate!
    
    var shortcutType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate = delegate
        LocalNotificationManager.shared.notificationCenter.delegate = self
        
        viewModel = MainViewModel()
        
        setupFetchResultsController()
        
        configureLayout()
        
        countAppointments = fetchedResultsController.fetchedObjects?.count ?? 0
        
        openedApp()
        LocalNotificationManager.shared.clearAbsolutePath()
        
        handleShortcut(of: shortcutType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        if navigationController?.isToolbarHidden ?? false {
            navigationController?.setToolbarHidden(false, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if navigationBarHeight == 0.0 {
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
            let adjust = tableView.adjustedContentInset.top
            navigationBarHeight = statusBarHeight + adjust
        }
    }
    
    @objc private func pushCreateAction() {
        let controller = CreateNewAppointmentViewController()
        push(of: controller)
    }
    
    @objc private func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    private func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()
        let sectionsSort = NSSortDescriptor(key: #keyPath(Client.makeUpAppointmentDate), ascending: true)
        let rowsSort = NSSortDescriptor(key: #keyPath(Client.makeUpAppointmentTime), ascending: true)
        
        fetchRequest.sortDescriptors = [sectionsSort, rowsSort]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: appDelegate.coreDataService.context,
            sectionNameKeyPath: "makeUpAppointmentDate",
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch failed")
        }
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
    
    @objc private func showCalendarView() {
        let controller = CalendarAppointmentViewController()
        navigationController?.setToolbarHidden(true, animated: false)
        push(of: controller, animationType: .fade)
    }
}

extension MainViewController {
    
    func setupNavigationBar() {
        navigationItem.title = localized(of: .myAppointments)
        navigationController?.navigationBar.prefersLargeTitles = true
        let configuration = UIImage.SymbolConfiguration(paletteColors: [.white, .systemYellow])
        let image = UIImage(systemName: "calendar.day.timeline.left", withConfiguration: configuration)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(showCalendarView))
    }
    
    func configureFloatingBarButton() -> UIBarButtonItem {
        return switch floatingButtonStatus {
            case .show: UIBarButtonItem(image: UIImage(systemName: "arrow.up"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(scrollToTop))
            case .hide: UIBarButtonItem(systemItem: .fixedSpace)
        }
    }
    
    func setupToolBar() {
        let fixedSpace = UIBarButtonItem(systemItem: .fixedSpace)
        fixedSpace.width = 20
        
        let floatingButton = configureFloatingBarButton()

        let countLabel = UILabel()
        countLabel.text = "\(countAppointments) \(localized(of: .numberAppointments))"
        countLabel.font = .systemFont(ofSize: 16, weight: .regular)
        countLabel.textColor = .gray
        let countItem = UIBarButtonItem(customView: countLabel)
        
        toolbarItems = [
            fixedSpace,
            floatingButton,
            UIBarButtonItem(systemItem: .flexibleSpace),
            countItem,
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(image: UIImage(systemName: "plus.circle"),
                            style: .plain,
                            target: self,
                            action: #selector(pushCreateAction)),
            fixedSpace,
        ]
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func configureLayout() {
        configureSuperView()
        configureTableView()
    }
    
    func configureSuperView() {
        view.backgroundColor = .background
    }
    
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.allowsSelection = true
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray.withAlphaComponent(0.5)
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        tableView.register(ClientTableViewCell.self,
                           forCellReuseIdentifier: ClientTableViewCell.identifier)
        
        tableView.backgroundColor = .background
        tableView.sectionHeaderTopPadding = 20
        
        tableView.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func configureClientCellModel(client: Client) -> ClientTableViewCellModel {
        let dateClient = client.makeUpAppointmentDate ?? .now
        let timeClient = client.makeUpAppointmentTime ?? .now
        
        return ClientTableViewCellModel(time: timeClient.timeFormat,
                                        date: dateClient.dateFormat,
                                        name: client.name ?? "Маша")
    }
}

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.identifier, for: indexPath) as? ClientTableViewCell else { return UITableViewCell() }
        cell.numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        cell.configureCellCorners(indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
}

extension MainViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ClientTableViewCell else { return }
        
        cell.selectionStyle = .default
        
        guard let sections = fetchedResultsController.sections else { return }
        let sectionInfo = sections[indexPath.section]
        guard let client = sectionInfo.objects?[indexPath.row] as? Client else { return }
        
        let model = configureClientCellModel(client: client)
        
        cell.setupCell(model: model)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = TableViewHeader()
        
        guard let clientHeader = fetchedResultsController.sections?[section] else { return viewHeader }
        
        viewHeader.configure(with: TableHeaderViewModel(title: clientHeader.name))
        
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sections = fetchedResultsController.sections else { return }
        let sectionInfo = sections[indexPath.section]
        guard let client = sectionInfo.objects?[indexPath.row] as? Client else { return }
        
        let controller = DetailsAppointmentViewController()
        controller.client = client
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.push(of: controller)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > view.bounds.height / 3 && floatingButtonStatus.isHidden {
            floatingButtonStatus = .show
        } else if scrollView.contentOffset.y <= view.bounds.height / 3 && floatingButtonStatus.isShowing {
            floatingButtonStatus = .hide
        }
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
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

extension MainViewController: UIContextMenuInteractionDelegate {
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
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
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                self.show(viewController, sender: self)
            }
        }
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .sound, .badge, .banner])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let absolutePath = userInfo[Constants.clientObjectIDNotificationKey] as? String {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let url = URL(string: absolutePath) else { return }
            let controller = DetailsAppointmentViewController()
            let client = delegate.coreDataService.fetchWithURL(with: url)
            controller.client = client
            push(of: controller)
        }
        
        completionHandler()
    }
    
    private func openedApp() {
        guard let absolutePath = LocalNotificationManager.shared.clientObjectAbsolutePath else { return }
        guard let url = URL(string: absolutePath) else { return }
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let controller = DetailsAppointmentViewController()
        let client = delegate.coreDataService.fetchWithURL(with: url)
        controller.client = client
        push(of: controller)
    }
}
