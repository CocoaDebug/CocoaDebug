//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    var reachEndDefault: Bool = true
    var reachEndColor: Bool = true
    
    var firstInDefault: Bool = true
    var firstInColor: Bool = true
    
    var selectedSegmentIndex: Int = 0
    var selectedSegment_0: Bool = false
    var selectedSegment_1: Bool = false
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    
    @IBOutlet weak var defaultTableView: UITableView!
    @IBOutlet weak var defaultSearchBar: UISearchBar!
    lazy var defaultModels: [LogModel] = [LogModel]()
    var defaultCacheModels: Array<LogModel>?
    var defaultSearchModels: Array<LogModel>?
    
    @IBOutlet weak var colorTableView: UITableView!
    @IBOutlet weak var colorSearchBar: UISearchBar!
    lazy var colorModels: [LogModel] = [LogModel]()
    var colorCacheModels: Array<LogModel>?
    var colorSearchModels: Array<LogModel>?
    
    
    
    //MARK: - tool
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        
        if selectedSegmentIndex == 0
        {
            guard let defaultCacheModels = defaultCacheModels else {return}
            defaultSearchModels = defaultCacheModels
            
            if searchText == "" {
                defaultModels = defaultCacheModels
            }else{
                guard let defaultSearchModels = defaultSearchModels else {return}
                
                for _ in defaultSearchModels {
                    if let index = self.defaultSearchModels?.index(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.defaultSearchModels?.remove(at: index)
                    }
                }
                defaultModels = self.defaultSearchModels ?? []
            }
        }
        else
        {
            guard let colorCacheModels = colorCacheModels else {return}
            colorSearchModels = colorCacheModels
            
            if searchText == "" {
                colorModels = colorCacheModels
            }else{
                guard let colorSearchModels = colorSearchModels else {return}
                
                for _ in colorSearchModels {
                    if let index = self.colorSearchModels?.index(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.colorSearchModels?.remove(at: index)
                    }
                }
                colorModels = self.colorSearchModels ?? []
            }
        }
    }
    
    //MARK: - private
    func reloadLogs(needScrollToEnd: Bool = false, needReloadData: Bool = true) {
        
        if selectedSegmentIndex == 0
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) { [weak self] in
                if self?.defaultSearchBar.isHidden == true {
                    self?.defaultSearchBar.isHidden = false
                }
            }
            
            
            defaultTableView.isHidden = false
            colorTableView.isHidden = true
            
            if needReloadData == false && defaultModels.count > 0 {return}
            
            defaultModels = LogStoreManager.shared.defaultLogArray
            
            self.defaultCacheModels = self.defaultModels
            
            self.searchLogic(CocoaDebugSettings.shared.logSearchWordDefault ?? "")
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
                
                if needScrollToEnd == false {return}
                
                //table下滑到底部
                guard let count = self?.defaultModels.count else {return}
                if count > 0 {
                    guard let firstInDefault = self?.firstInDefault else {return}
                    self?.defaultTableView.tableViewScrollToBottom(animated: !firstInDefault)
                    self?.firstInDefault = false
                }
            }
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) { [weak self] in
                if self?.colorSearchBar.isHidden == true {
                    self?.colorSearchBar.isHidden = false
                }
            }
            
            
            defaultTableView.isHidden = true
            colorTableView.isHidden = false
            
            if needReloadData == false && colorModels.count > 0 {return}
            
            colorModels = LogStoreManager.shared.colorLogArray
            
            self.colorCacheModels = self.colorModels
            
            self.searchLogic(CocoaDebugSettings.shared.logSearchWordColor ?? "")
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
                
                if needScrollToEnd == false {return}
                
                //table下滑到底部
                guard let count = self?.colorModels.count else {return}
                if count > 0 {
                    guard let firstInColor = self?.firstInColor else {return}
                    self?.colorTableView.tableViewScrollToBottom(animated: !firstInColor)
                    self?.firstInColor = false
                }
            }
        }
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.tintColor = Color.mainGreen
        deleteItem.tintColor = Color.mainGreen
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLogs_notification), name: NSNotification.Name("refreshLogs_CocoaDebug"), object: nil)
        
        defaultTableView.tableFooterView = UIView()
        defaultTableView.delegate = self
        defaultTableView.dataSource = self
//        defaultTableView.rowHeight = UITableViewAutomaticDimension
        defaultSearchBar.delegate = self
        defaultSearchBar.text = CocoaDebugSettings.shared.logSearchWordDefault
        defaultSearchBar.isHidden = true
        
        colorTableView.tableFooterView = UIView()
        colorTableView.delegate = self
        colorTableView.dataSource = self
