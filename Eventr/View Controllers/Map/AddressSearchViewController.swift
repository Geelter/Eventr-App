//
//  AddressSearchViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 15/10/2021.
//

import UIKit
import MapKit

class AddressSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTable: UITableView!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var address: Address?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
        searchBar.delegate = self
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
    }
    
    func getAddress(from placemark: MKPlacemark) {
        address = Address(from: placemark)
    }
}

extension AddressSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
        searchResultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle errors from completer
    }
}

extension AddressSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

extension AddressSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let placemark = response?.mapItems.first?.placemark else {return}
            
            self.getAddress(from: placemark)
            
            self.performSegue(withIdentifier: K.Segues.unwindToMap, sender: self)
        }
    }
}

extension AddressSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        
        return cell
    }
}
