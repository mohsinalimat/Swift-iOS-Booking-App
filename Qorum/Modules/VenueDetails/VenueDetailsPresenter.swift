//
//  VenueDetailsPresenter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/16/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol VenueDetailsPresentationLogic: AnyObject {
    
    /// Asks the view controller to open the `Bill` scene as a result of tab opening request.
    ///
    /// - Parameter response: The tab opening request response, which is expected to be successful.
    func presentCheckin(response: VenueDetails.CheckIn.Response)
    
    /// Asks the view controller to notify user
    /// about tab opening request failure details.
    ///
    /// - Parameter response: The tab opening request failure details.
    func presentCheckinError(response: VenueDetails.CheckIn.Response)
    
    /// Asks the view controller to notify user
    /// about preconditions failure details on attempt to open a tab.
    ///
    /// - Parameter response: The preconditions failure details.
    func presentPreconditionsError(response: VenueDetails.Preconditions)
    
    /// Asks the view controller to start opening a tab.
    func presentPreconditionsSuccess()
    
    /// Asks the view controller to present given overlay.
    ///
    /// - Parameter overlay: overlay to present
    func presentOverlay(_ overlay: VenueDetails.Overlay)
    
    /// Asks view controller to update its UI after checkins loading.
    /// The checkins loading happens after user login.
    func presentLoadedCheckins()
    
}

/// The presenter for the Venue Details scene.
class VenueDetailsPresenter: VenueDetailsPresentationLogic {
    
    /// The `weak` (to avoid a retain cycle) pointer to the view controller
    weak var viewController: VenueDetailsDisplayLogic?
    
    // MARK: - Preconditions
    
    func presentPreconditionsSuccess() {
        viewController?.displayPreconditionsSuccess()
    }
    
    func presentPreconditionsError(response: VenueDetails.Preconditions) {
        viewController?.displayPreconditionsError(viewModel: response)
    }
    
    // MARK: - Checkin
    
    func presentCheckin(response: VenueDetails.CheckIn.Response) {
        var message: String? = nil
        if response.checkin?.uberDiscountValue == .none && AppDelegate.shared.freeRideCheckinsHash.isEmpty {
            message = "Free ride is unavailable"
        }
        let viewModel = VenueDetails.CheckIn.ViewModel(checkin: response.checkin,
                                                       warning: message,
                                                       checkinError: nil)
        viewController?.displayCheckin(viewModel: viewModel)
    }
    
    func presentCheckinError(response: VenueDetails.CheckIn.Response) {
        let viewModel = VenueDetails.CheckIn.ViewModel(checkin: nil,
                                                       warning: nil,
                                                       checkinError: response.checkinError)
        viewController?.displayCheckinError(viewModel: viewModel)
    }
    
    func presentOverlay(_ overlay: VenueDetails.Overlay) {
        viewController?.displayOverlay(overlay)
    }
    
    func presentLoadedCheckins() {
        viewController?.displayLoadedCheckins()
    }
    
}

// MARK: - AuthPresentationLogic
extension VenueDetailsPresenter: AuthPresentationLogic {
    
    func present(response: Auth.Response) {
        switch response {
        case .mayOpenVenues:
            viewController?.displayLoggedInUser()
        case .userOfIllegalAge:
            viewController?.displayAgeAlert()
        case let .error(error):
            print("AuthPresenter error: \(error)")
        }
    }
    
    func presentLoader() {
        viewController?.showLoader()
    }
    
    func presentLoginLoader() {
        viewController?.showLoader("Logging in")
    }
    
    func hideLoader() {
        viewController?.hideLoader()
    }
    
}

