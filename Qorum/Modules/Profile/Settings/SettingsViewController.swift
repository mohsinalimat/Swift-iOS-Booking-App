//
//  SettingsViewController.swift
//  Qorum
//
//  Created by Stanislav on 02.05.2018.
//  Copyright (c) 2018 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsDisplayLogic: class {
    func display(viewModel: Settings.ViewModel)
    func showLoader()
    func hideLoader()
}

class SettingsViewController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.profile
    
    var interactor: SettingsBusinessLogic?
    var router: (NSObjectProtocol & SettingsRoutingLogic & SettingsDataPassing)?
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var buildVersionLabel: UILabel!
    
    var items: [Settings.TableItem] = []
    
    // MARK: - Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter()
        let router = SettingsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothHelper.shared.checkBluetooth()
        tableView.dataSource = self
        tableView.bounces = false
        interactor?.update(.version)
        interactor?.update(.items)
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        router?.routeBack()
    }
    
}

// MARK: - SettingsDisplayLogic
extension SettingsViewController: SettingsDisplayLogic {
    
    func display(viewModel: Settings.ViewModel) {
        switch viewModel {
            
        /* Displays version number */
        case let .version(versionText):
            buildVersionLabel.text = versionText
            
        /* Displays tableview items */
        case .items(let items):
            self.items = items
            tableView.reloadData()
            
        /* Requests interactor to get new state model */
        case .updateItems:
            interactor?.update(.items)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        let item = items[indexPath.row]
        cell.row = indexPath.row
        cell.settingLabel.text = item.title
        cell.settingSwitch.isOn = item.isOn
        cell.settingDetails.text = item.details
        cell.delegate = self
        return cell
    }
    
}

// MARK: - SettingsTableViewCellDelegate
extension SettingsViewController: SettingsTableViewCellDelegate {
    
    func settingsTableViewCell(_ cell: SettingsTableViewCell,
                               at row: Int,
                               didSet isOn: Bool) {
        let defaults = UserDefaults.standard
        switch row {
        case 0: interactor?.update(.visibility(isOn))
        case 1: defaults.set(isOn, for: .autoOpenTabKey)
        case 2: interactor?.update(.twitter(isOn))
        default: break
        }
    }
    
}