//        colorTableView.rowHeight = UITableViewAutomaticDimension
        colorSearchBar.delegate = self
        colorSearchBar.text = CocoaDebugSettings.shared.logSearchWordColor
        colorSearchBar.isHidden = true
        
        //segmentedControl
        selectedSegmentIndex = CocoaDebugSettings.shared.logSelectIndex 
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        
        if selectedSegmentIndex == 0 {
            selectedSegment_0 = true
        }else{
            selectedSegment_1 = true
        }
        
        reloadLogs(needScrollToEnd: true, needReloadData: true)

        //hide searchBar icon
        let textFieldInsideSearchBar = defaultSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        let textFieldInsideSearchBar2 = colorSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar2.leftViewMode = UITextFieldViewMode.never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultSearchBar.resignFirstResponder()
        colorSearchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    
    

    
    //MARK: - target action
    @IBAction func resetLogs(_ sender: Any) {
        
        if selectedSegmentIndex == 0
        {
            defaultModels = []
            defaultCacheModels = []
            defaultSearchBar.text = nil
            defaultSearchBar.resignFirstResponder()
            CocoaDebugSettings.shared.logSearchWordDefault = nil
            
            LogStoreManager.shared.resetDefaultLogs()
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
            }
        }
        else
        {
            colorModels = []
            colorCacheModels = []
            colorSearchBar.text = nil
            colorSearchBar.resignFirstResponder()
            CocoaDebugSettings.shared.logSearchWordColor = nil
            
            LogStoreManager.shared.resetColorLogs()
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
            }
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        CocoaDebugSettings.shared.logSelectIndex = selectedSegmentIndex
        
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
        
        reloadLogs(needScrollToEnd: false, needReloadData: false)
    }
    
    
    //MARK: - notification
    @objc func refreshLogs_notification() {
        
        if selectedSegmentIndex == 0 {
            reloadLogs(needScrollToEnd: reachEndDefault, needReloadData: true)
        }else{
            reloadLogs(needScrollToEnd: reachEndColor, needReloadData: true)
        }
    }
}

//MARK: - UITableViewDataSource
extension LogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == defaultTableView {
            return defaultModels.count
        }else{
            return colorModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == defaultTableView {
            //否则偶尔crash
            if indexPath.row >= defaultModels.count {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
                as! LogCell
            cell.model = defaultModels[indexPath.row]
            return cell
        }else{
            //否则偶尔crash
            if indexPath.row >= colorModels.count {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
                as! LogCell
            cell.model = colorModels[indexPath.row]
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension LogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var model: LogModel
        
        if tableView == defaultTableView {
            model = defaultModels[indexPath.row]
        }else{
            model = colorModels[indexPath.row]
        }
        
        
        if let height = model.str?.height(with: UIFont.boldSystemFont(ofSize: 12), constraintToWidth: UIScreen.main.bounds.size.width) {
            return (height + 34) > 5000 ? 5000 : (height + 34)
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == defaultTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            defaultSearchBar.resignFirstResponder()
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
            colorSearchBar.resignFirstResponder()
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == defaultTableView {
            let model = defaultModels[indexPath.row]
            var title = "Tag"
            if model.isTag == true {title = "UnTag"}
            
            let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
                model.isTag = !model.isTag
                self?.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.reloadData()
                }
                completionHandler(true)
            }
            
            defaultSearchBar.resignFirstResponder()
            left.backgroundColor = "#007aff".hexColor
            return UISwipeActionsConfiguration(actions: [left])
        }else{
            let model = colorModels[indexPath.row]
            var title = "Tag"
            if model.isTag == true {title = "UnTag"}
            
            let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
                model.isTag = !model.isTag
                self?.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.reloadData()
                }
                completionHandler(true)
            }
            
            colorSearchBar.resignFirstResponder()
            left.backgroundColor = "#007aff".hexColor
            return UISwipeActionsConfiguration(actions: [left])
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == defaultTableView {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
                guard let models = self?.defaultModels else {return}
                LogStoreManager.shared.removeLog(models[indexPath.row])
                self?.defaultModels.remove(at: indexPath.row)
                self?.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            defaultSearchBar.resignFirstResponder()
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
                guard let models = self?.colorModels else {return}
                LogStoreManager.shared.removeLog(models[indexPath.row])
                self?.colorModels.remove(at: indexPath.row)
                self?.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            colorSearchBar.resignFirstResponder()
            return UISwipeActionsConfiguration(actions: [delete])
        }
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
        if tableView == defaultTableView {
            if (editingStyle == .delete) {
                LogStoreManager.shared.removeLog(defaultModels[indexPath.row])
                self.defaultModels.remove(at: indexPath.row)
                self.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }else{
            if (editingStyle == .delete) {
                LogStoreManager.shared.removeLog(colorModels[indexPath.row])
                self.colorModels.remove(at: indexPath.row)
                self.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}

//MARK: - UIScrollViewDelegate
extension LogViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == defaultTableView
        {
            defaultSearchBar.resignFirstResponder()
            
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                //you reached end of the table default
                reachEndDefault = true
            }else{
                reachEndDefault = false
            }
        }
        else
        {
            colorSearchBar.resignFirstResponder()
            
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                //you reached end of the table color
                reachEndColor = true
            }else{
                reachEndColor = false
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
        if searchBar == defaultSearchBar {
            CocoaDebugSettings.shared.logSearchWordDefault = searchText
            searchLogic(searchText)
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
            }
        }else{
            CocoaDebugSettings.shared.logSearchWordColor = searchText
            searchLogic(searchText)
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
            }
        }
    }
}
