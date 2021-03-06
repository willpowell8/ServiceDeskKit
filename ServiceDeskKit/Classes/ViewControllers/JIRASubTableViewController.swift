//
//  JIRASubTableViewController.swift
//  Pods
//
//  Created by Will Powell on 31/08/2017.
//
//

///rest/api/1.0/jql/autocomplete?fieldName=Sprint&fieldValue=test

import UIKit
import MBProgressHUD

protocol JIRASubTableViewControllerDelegate {
    func jiraSelected(field:ServiceDeskRequestField?, item:Any?)
}

class JIRASubTableViewController: UITableViewController {
    
    var delegate:JIRASubTableViewControllerDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    var field:ServiceDeskRequestField? {
        didSet{
            if let f = field {
                self.navigationItem.title = f.name
            }
            apply()
        }
    }
    var selectedFields = [DisplayClass]()
    var selectedField:DisplayClass?
    
    var elements = [DisplayClass]() {
        didSet{
            elementsFiltered = elements
            if elements.count > 5 {
                tableView.tableHeaderView = searchController.searchBar
            }else{
                tableView.tableHeaderView = nil
            }
        }
    }
    var elementsFiltered = [DisplayClass]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func applyData(data:[AnyHashable:Any]){
        if let identifier = field?.fieldId {
           if let selected = data[identifier] as? DisplayClass {
                self.selectedField = selected
            }
        }
        self.tableView.reloadData()
    }
    
    
    func apply(){
        guard let v = field?.validValues else{
            return
        }
        elements = v
    }
    
    @objc func done(){
        //delegate?.jiraSelected(field:self.field, item: selectedFields)
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementsFiltered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var element:DisplayClass?
        element = elementsFiltered[indexPath.row]
        cell.textLabel?.text = element?.label
        if let selectedElementLabel = selectedField?.label, selectedElementLabel == element?.label {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        applySelectionToggle(tableView, didSelectRowAt: indexPath)
    }
    
    func applySelectionToggle(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let element = elementsFiltered[indexPath.row]
        if let serviceRequestField = element as? ServiceDeskRequestFieldValue, let children = serviceRequestField.children, children.count > 0 {
            let v = JIRASubTableViewController()
            v.field = self.field
            v.elements = children
            v.delegate = self.delegate
            navigationController?.pushViewController(v, animated: true)
            return
        }
        delegate?.jiraSelected(field:self.field, item: element)
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        applySelectionToggle(tableView, didSelectRowAt: indexPath)
    }

}

extension JIRASubTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.characters.count > 0 {
            elementsFiltered = elements.filter({ (display) -> Bool in
                if let label = display.label {
                    return label.contains(text)
                }
                return false
            })
        }else{
            elementsFiltered = elements
        }
    }
}

extension JIRASubTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, let field = self.field else {
            return
        }
        
    }
}
