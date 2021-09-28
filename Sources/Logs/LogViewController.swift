//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    var reachEndDefault: Bool = true
    var reachEndRN: Bool = true
    var reachEndWeb: Bool = true
    
    var firstInDefault: Bool = true
    var firstInRN: Bool = true
    var firstInWeb: Bool = true
    
    var selectedSegmentIndex: Int = 0
    var selectedSegment_0: Bool = false
    var selectedSegment_1: Bool = false
    var selectedSegment_2: Bool = false
    
    var defaultReloadDataFinish: Bool = true
    var rnReloadDataFinish: Bool = true
    var webReloadDataFinish: Bool = true
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    
    @IBOutlet weak var defaultTableView: UITableView!
    @IBOutlet weak var defaultSearchBar: UISearchBar!
    var defaultModels: [_OCLogModel] = [_OCLogModel]()
    var defaultCacheModels: Array<_OCLogModel>?
    var defaultSearchModels: Array<_OCLogModel>?
    
    @IBOutlet weak var rnTableView: UITableView!
    @IBOutlet weak var rnSearchBar: UISearchBar!
    var rnModels: [_OCLogModel] = [_OCLogModel]()
    var rnCacheModels: Array<_OCLogModel>?
    var rnSearchModels: Array<_OCLogModel>?
    
    @IBOutlet weak var webTableView: UITableView!
    @IBOutlet weak var webSearchBar: UISearchBar!
    var webModels: [_OCLogModel] = [_OCLogModel]()
    var webCacheModels: Array<_OCLogModel>?
    var webSearchModels: Array<_OCLogModel>?
    
    
    
    //MARK: - tool
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        
        if selectedSegmentIndex == 0
        {
            guard let defaultCacheModels = defaultCacheModels else {return}
            defaultSearchModels = defaultCacheModels
            
            if searchText == "" {
                defaultModels = defaultCacheModels
            } else {
                guard let defaultSearchModels = defaultSearchModels else {return}
                
                for _ in defaultSearchModels {
                    if let index = self.defaultSearchModels?.firstIndex(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.defaultSearchModels?.remove(at: index)
                    }
                }
                defaultModels = self.defaultSearchModels ?? []
            }
        }
        else if selectedSegmentIndex == 1
        {
            guard let rnCacheModels = rnCacheModels else {return}
            rnSearchModels = rnCacheModels
            
            if searchText == "" {
                rnModels = rnCacheModels
            } else {
                guard let rnSearchModels = rnSearchModels else {return}
                
                for _ in rnSearchModels {
                    if let index = self.rnSearchModels?.firstIndex(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.rnSearchModels?.remove(at: index)
                    }
                }
                rnModels = self.rnSearchModels ?? []
            }
        }
        else
        {
            guard let webCacheModels = webCacheModels else {return}
            webSearchModels = webCacheModels
            
            if searchText == "" {
                webModels = webCacheModels
            } else {
                guard let webSearchModels = webSearchModels else {return}
                
                for _ in webSearchModels {
                    if let index = self.webSearchModels?.firstIndex(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.webSearchModels?.remove(at: index)
                    }
                }
                webModels = self.webSearchModels ?? []
            }
        }
    }
    
    //MARK: - private
    func reloadLogs(needScrollToEnd: Bool = false, needReloadData: Bool = true) {
        
        if selectedSegmentIndex == 0
        {
            if defaultReloadDataFinish == false {return}
            
            if defaultSearchBar.isHidden != false ||
                rnSearchBar.isHidden != true ||
                webSearchBar.isHidden != true {
                defaultSearchBar.isHidden = false
                rnSearchBar.isHidden = true
                webSearchBar.isHidden = true
            }
            
            if defaultTableView.isHidden != false ||
                rnTableView.isHidden != true ||
                webTableView.isHidden != true {
                defaultTableView.isHidden = false
                rnTableView.isHidden = true
                webTableView.isHidden = true
            }
            
            if needReloadData == false && defaultModels.count > 0 {return}
            
            if let arr = _OCLogStoreManager.shared()?.normalLogArray {
                defaultModels = arr as! [_OCLogModel]
            }
            
            self.defaultCacheModels = self.defaultModels
            
            self.searchLogic(CocoaDebugSettings.shared.logSearchWordNormal ?? "")
            
            //            dispatch_main_async_safe { [weak self] in
            self.defaultReloadDataFinish = false
            self.defaultTableView.reloadData {
                self.defaultReloadDataFinish = true
            }
            
            if needScrollToEnd == false {return}
            
            //table下滑到底部
            //                guard let count = self.defaultModels.count else {return}
            if self.defaultModels.count > 0 {
                //                    guard let firstInDefault = self.firstInDefault else {return}
                self.defaultTableView.tableViewScrollToBottom(animated: !firstInDefault)
                self.firstInDefault = false
            }
            //            }
        }
        else if selectedSegmentIndex == 1
        {
            if rnReloadDataFinish == false {return}
            
            if defaultSearchBar.isHidden != true ||
                rnSearchBar.isHidden != false ||
                webSearchBar.isHidden != true {
                defaultSearchBar.isHidden = true
                rnSearchBar.isHidden = false
                webSearchBar.isHidden = true
            }
            
            if defaultTableView.isHidden != true ||
                rnTableView.isHidden != false ||
                webTableView.isHidden != true {
                defaultTableView.isHidden = true
                rnTableView.isHidden = false
                webTableView.isHidden = true
            }
            
            if needReloadData == false && rnModels.count > 0 {return}
            
            if let arr = _OCLogStoreManager.shared()?.rnLogArray {
                rnModels = arr as! [_OCLogModel]
            }
            
            self.rnCacheModels = self.rnModels
            
            self.searchLogic(CocoaDebugSettings.shared.logSearchWordRN ?? "")
            
            //            dispatch_main_async_safe { [weak self] in
            self.rnReloadDataFinish = false
            self.rnTableView.reloadData {
                self.rnReloadDataFinish = true
            }
            
            if needScrollToEnd == false {return}
            
            //table下滑到底部
            //                guard let count = self.rnModels.count else {return}
            if self.rnModels.count > 0 {
                //                    guard let firstInRN = self.firstInRN else {return}
                self.rnTableView.tableViewScrollToBottom(animated: !firstInRN)
                self.firstInRN = false
            }
            //            }
        }
        else
        {
            if webReloadDataFinish == false {return}
            
            if defaultSearchBar.isHidden != true ||
                rnSearchBar.isHidden != true ||
                webSearchBar.isHidden != false {
                defaultSearchBar.isHidden = true
                rnSearchBar.isHidden = true
                webSearchBar.isHidden = false
            }
            
            if defaultTableView.isHidden != true ||
                rnTableView.isHidden != true ||
                webTableView.isHidden != false {
                defaultTableView.isHidden = true
                rnTableView.isHidden = true
                webTableView.isHidden = false
            }
            
            if needReloadData == false && webModels.count > 0 {return}
            
            if let arr = _OCLogStoreManager.shared().webLogArray {
                webModels = arr as! [_OCLogModel]
            }
            
            self.webCacheModels = self.webModels
            
            self.searchLogic(CocoaDebugSettings.shared.logSearchWordWeb ?? "")
            
            //            dispatch_main_async_safe { [weak self] in
            self.webReloadDataFinish = false
            self.webTableView.reloadData {
                self.webReloadDataFinish = true
            }
            
            if needScrollToEnd == false {return}
            
            //table下滑到底部
            //                guard let count = self.webModels.count else {return}
            if self.webModels.count > 0 {
                //                    guard let firstInWeb = self.firstInWeb else {return}
                self.webTableView.tableViewScrollToBottom(animated: !firstInWeb)
                self.firstInWeb = false
            }
            //            }
        }
    }
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
        deleteItem.tintColor = Color.mainGreen
        segmentedControl.tintColor = Color.mainGreen
        
        if UIScreen.main.bounds.size.width == 320 {
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        } else {
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        }
        
        //notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refreshLogs_CocoaDebug"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.refreshLogs_notification()
        }
        
        
        defaultTableView.tableFooterView = UIView()
        defaultTableView.delegate = self
        defaultTableView.dataSource = self
        //        defaultTableView.rowHeight = UITableViewAutomaticDimension
        defaultSearchBar.delegate = self
        defaultSearchBar.text = CocoaDebugSettings.shared.logSearchWordNormal
        defaultSearchBar.isHidden = true
        //抖动bug
        defaultTableView.estimatedRowHeight = 0
        defaultTableView.estimatedSectionHeaderHeight = 0
        defaultTableView.estimatedSectionFooterHeight = 0
        
        
        
        rnTableView.tableFooterView = UIView()
        rnTableView.delegate = self
        rnTableView.dataSource = self
        //        rnTableView.rowHeight = UITableViewAutomaticDimension
        rnSearchBar.delegate = self
        rnSearchBar.text = CocoaDebugSettings.shared.logSearchWordRN
        rnSearchBar.isHidden = true
        //抖动bug
        rnTableView.estimatedRowHeight = 0
        rnTableView.estimatedSectionHeaderHeight = 0
        rnTableView.estimatedSectionFooterHeight = 0
        
        
        
        webTableView.tableFooterView = UIView()
        webTableView.delegate = self
        webTableView.dataSource = self
        //        webTableView.rowHeight = UITableViewAutomaticDimension
        webSearchBar.delegate = self
        webSearchBar.text = CocoaDebugSettings.shared.logSearchWordWeb
        webSearchBar.isHidden = true
        //抖动bug
        webTableView.estimatedRowHeight = 0
        webTableView.estimatedSectionHeaderHeight = 0
        webTableView.estimatedSectionFooterHeight = 0
        
        
        
        //segmentedControl
        selectedSegmentIndex = CocoaDebugSettings.shared.logSelectIndex 
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        
        if selectedSegmentIndex == 0 {
            selectedSegment_0 = true
        } else if selectedSegmentIndex == 1 {
            selectedSegment_1 = true
        } else {
            selectedSegment_2 = true
        }
        
        reloadLogs(needScrollToEnd: true, needReloadData: true)
        
        
        
        //hide searchBar icon
        let textFieldInsideSearchBar = defaultSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = .never
        textFieldInsideSearchBar.leftView = nil
        textFieldInsideSearchBar.backgroundColor = .white
        textFieldInsideSearchBar.returnKeyType = .default
        
        let textFieldInsideSearchBar2 = rnSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar2.leftViewMode = .never
        textFieldInsideSearchBar2.leftView = nil
        textFieldInsideSearchBar2.backgroundColor = .white
        textFieldInsideSearchBar2.returnKeyType = .default
        
        let textFieldInsideSearchBar3 = webSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar3.leftViewMode = .never
        textFieldInsideSearchBar3.leftView = nil
        textFieldInsideSearchBar3.backgroundColor = .white
        textFieldInsideSearchBar3.returnKeyType = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultSearchBar.resignFirstResponder()
        rnSearchBar.resignFirstResponder()
        webSearchBar.resignFirstResponder()
    }
    
    deinit {
        //notification
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - target action
    @IBAction func didTapDown(_ sender: Any) {
        if selectedSegmentIndex == 0
        {
            defaultTableView.tableViewScrollToBottom(animated: true)
            defaultSearchBar.resignFirstResponder()
            reachEndDefault = true
        }
        else if selectedSegmentIndex == 1
        {
            rnTableView.tableViewScrollToBottom(animated: true)
            rnSearchBar.resignFirstResponder()
            reachEndRN = true
        }
        else
        {
            webTableView.tableViewScrollToBottom(animated: true)
            webSearchBar.resignFirstResponder()
            reachEndWeb = true
        }
    }
    
    @IBAction func didTapUp(_ sender: Any) {
        if selectedSegmentIndex == 0
        {
            defaultTableView.tableViewScrollToHeader(animated: true)
            defaultSearchBar.resignFirstResponder()
            reachEndDefault = false
        }
        else if selectedSegmentIndex == 1
        {
            rnTableView.tableViewScrollToHeader(animated: true)
            rnSearchBar.resignFirstResponder()
            reachEndRN = false
        }
        else
        {
            webTableView.tableViewScrollToHeader(animated: true)
            webSearchBar.resignFirstResponder()
            reachEndWeb = false
        }
    }
    
    
    @IBAction func resetLogs(_ sender: Any) {
        if selectedSegmentIndex == 0
        {
            defaultModels = []
            defaultCacheModels = []
            //            defaultSearchBar.text = nil
            defaultSearchBar.resignFirstResponder()
            //            CocoaDebugSettings.shared.logSearchWordNormal = nil
            
            _OCLogStoreManager.shared()?.resetNormalLogs()
            
            //            dispatch_main_async_safe { [weak self] in
            self.defaultTableView.reloadData()
            //            }
        }
        else if selectedSegmentIndex == 1
        {
            rnModels = []
            rnCacheModels = []
            //            rnSearchBar.text = nil
            rnSearchBar.resignFirstResponder()
            //            CocoaDebugSettings.shared.logSearchWordRN = nil
            
            _OCLogStoreManager.shared()?.resetRNLogs()
            
            //            dispatch_main_async_safe { [weak self] in
            self.rnTableView.reloadData()
            //            }
        }
        else
        {
            webModels = []
            webCacheModels = []
            //            webSearchBar.text = nil
            webSearchBar.resignFirstResponder()
            //            CocoaDebugSettings.shared.logSearchWordWeb = nil
            
            _OCLogStoreManager.shared().resetWebLogs()
            
            //            dispatch_main_async_safe { [weak self] in
            self.webTableView.reloadData()
            //            }
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        CocoaDebugSettings.shared.logSelectIndex = selectedSegmentIndex
        
        if selectedSegmentIndex == 0 {
            rnSearchBar.resignFirstResponder()
            webSearchBar.resignFirstResponder()
        } else if selectedSegmentIndex == 1 {
            defaultSearchBar.resignFirstResponder()
            webSearchBar.resignFirstResponder()
        } else {
            defaultSearchBar.resignFirstResponder()
            rnSearchBar.resignFirstResponder()
        }
        
        if selectedSegmentIndex == 0 && selectedSegment_0 == false {
            selectedSegment_0 = true
            reloadLogs(needScrollToEnd: true, needReloadData: true)
            return
        }
        
        if selectedSegmentIndex == 1 && selectedSegment_1 == false {
            selectedSegment_1 = true
            reloadLogs(needScrollToEnd: true, needReloadData: true)
            return
        }
        
        if selectedSegmentIndex == 2 && selectedSegment_2 == false {
            selectedSegment_2 = true
            reloadLogs(needScrollToEnd: true, needReloadData: true)
            return
        }
        
        reloadLogs(needScrollToEnd: false, needReloadData: false)
    }
    
    @objc func didTapView() {
        if selectedSegmentIndex == 0 {
            defaultSearchBar.resignFirstResponder()
        } else if selectedSegmentIndex == 1 {
            rnSearchBar.resignFirstResponder()
        } else {
            webSearchBar.resignFirstResponder()
        }
    }
    
    
    //MARK: - notification
    @objc func refreshLogs_notification() {
        if self.selectedSegmentIndex == 0 {
            self.reloadLogs(needScrollToEnd: self.reachEndDefault , needReloadData: true)
        } else if self.selectedSegmentIndex == 1 {
            self.reloadLogs(needScrollToEnd: self.reachEndRN , needReloadData: true)
        } else {
            self.reloadLogs(needScrollToEnd: self.reachEndWeb , needReloadData: true)
        }
    }
}

//MARK: - UITableViewDataSource
extension LogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == defaultTableView {
            return defaultModels.count
        } else if tableView == rnTableView {
            return rnModels.count
        } else {
            return webModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        
        if tableView == defaultTableView
        {
            cell.model = defaultModels[indexPath.row]
        }
        else if tableView == rnTableView
        {
            cell.model = rnModels[indexPath.row]
        }
        else
        {
            cell.model = webModels[indexPath.row]
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension LogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var logTitleString = ""
        var models_: [_OCLogModel]?
        
        if tableView == defaultTableView
        {
            defaultSearchBar.resignFirstResponder()
            reachEndDefault = false
            logTitleString = "Log"
            models_ = defaultModels
        }
        else if tableView == rnTableView
        {
            rnSearchBar.resignFirstResponder()
            reachEndRN = false
            logTitleString = "RN"
            models_ = rnModels
        }
        else
        {
            webSearchBar.resignFirstResponder()
            reachEndWeb = false
            logTitleString = "Web"
            models_ = webModels
        }
        
        //
        guard let models = models_ else {return}
        
        let vc = JsonViewController.instanceFromStoryBoard()
        vc.editType = .log
        vc.logTitleString = logTitleString
        vc.logModels = models
        vc.logModel = models[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
        
        vc.justCancelCallback = {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var model: _OCLogModel
        
        if tableView == defaultTableView {
            model = defaultModels[indexPath.row]
            
        } else if tableView == rnTableView {
            model = rnModels[indexPath.row]
            
        } else {
            model = webModels[indexPath.row]
        }
        
        if let height = model.str?.height(with: UIFont.boldSystemFont(ofSize: 12), constraintToWidth: UIScreen.main.bounds.size.width) {
            return height + 10;
        }
        
        return 0
    }
}

//MARK: - UIScrollViewDelegate
extension LogViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == defaultTableView {
            defaultSearchBar.resignFirstResponder()
            reachEndDefault = false
        } else if scrollView == rnTableView {
            rnSearchBar.resignFirstResponder()
            reachEndRN = false
        } else {
            webSearchBar.resignFirstResponder()
            reachEndWeb = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            //bottom reached
            if scrollView == defaultTableView {
                reachEndDefault = true
            } else if scrollView == rnTableView {
                reachEndRN = true
            } else {
                reachEndWeb = true
            }
        }
    }
}

//MARK: - UISearchBarDelegate
extension LogViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar == defaultSearchBar
        {
            CocoaDebugSettings.shared.logSearchWordNormal = searchText
            searchLogic(searchText)
            
            //            dispatch_main_async_safe { [weak self] in
            self.defaultTableView.reloadData()
            //            }
        }
        else if searchBar == rnSearchBar
        {
            CocoaDebugSettings.shared.logSearchWordRN = searchText
            searchLogic(searchText)
            
            //            dispatch_main_async_safe { [weak self] in
            self.rnTableView.reloadData()
            //            }
        }
        else
        {
            CocoaDebugSettings.shared.logSearchWordWeb = searchText
            searchLogic(searchText)
            
            //            dispatch_main_async_safe { [weak self] in
            self.webTableView.reloadData()
            //            }
        }
    }
}
