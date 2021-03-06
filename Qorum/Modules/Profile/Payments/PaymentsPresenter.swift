//
//  PaymentsPresenter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/27/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol PaymentsPresentationLogic {
    
    /// Presents current state
    ///
    /// - Parameter response: state model
    func present(response: Payments.Response)
    
    /// Presents Loading state
    ///
    /// - Parameter loadingState: loading state model
    func present(loadingState: Payments.LoadingState)
    
    /// Presents Alert
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - message: alert text
    func presentAlert(title: String, message: String)
}

class PaymentsPresenter {
    weak var viewController: PaymentsDisplayLogic?
}

// MARK: - PaymentsPresentationLogic
extension PaymentsPresenter: PaymentsPresentationLogic {
    
    func present(response: Payments.Response) {
        switch response {
        case let .value(cards):
            viewController?.displayFetchedPaymentCards(viewModel: .init(cards: cards))
        case let .error(error):
            present(loadingState: .finished)
            debugPrint("PaymentsPresenter present response error:", error)
            presentAlert(title: "Looks like we're having an issue with our payment processor",
                         message: "Please try again in 10 minutes")
        }
    }
    
    func present(loadingState: Payments.LoadingState) {
        viewController?.display(loadingState: loadingState)
    }
    
    func presentAlert(title: String, message: String) {
        viewController?.display(title: title, message: message)
    }
}
