//
//  LocationSearchTable.swift
//  myNursingSpots
//
//  Created by Darko Kulakov on 2019-07-04.
//  Copyright © 2019 Elena Kulakova. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil

}

extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.search(_:)), object: searchController)
        perform(#selector(self.search(_:)), with: searchController, afterDelay: 0.75)

    }
    
    @objc func search(_ searchController: UISearchController) {
                guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = searchBarText
                request.region = mapView.region
        
                DispatchQueue.main.async {
                    //Use the network activity indicator as a hint to the user that a search is in progress
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
        
                let search = MKLocalSearch(request: request)
                search.start { (response, error) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        guard let response = response else { return }
                        self.matchingItems = response.mapItems
                        self.tableView.reloadData()
                    }
                }
    }
}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.parseAddress()
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.didSelectResult(placemark: selectedItem)
        dismiss(animated: true)
    }
}
