//
//  ListCrashesViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 31/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

class ListCrashesViewController: UITableViewController {

    var models: [LogCrash] = [LogCrash]()
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action:#selector(ListCrashesViewController.deleteCrashes))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        models = StoreManager.shared.crashArray
        tableView.reloadData()
    }

    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //否则偶尔crash
        if indexPath.row >= models.count {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrashListTableViewCell", for: indexPath)
            as! CrashListTableViewCell
        cell.crash = models[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = DetailCrashTableViewController.instanceFromStoryBoard()
        vc.crash = models[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let models = self?.models else {return}
            StoreManager.shared.removeCrash(models[indexPath.row])
            self?.models.remove(at: indexPath.row)
            self?.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - only for ios8/ios9/ios10, not ios11
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            StoreManager.shared.removeCrash(models[indexPath.row])
            self.models.remove(at: indexPath.row)
            self.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    //MARK: - target action
    @objc func deleteCrashes() {
        models = []
        StoreManager.shared.resetCrashs()
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
