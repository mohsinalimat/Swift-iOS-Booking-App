//
//  BillPresenter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/30/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import UserNotifications

protocol BillPresentationLogic: AnyObject {
    
    /// Presents Bill data
    ///
    /// - Parameter response: bill response
    func presentBill(response: BillModels.Bill.Response)
    
    /// Presents checkout flow
    ///
    /// - Parameter response: checkout response
    func presentCheckout(response: BillModels.CheckOut.Response)
    
    /// Presents Tips update flow
    ///
    /// - Parameter response: tips response
    func presentGratuity(response: BillModels.Gratuity.Response)
    
    /// Presents Uber free ride state
    ///
    /// - Parameter checkin: checkin model
    func presentRidesafe(for checkin: Checkin)
    
    /// Presents alert if ridesafe was previously revealed
    ///
    /// - Parameter ridesafeTimeMinutes: time waiting for free uber (only for alert's body)
    func presentUnusedRidesafeAlert(ridesafeTimeMinutes: Int)
}

class BillPresenter {
    
    weak var viewController: BillDisplayLogic?
    
    // MARK: - Alerts
    
    static func displayClosingEmptyTabAlert() {
        let message = "Looks like you didn't order anything. If you want to close out your tab, please see the bartender."
        UIAlertController.presentAsAlert(title: "Whoops!",
                                         message: message,
                                         actions: ([("Got it", .cancel, nil)]))
    }
    
    func displayNotEnoughAmountToCharge() {
        guard viewController?.paymentFailureAlert == .none else { return }
        let title = """
        In order to pay through the Qorum app and redeem your discounts, your tab total must be above $0.50.
        """
        let message = """
        Reminder: If you pay with cash, you'll miss out on Qorum drink discounts.
        """
        viewController?.paymentFailureAlert = UIAlertController.presentAsAlert(title: title, message: message, actions:
            [("Pay with Cash", .destructive, { [weak self] in self?.displayNotEnoughAmountToChargeCashConfirmation() }),
             ("Keep Tab Open", .cancel, .none)])
    }
    
    func displayNotEnoughAmountToChargeCashConfirmation() {
        let title = """
        You've selected to pay with cash. Please see the bartender to close out your tab.
        """
        let message = """
        Reminder: If you pay with cash, you'll miss out on Qorum drink discounts.
        """
        viewController?.paymentFailureAlert = UIAlertController.presentAsAlert(title: title, message: message, actions:
            [("Keep Tab Open", .cancel, .none),
             ("Got it", .destructive, { [weak self] in self?.displayCashPending() })])
    }
    
    func displayNoEnoughCredits() {
        guard viewController?.paymentFailureAlert == .none else { return }
        let title = """
        Oops... It appears your default payment card has insufficient funds to pay your order.
        """
        let message = """
        Please change your default payment card or settle your tab at the bar.
        """
        viewController?.paymentFailureAlert = UIAlertController.presentAsAlert(title: title, message: message, actions:
            [("Pay with Cash", .destructive, { [weak self] in self?.displayNoEnoughCreditsCashConfirmation() }),
             ("Change Card", .cancel, { [weak viewController] in viewController?.routeToPayments() })])
    }
    
    func displayNoEnoughCreditsCashConfirmation() {
        let title = """
        You’ve selected to pay with cash. Please see the bartender to close out your tab.
        """
        let message = """
        Reminder: If you pay with cash, you’ll miss out on Qorum drink discount. To redeem your drink doscounts, update your card in the app now.
        """
        viewController?.paymentFailureAlert = UIAlertController.presentAsAlert(title: title, message: message, actions:
            [("Change Card", .cancel, { [weak viewController] in viewController?.routeToPayments() }),
             ("Continue with Cash", .destructive, { [weak self] in self?.displayCashPending() })])
    }
    
    func displayCashPending() {
        let title = """
        You've selected to pay with cash.
        """
        let message = """
        You've decided to close your tab with cash. Please see the bartender to settle your tab.
        """
        viewController?.paymentFailureAlert = UIAlertController
            .presentAsAlert(title: title,
                            message: message,
                            actions: .noActions)
    }
    
    func displayPOSError(title: String, message: String) {
        if UIApplication.shared.applicationState != .active {
            let identifier = QorumPushIdentifier.checkoutError.rawValue
            let content = UNMutableNotificationContent.create(with: title, body: message)
            VenueTrackerNotifier.showNotification(with: identifier, content: content)
        } else {
            UIAlertController.presentAsAlert(title: title,
                                             message: message,
                                             actions: [("Got It", .cancel, nil)])
        }
    }
    
    // MARK: - ViewModels
    
