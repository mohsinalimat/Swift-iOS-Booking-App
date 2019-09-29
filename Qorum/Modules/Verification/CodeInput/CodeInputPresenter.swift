//
//  CodeInputPresenter.swift
//  Qorum
//
//  Created by Stanislav on 09.04.2018.
//  Copyright (c) 2018 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CodeInputPresentationLogic: class {
    
    /// Presents current state
    ///
    /// - Parameter response: response model with current state
    func present(response: CodeInput.Response)
    
    /// Shows loader with custom message
    ///
    /// - Parameter message: message to show
    func showLoader(message: String)
    
    /// Hides loader
    func hideLoader()
}

class CodeInputPresenter {
    weak var viewController: CodeInputDisplayLogic?
}

// MARK: - CodeInputPresentationLogic
extension CodeInputPresenter: CodeInputPresentationLogic {
    
    func present(response: CodeInput.Response) {
        let viewModel: CodeInput.ViewModel
        switch response {
        case .invalidCode:
            viewModel = .warning("INVALID VERIFICATION CODE")
        case .noPendingVerifications:
            viewModel = .failure("No pending verifications for your phone. Try again.")
        case .reachedRequestsLimit:
            viewModel = .failure("Too Many Requests API usage limit. Please wait until you pass the limit and attempt the call again.")
        case .error(let error):
            viewModel = .warning(error.message)
        case .success(let needsVerifyEmail):
            viewModel = needsVerifyEmail ? .mayVerifyEmail : .mayClose
        case .secondsToSubmit(let seconds):
            viewModel = .resubmitButton(isEnabled: false, text: "SUBMIT VERIFICATION CODE IN \(seconds)")
        case .mayReSubmit:
            viewModel = .resubmitButton(isEnabled: true, text: "SUBMIT")
        case .secondsToResend(let seconds):
            viewModel = .resendButton(isEnabled: false, text: "RESEND VERIFICATION CODE IN \(seconds)")
        case .mayResend:
            viewModel = .resendButton(isEnabled: true, text: "RESEND VERIFICATION CODE")
        }
        viewController?.display(viewModel: viewModel)
    }
    
    func showLoader(message: String) {
        viewController?.showLoader(message)
    }
    
    func hideLoader() {
        viewController?.hideLoader()
    }
    
}

