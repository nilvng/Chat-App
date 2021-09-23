//
//  SearchViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {

    lazy var searchBar :UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 65))
    

    var currentSearchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        searchBar.placeholder = "Search"
//        searchBar.backgroundColor  = .white
//
//        self.navigationItem.backButtonDisplayMode = .minimal
//        self.navigationItem.titleView = searchBar
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search artists"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        self.currentSearchText = searchText
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
