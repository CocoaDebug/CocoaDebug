//
//  NetworkViewController.swift
//  PhiSpeaker
//
//  Created by liman on 25/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var models: Array<JxbHttpModel>?
    var cacheModels: Array<JxbHttpModel>?
    var searchModels: Array<JxbHttpModel>?
    
    var foo: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - tool
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        guard let cacheModels = cacheModels else {return}
        searchModels = cacheModels
        
        if searchText == "" {
            models = cacheModels
        }else{
            guard let searchModels = searchModels else {return}
            
            for _ in searchModels {
                if let index = self.searchModels?.index(where: { (model) -> Bool in
                    return !model.url.absoluteString.lowercased().contains(searchText.lowercased())//忽略大小写
                }) {
                    self.searchModels?.remove(at: index)
                }
            }
            models = self.searchModels
        }
    }
    
    //MARK: - private
    func reloadHttp(_ isFirstIn: Bool = false) {
        
        self.models = (JxbHttpDatasource.shareInstance().httpModels as NSArray as? [JxbHttpModel])
        self.cacheModels = self.models
        
        self.searchLogic(DebugManSettings.shared.networkSearchWord ?? "")

        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
            
            if isFirstIn == false {return}
            
            //table下滑到底部
            if let count = self?.models?.count {
                if count > 0 {
                    self?.tableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                    
                    /*
                     //滑动不到最底部, 弃用
                     if let h1 = self?.tableView.contentSize.height, let h2 = self?.tableView.frame.size.height, let bottom = self?.tableView.contentInset.bottom {
                     if h1 > h2 {
                     self?.tableView.setContentOffset(CGPoint.init(x: 0, y: h1-h2+bottom), animated: false)
                     }
                     }*/
                }
            }
        }
    }
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if foo == true {return}
        foo = true
        
        
        guard let models = self.models else {return}
        let count = models.count
        
        if count > 0 {
            //否则第一次进入滑动不到底部
            DispatchQueue.main.async { [weak self] in
                self?.tableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHttp_notification(_ :)), name: NSNotification.Name("reloadHttp_DebugMan"), object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.text = DebugManSettings.shared.networkSearchWord
        tableView.tableFooterView = UIView()
        
        //hide searchBar icon
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        reloadHttp(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
            as! NetworkCell
        
        cell.httpModel = models?[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let serverURL = DebugManSettings.shared.serverURL else {return 0}
        let model = models?[indexPath.row]
        var height: CGFloat = 0.0
        
        if let cString = model?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {
                
                if model?.url.absoluteString.contains(serverURL) == true {
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }else{
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }
                
                return height + 57
            }
        }
        
        return 0  
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let models = models else {return}
        
        if let index = models.index(where: { (model_) -> Bool in
            return model_.isSelected == true
        }) {
            models[index].isSelected = false
        }
        
        let model = models[indexPath.row]
        model.isSelected = true
        
        let vc: NetworkDetailViewController = NetworkDetailViewController.instanceFromStoryBoard()
        vc.httpModel = model
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.justCancelCallback = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let models = models else {return UISwipeActionsConfiguration.init()}
        let model = models[indexPath.row]
        var title = "Tag"
        if model.isTag == true {title = "UnTag"}
        
        let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
            model.isTag = !model.isTag
            self?.dispatch_main_async_safe { [weak self] in
                self?.tableView.reloadData()
            }
            completionHandler(true)
        }
        
        searchBar.resignFirstResponder()
        left.backgroundColor = UIColor.init(hexString: "#007aff")
        return UISwipeActionsConfiguration(actions: [left])
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let models = self?.models else {return}
            JxbHttpDatasource.shareInstance().remove(models[indexPath.row])
            self?.models?.remove(at: indexPath.row)
            self?.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        
        searchBar.resignFirstResponder()
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - only for ios8/ios9/ios10, not ios11
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let models = self.models else {return}
            JxbHttpDatasource.shareInstance().remove(models[indexPath.row])
            self.models?.remove(at: indexPath.row)
            self.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        DebugManSettings.shared.networkSearchWord = searchText
        searchLogic(searchText)
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - target action
    @IBAction func tapTrashButton(_ sender: UIBarButtonItem) {
        JxbHttpDatasource.shareInstance().reset()
        models = []
        cacheModels = []
        searchBar.resignFirstResponder()
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - notification
    @objc func reloadHttp_notification(_ notification: Notification) {
        reloadHttp()
    }
}

