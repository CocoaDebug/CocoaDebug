//
//  ToJSONViewController.swift
//  PhiHome
//
//  Created by liman on 09/12/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

enum EditType {
    case unknown
    case request
    case header
}

import Foundation
import UIKit

class ToJSONViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    
//    let keyboardMan = KeyboardMan()
//    private var button: UIButton?
    
    var editType: EditType  = .unknown
    var httpModel: JxbHttpModel?
    var detailModel: NetworkDetailModel?
    
    //编辑过的url
    var editedURLString: String?
    //编辑过的content (request/header)
    var editedContent: String?
    
    static func instanceFromStoryBoard() -> ToJSONViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: DebugMan.self))
        return storyboard.instantiateViewController(withIdentifier: "ToJSONViewController") as! ToJSONViewController
    }
    
    //MARK: - tool
    
    //确定格式(JSON/Form)
    func detectSerializer() {
        guard let content = detailModel?.content else {
            detailModel?.requestSerializer = JSONRequestSerializer//默认JSON格式
            return
        }
        
        if let _ = content.stringToDictionary() {
            //JSON格式
            detailModel?.requestSerializer = JSONRequestSerializer
            segmentedControl.selectedSegmentIndex = 0
        }else{
            //Form格式
            detailModel?.requestSerializer = FormRequestSerializer
            segmentedControl.selectedSegmentIndex = 1
        }
    }
    
    //show button
//    private func initButton(_ infoHeight: CGFloat) {
//        if button == nil {
//            button = UIButton.init(frame: CGRect(x:UIScreen.main.bounds.width-74,y:UIScreen.main.bounds.height,width:74,height:38))
//            button?.backgroundColor = UIColor.white
//            button?.setTitle("Hide", for: .normal)
//            button?.setTitleColor(UIColor.black, for: .normal)
//            button?.addCorner(roundingCorners: UIRectCorner(rawValue: UIRectCorner.RawValue(UInt8(UIRectCorner.topLeft.rawValue) | UInt8(UIRectCorner.topRight.rawValue))), cornerSize: CGSize(width:4,height:4))
//            button?.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
//
//            guard let button = button else {return}
//            DotzuManager.shared.window.addSubview(button)
//        }
//
//        UIView.animate(withDuration: 0.35) { [weak self] in
//            self?.button?.frame.origin.y = UIScreen.main.bounds.height-infoHeight-38
//        }
//    }
    
    //hide button
//    private func deInitButton(_ infoHeight: CGFloat) {
//        UIView.animate(withDuration: 0.35, animations: { [weak self] in
//            self?.button?.frame.origin.y = UIScreen.main.bounds.height
//        }) { [weak self] _ in
//            self?.button?.removeFromSuperview()
//            self?.button = nil
//        }
//    }
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = tableHeaderView
        textView.delegate = self
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        
        self.title = detailModel?.title
        
        //判断类型 (默认类型URL)
        if detailModel?.title == "REQUEST" {
            editType = .request
        }
        if detailModel?.title == "HEADER" {
            editType = .header
        }
        
        //设置UI
        if editType == .request
        {
            tableView.tableHeaderView?.frame.size.height = 28
            tableView.tableHeaderView?.isHidden = false
            textView.text = detailModel?.content
            detectSerializer()//确定格式(JSON/Form)
        }
        else if editType == .header
        {
            tableView.tableHeaderView?.frame.size.height = 0
            tableView.tableHeaderView?.isHidden = true
            textView.text = detailModel?.headerFields?.dictionaryToString()
        }
        else
        {
            tableView.tableHeaderView?.frame.size.height = 0
            tableView.tableHeaderView?.isHidden = true
            textView.text = detailModel?.content
            detectSerializer()//确定格式(JSON/Form)
        }
        
        //键盘
//        keyboardMan.postKeyboardInfo = { [weak self] keyboardMan, keyboardInfo in
//            switch keyboardInfo.action {
//            case .show:
//                self?.initButton(keyboardInfo.height)
//            case .hide:
//                self?.deInitButton(keyboardInfo.height)
//            }
//        }
    }
    
    
    //MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView)
    {
        tableView.beginUpdates()
        tableView.endUpdates()

        editedContent = textView.text
        detailModel?.content = textView.text
    }
    

    //MARK: - target action
    
    //能点击segmentedControl, 说明一定是在编辑request
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        guard let requestSerializer = detailModel?.requestSerializer, let textView = textView else {return}
        
        
        if requestSerializer == JSONRequestSerializer {//原格式为JSON
            if sender.selectedSegmentIndex == 1 {//转换为Form
                
                if let formString = detailModel?.content?.jsonStringToFormString() {
                    textView.text = formString
                    self.textViewDidChange(textView)
                    detailModel?.requestSerializer = FormRequestSerializer
                    detailModel?.content = textView.text
                }else{
                    sender.selectedSegmentIndex = 0
                    UIAlertController.showError(title: "Format is illegal", controller: self)
                    return
                }
            }
        }
        
        
        if requestSerializer == FormRequestSerializer {//原格式为Form
            if sender.selectedSegmentIndex == 0 {//转换为JSON
                
                if let jsonString = detailModel?.content?.formStringToJsonString() {
                    textView.text = jsonString
                    self.textViewDidChange(textView)
                    detailModel?.requestSerializer = JSONRequestSerializer
                    detailModel?.content = textView.text
                }else{
                    sender.selectedSegmentIndex = 1
                    UIAlertController.showError(title: "Format is illegal", controller: self)
                    return
                }
            }
        }
    }
}
