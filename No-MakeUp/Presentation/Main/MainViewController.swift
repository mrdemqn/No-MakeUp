//
//  ViewController.swift
//  Instaura
//
//  Created by Димон on 16.11.23.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
    
    private var viewModel: MainViewModelProtocol!
    
    private var notificationManager = LocalNotificationManager.shared
    
    private var fetchedResultsController: NSFetchedResultsController<Client>!
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate = delegate
        notificationManager.notificationCenter.delegate = self
        
        viewModel = MainViewModel()
        
        setupFetchResultsController()
        
        setupToolBar()
        configureLayout()
        prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @objc private func pushCreateAction() {
        let controller = CreateNewAppointmentViewController()
        push(of: controller)
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
}

extension MainViewController {
    
    func setupNavigationBar() {
        navigationItem.title = localized(of: .myAppointments)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupToolBar() {
        let fixedSpace = UIBarButtonItem(systemItem: .fixedSpace)
        fixedSpace.width = 20
        
        toolbarItems = [
            fixedSpace,
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "\(fetchedResultsController.fetchedObjects?.count ?? 0) \(localized(of: .numberAppointments))"),
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
    
    func prepareLayout() {
        prepareTableView()
    }
    
    func configureSuperView() {
        view.backgroundColor = .background
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(ClientTableViewCell.self,
                           forCellReuseIdentifier: ClientTableViewCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func prepareTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureClientCellModel(client: Client) -> ClientTableViewCellModel {
        let dateClient = client.makeUpAppointmentDate ?? .now
        let timeClient = client.makeUpAppointmentTime ?? .now
        
        return ClientTableViewCellModel(time: timeClient.timeFormat,
                                        date: dateClient.dateFormat,
                                        name: client.name ?? "Маша")
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.identifier, for: indexPath)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
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
        
        viewHeader.configure(with: TableHeaderViewModel(title: ""))
        
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
        push(of: controller)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
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
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert:
                tableView.insertSections(indexSet, with: .fade)
            case .delete:
                tableView.deleteSections(indexSet, with: .fade)
            case .update:
                tableView.reloadSections(indexSet, with: .fade)
            case .move:
                break
            default:
                break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Will Present Notification")
        completionHandler([.list, .sound, .badge, .banner])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did Receive Notification")
        
        let userInfo = response.notification.request.content.userInfo
        if let absolutePath = userInfo[Constants.clientObjectIDNotificationKey] as? String {
            print(absolutePath)
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let url = URL(string: absolutePath) else { return }
            let controller = DetailsAppointmentViewController()
            let client = delegate.coreDataService.fetchWithURL(with: url)
            controller.client = client
            push(of: controller)
        }
        
        
        completionHandler()
    }
}


final class TableViewHeader: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with viewModel: TableHeaderViewModel) {
        titleLabel.text = viewModel.title
    }
    
    private func setup() {
        backgroundColor = .black
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

struct TableHeaderViewModel {
    let title: String
}
