//
//  MapRouter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/10/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol MapRoutingLogic {
    func routeToVenues()
    func routeToProfile()
    func routeToAuth()
    func routeToVenueDetails(venue: Venue)
}

protocol MapDataPassing {
    var dataStore: MapDataStore? { get }
}

class MapRouter: NSObject, MapRoutingLogic, MapDataPassing {
    weak var viewController: MapViewController?
    var dataStore: MapDataStore?
    
    // MARK: - Routing
    
    /// Opens List of Venues Screen
    func routeToVenues() {
        if let navigationController = viewController?.navigationController {
            UIView.transition(with: navigationController.view, duration: 0.8, options: .transitionFlipFromLeft, animations: {
                navigationController.popViewController(animated: false)
            }, completion: nil)
        }
    }
    
    /// Opens user profile screen
    func routeToProfile() {
        navigateToProfile(source: viewController!, destination: ProfileViewController.fromStoryboard)
    }
    
    /// Opens Logins screen
    func routeToAuth() {
        viewController!.navigationController!.pushViewController(AuthViewController.fromStoryboard, animated: true)
    }
    
    /// Opens Venue Details Screen
    ///
    /// - Parameter venue: venue to open
    func routeToVenueDetails(venue: Venue) {
        let destinationVC = VenueDetailsViewController.fromStoryboard
        var destinationDS = destinationVC.router!.dataStore!
        destinationDS.venue = venue
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    // MARK: - Navigation
    
    func navigateToProfile(source: MapViewController, destination: ProfileViewController) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
    
}
