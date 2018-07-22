//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {
    
    var reachEnd: Bool = true
    
    var firstIn: Bool = true
    
    var models: Array<HttpModel>?
    var cacheModels: Array<HttpModel>?
    var searchModels: Array<HttpModel>?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    
    
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
    func reloadHttp(needScrollToEnd: Bool = false) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) { [weak self] in
            if self?.searchBar.isHidden == true {
                self?.searchBar.isHidden = false
            }
        }
        
        
        self.models = (HttpDatasource.shared().httpModels as NSArray as? [HttpModel])
        self.cacheModels = self.models
        
        self.searchLogic(CocoaDebugSettings.shared.networkSearchWord ?? "")

        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
            
            if needScrollToEnd == false {return}
            
            //table下滑到底部
            if let count = self?.models?.count {
                if count > 0 {
                    guard let firstIn = self?.firstIn else {return}
                    self?.tableView.tableViewScrollToBottom(animated: !firstIn)
                    self?.firstIn = false
                    
                    //self?.tableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteItem.tintColor = Color.mainGreen
        
        //add FPSLabel behind status bar
        addStatusBarBackgroundView(viewController: self)
        
//        UIApplication.shared.statusBarStyle = .lightContent //liman
//        setNeedsStatusBarAppearanceUpdate()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHttp_notification(_ :)), name: NSNotification.Name("reloadHttp_CocoaDebug"), object: nil)
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        searchBar.text = CocoaDebugSettings.shared.networkSearchWord
        searchBar.isHidden = true
        
        //hide searchBar icon
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        reloadHttp(needScrollToEnd: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - target action
    @IBAction func tapTrashButton(_ sender: UIBarButtonItem) {
        HttpDatasource.shared().reset()
        models = []
        cacheModels = []
        searchBar.text = nil
        searchBar.resignFirstResponder()
        CocoaDebugSettings.shared.networkSearchWord = nil
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - notification
    @objc func reloadHttp_notification(_ notification: Notification) {
        
        reloadHttp(needScrollToEnd: reachEnd)
    }
}

//MARK: - UITableViewDataSource
extension NetworkViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
            as! NetworkCell
        
        cell.httpModel = models?[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let serverURL = CocoaDebugSettings.shared.serverURL else {return 0}
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
        left.backgroundColor = "#007aff".hexColor
        return UISwipeActionsConfiguration(actions: [left])
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let models = self?.models else {return}
            HttpDatasource.shared().remove(models[indexPath.row])
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
            HttpDatasource.shared().remove(models[indexPath.row])
            self.models?.remove(at: indexPath.row)
            self.dispatch_main_async_safe { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

//MARK: - UIScrollViewDelegate
extension NetworkViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        searchBar.resignFirstResponder()
        
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            //you reached end of the table
            reachEnd = true
        }else{
            reachEnd = false
        }
    }
}

//MARK: - UISearchBarDelegate
extension NetworkViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        CocoaDebugSettings.shared.networkSearchWord = searchText
        searchLogic(searchText)
        
        dispatch_main_async_safe { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

