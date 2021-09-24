//
//  SearchViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class CustomSearchController : UIViewController {

 //   lazy var searchBar :UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 65))
    
    lazy var searchField : UITextField = {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
        return field
    }()
    
    var resultTableView : UITableView = {
        let view = UITableView()
        return view
    }()
    
    var currentSearchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        searchBar.placeholder = "Search"
//        searchBar.searchBarStyle = .minimal
//        searchBar.isTranslucent = false
//        searchBar.backgroundImage = UIImage()
//        searchBar.barTintColor  = .white

        self.navigationItem.backButtonDisplayMode = .minimal
//        self.navigationItem.titleView = searchBar
        self.navigationItem.titleView = searchField
        searchField.backgroundColor = .white
        searchField.tintColor = .black
        
        view.addSubview(resultTableView)
        resultTableView.frame = view.bounds
    } 


}
