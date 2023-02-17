//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {
    
    var reachEnd: Bool = true
    var firstIn: Bool = true
    var reloadDataFinish: Bool = true
    
    var models: Array<_HttpModel>?
    var cacheModels: Array<_HttpModel>?
    var searchModels: Array<_HttpModel>?
    
    var naviItemTitleLabel: UILabel?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    //MARK: - tool
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        guard let cacheModels = cacheModels else {return}
        searchModels = cacheModels
        
        if searchText == "" {
            models = cacheModels
        } else {
            guard let searchModels = searchModels else {return}
            
            for _ in searchModels {
                if let index = self.searchModels?.firstIndex(where: { (model) -> Bool in
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
        
        if reloadDataFinish == false {return}
        
        if searchBar.isHidden != false {
            searchBar.isHidden = false
        }
        
        self.models = (_HttpDatasource.shared().httpModels as NSArray as? [_HttpModel])
        self.cacheModels = self.models
        
        self.searchLogic(CocoaDebugSettings.shared.networkSearchWord ?? "")
        
        //        dispatch_main_async_safe { [weak self] in
        self.reloadDataFinish = false
        self.tableView.reloadData {
            self.reloadDataFinish = true
        }
        
        if needScrollToEnd == false {return}
        
        //table下滑到底部
        if let count = self.models?.count {
            if count > 0 {
                //                    guard let firstIn = self.firstIn else {return}
                self.tableView.tableViewScrollToBottom(animated: !firstIn)
                self.firstIn = false
            }
        }
        //        }
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItem.titleView = naviItemTitleLabel
        
        naviItemTitleLabel?.text = "🚀[0]"
        deleteItem.tintColor = Color.mainGreen
        
        //notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadHttp_CocoaDebug"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.reloadHttp(needScrollToEnd: self?.reachEnd ?? true)
        }
        
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        //抖动bug
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        searchBar.delegate = self
        searchBar.text = CocoaDebugSettings.shared.networkSearchWord
        searchBar.isHidden = true
        
        //hide searchBar icon
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = .never
        textFieldInsideSearchBar.leftView = nil
        textFieldInsideSearchBar.backgroundColor = .white
        textFieldInsideSearchBar.returnKeyType = .default
        
        reloadHttp(needScrollToEnd: true)
        
        if models?.count ?? 0 > CocoaDebugSettings.shared.networkLastIndex && CocoaDebugSettings.shared.networkLastIndex > 0 {
            tableView.tableViewScrollToIndex(index: CocoaDebugSettings.shared.networkLastIndex, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    deinit {
        //notification
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - target action
    @IBAction func didTapDown(_ sender: Any) {
        tableView.tableViewScrollToBottom(animated: true)
        searchBar.resignFirstResponder()
        reachEnd = true
        CocoaDebugSettings.shared.networkLastIndex = 0
    }
    
    @IBAction func didTapUp(_ sender: Any) {
        tableView.tableViewScrollToHeader(animated: true)
        searchBar.resignFirstResponder()
        reachEnd = false
        CocoaDebugSettings.shared.networkLastIndex = 0
    }
    
    
    @IBAction func tapTrashButton(_ sender: UIBarButtonItem) {
        _HttpDatasource.shared().reset()
        models = []
        cacheModels = []
        //        searchBar.text = nil
        searchBar.resignFirstResponder()
        //        CocoaDebugSettings.shared.networkSearchWord = nil
        CocoaDebugSettings.shared.networkLastIndex = 0
        
        //        dispatch_main_async_safe { [weak self] in
        self.tableView.reloadData()
        self.naviItemTitleLabel?.text = "🚀[0]"
        //        }
        
        NotificationCenter.default.post(name: NSNotification.Name("deleteAllLogs_CocoaDebug"), object: nil, userInfo: nil)
    }
    
    @objc func didTapView() {
        searchBar.resignFirstResponder()
    }
}

//MARK: - UITableViewDataSource
extension NetworkViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = models?.count {
            naviItemTitleLabel?.text = "🚀[" + String(count) + "]"
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
            as! NetworkCell
        
        cell.httpModel = models?[indexPath.row]
        cell.index = indexPath.row
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
                } else {
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
        searchBar.resignFirstResponder()
        reachEnd = false
        
        guard let models = models else {return}
        
        let vc: NetworkDetailViewController = NetworkDetailViewController.instanceFromStoryBoard()
        vc.httpModels = models
        vc.httpModel = models[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.justCancelCallback = { [weak self] in
            self?.tableView.reloadData()
        }
        
        CocoaDebugSettings.shared.networkLastIndex = indexPath.row
    }
}

//MARK: - UIScrollViewDelegate
extension NetworkViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        reachEnd = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            //bottom reached
            reachEnd = true
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
        
        //        dispatch_main_async_safe { [weak self] in
        self.tableView.reloadData()
        //        }
    }
}