    func billViewModel(from response: BillModels.Bill.Response) -> BillModels.Bill.ViewModel {
        switch response {
        case let .value(checkin):
            return .success(checkin)
        case let .error(error):
            guard viewController?.isVisible ?? false else {
                // do nothing here, just skip
                return .alertDisplayed
            }
            guard let genericError = error as? GenericError else {
                return .alert(title: "Cannot update tab", message: error.message)
            }
            switch genericError.status {
            case 402:
                displayNoEnoughCredits()
                return .alertDisplayed
            case 409:
                guard let errorCode = CheckinPOSError(rawValue: genericError.code) else {
                    // TODO: - need to confirm with @tetiana
//                    let message = "We were unable to refresh your tab because terminal is not responding. Please try again later or ask the bartender."
                    let message = "We were unable to refresh your tab because the bartender is currently updating it. Please try again later or ask the bartender directly."
                    return .alert(title: "Something went wrong!", message: message)
                }
                if errorCode == .TAB_TICKET_CLOSED_EMPTY {
                    return .autoClosed
                }
                displayPOSError(title: "Ooops!", message: errorCode.message)
                return .alertDisplayed
            case 500:
                let message = "We were unable to refresh your tab because terminal is not responding. Please try again later or ask the bartender."
                return .alert(title: "Something went wrong!", message: message)
            default:
                return .alert(title: "Cannot update tab", message: genericError.title)
            }
        }
    }
    
    func checkOutViewModel(from response: BillModels.CheckOut.Response) -> BillModels.CheckOut.ViewModel {
        switch response {
        case let .success(checkin):
            return .success(checkin)
        case let .error(error):
            guard viewController?.isVisible ?? false else {
                // do nothing here, just skip
                return .alertDisplayed
            }
            guard let genericError = error as? GenericError else {
                return .alert(title: "Cannot close tab", message: error.message)
            }
            switch genericError.status {
            case 402:
                switch genericError.code {
                case "1001":
                    displayNotEnoughAmountToCharge()
                    return .alertDisplayed
                case "1":
                    displayNoEnoughCredits()
                    return .alertDisplayed
                default:
                    break
                }
            case 409:
                if let errorCode = CheckinPOSError(rawValue: genericError.code) {
                    displayPOSError(title: "Ooops!", message: errorCode.message)
                    return .alertDisplayed
                } else {
                    let message = "We were unable to close your tab because the bartender is currently updating it. Please try again later or ask the bartender directly."
                    return .alert(title: "Something went wrong!", message: message)
                }
            case 500:
                let message = "We were unable to close your tab because terminal is not responding. Please try again later or ask the bartender directly."
                return .alert(title: "Something went wrong!", message: message)
            default:
                break
            }
            return .alert(title: "Cannot close tab", message: genericError.title)
        case .emptyTab(_):
            BillPresenter.displayClosingEmptyTabAlert()
            return .alertDisplayed
        }
    }
    
}

// MARK: - BillPresentationLogic
extension BillPresenter:  BillPresentationLogic {
    
    func presentBill(response: BillModels.Bill.Response) {
        let viewModel = billViewModel(from: response)
        viewController?.displayBill(viewModel: viewModel)
    }
    
    func presentCheckout(response: BillModels.CheckOut.Response) {
        let viewModel = checkOutViewModel(from: response)
        viewController?.displayCheckOut(viewModel: viewModel)
    }
    
    func presentGratuity(response: BillModels.Gratuity.Response) {
        let viewModel: BillModels.Gratuity.ViewModel
        switch response {
        case .value:
            viewModel = .success
        case let .error(error):
            debugPrint(error)
            guard viewController?.isVisible ?? false else { return }
            let subtitle = (error as? GenericError)?.title ?? error.message
            viewModel = .alert(title: "Cannot update tips",
                               message: subtitle)
        }
        viewController?.displayGratuity(viewModel: viewModel)
    }
    
    func presentRidesafe(for checkin: Checkin) {
        let freeRideCheckin = checkin.freeRideCheckin ?? checkin
        let rideSafe = BillModels.Ridesafe.ViewModel.init(checkinId: freeRideCheckin.checkin_id,
                                                          data: freeRideCheckin.rideSafeData)
        viewController?.displayRidesafe(viewModel: rideSafe)
    }
    
    func presentUnusedRidesafeAlert(ridesafeTimeMinutes: Int) {
        let minutes = ridesafeTimeMinutes == 1 ? "minute" : "minutes"
        let message = """
        You already unlocked a free Uber ride with your previous checkin. You do not need to wait \(ridesafeTimeMinutes) \(minutes) to redeem the existing free Uber ride. Simply press the \"Free Uber\" button on the bottom of the My Tab screen to redeem it when you're ready.
        """
        UIAlertController.presentAsAlert(title: "Headsup!",
                                         message: message)
    }
}
