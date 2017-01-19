//
//  SearchViewController.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography
import NVActivityIndicatorView

protocol SearchViewControllerDataSource {
    weak var delegate: SearchViewControllerDelegate? { get set }
    
    func numberOfSection(in tableView: UITableView) -> Int
    func numberOfRows(in section: Int, tableView: UITableView) -> Int
    func cellForRow(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    
    //If you return nil then no section header is displayed
    func title(for section: Int) -> String?
    
    func didUpdateSearch(text: String)
    func didTapCell(at indexPath: IndexPath, controller: SearchViewController)
}

protocol SearchViewControllerDelegate: class {
    func showIndicator()
    func hideIndicator()
    func reloadTableView()
    func reloadTableView<T: Collection>(oldData: T, newData: T) where T.Iterator.Element: Equatable
}

//A view controller for searching kitsu
class SearchViewController: UIViewController {
    
    enum Scope: String {
        case anime = "Anime"
        case manga = "Manga"
        static let all: [Scope] = [.anime, .manga]
    }
    
    //The initial scope to start on
    var initialScope: Scope
    
    //The current scope
    var currentScope: Scope? = nil
    
    //A dictionary of data sources
    var sources: [Scope: SearchViewControllerDataSource] = [:]
    
    //The data source of the search
    var dataSource: SearchViewControllerDataSource? {
        
        willSet {
            dataSource?.delegate = nil
        }
        
        didSet {
            dataSource?.delegate = self
            tableView.reloadData()
        }
    }
    
    //The tableview for showing results
    lazy var tableView: UITableView = {
        let t = UITableView()
        
        t.alwaysBounceVertical = true
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        t.delegate = self
        t.dataSource = self
        
        t.tintColor = Theme.EntryView().tintColor
        
        //Set the footer view so we don't get extra seperators
        t.tableFooterView = UIView(frame: .zero)
        
        //Disable default reading margins
        t.cellLayoutMarginsFollowReadableWidth = false
        
        return t
    }()
    
    //The activity indicator
    var activityIndicator: NVActivityIndicatorView = {
        let theme = Theme.ActivityIndicatorTheme()
        return theme.view()
    }()
    
    //The search bar to search in
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        
        s.scopeButtonTitles = Scope.all.map { $0.rawValue }
        s.barTintColor = Theme.NavigationTheme().barColor
        s.tintColor = UIColor.white
        s.delegate = self
        s.showsCancelButton = true
        s.showsScopeBar = true
        s.placeholder = "Enter your search"
        
        //Change the tint color of the cursor
        for subView in s.subviews[0].subviews where subView is UITextField {
            subView.tintColor = Theme.Colors().secondary
        }
        
        return s
    }()
    
    //A view to put behind the status bar so that search bar doesn't overlap it
    var statusView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.NavigationTheme().barColor
        return v
    }()
    
    //The height constraint we modify on layout change
    var statusViewHeight: NSLayoutConstraint?
    
    /// Create a search view controller with an initial scope
    ///
    /// - Parameter scope: The starting scope
    init(scope: Scope = .anime) {
        self.initialScope = scope
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init() instead")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView(arrangedSubviews: [statusView, searchBar, tableView])
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        //Add the views
        self.view.addSubview(stackView)
        constrain(stackView, statusView, searchBar) { stack, status, bar in
            stack.edges == stack.superview!.edges
            
            statusViewHeight = (status.height == UIApplication.shared.statusBarFrame.height)
            bar.height >= 40 ~ LayoutPriority(999)
        }
        
        //Add the indicator
        let size = Theme.ActivityIndicatorTheme().size
        
        self.view.addSubview(activityIndicator)
        constrain(activityIndicator, tableView) { view, table in
            view.center == table.center
            view.width == size.width
            view.height == size.height
        }
        
        //Set the sources
        sources[.anime] = SearchAnimeDataSource(parent: tableView)
        sources[.manga] = SearchMangaDataSource(parent: tableView)
        
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        
        //Update search bar to reflect the scope
        let index = Scope.all.index(of: initialScope) ?? 0
        searchBar.selectedScopeButtonIndex = index
        searchBar(searchBar, selectedScopeButtonIndexDidChange: index)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusViewHeight?.constant = UIApplication.shared.statusBarFrame.height
    }
}

//MARK:- Table Datasource
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSection(in: tableView) ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfRows(in: section, tableView: tableView) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = dataSource?.cellForRow(at: indexPath, tableView: tableView) {
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource?.heightForRow(at: indexPath) ?? 44
    }
}

//MARK:- Table Delegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource?.didTapCell(at: indexPath, controller: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Set the title if we have it, else just return nil
        if let title = dataSource?.title(for: section) {
            let view = TitleTableSectionView()
            view.titleLabel.text = title
            return view
        }
        
        return nil
    }
    
    //Only show header if we have a title
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource?.title(for: section) == nil ? 0 : 35
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
}

//MARK:- Search
extension SearchViewController: UISearchBarDelegate {
    
    func setScope(scope: Scope) {
        currentScope = scope
        dataSource = sources[currentScope!] ?? nil
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = Scope.all[selectedScope]
        if currentScope != scope {
            setScope(scope: scope)
            dataSource?.didUpdateSearch(text: searchBar.text ?? "")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource?.didUpdateSearch(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }
}

//MARK:- Delegate
extension SearchViewController: SearchViewControllerDelegate {
    func showIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func reloadTableView<T: Collection>(oldData: T, newData: T) where T.Iterator.Element: Equatable {
        tableView.animateRowChanges(oldData: oldData, newData: newData)
    }
}
