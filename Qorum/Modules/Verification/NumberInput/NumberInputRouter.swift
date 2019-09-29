//
//  NumberInputRouter.swift
//  Qorum
//
//  Created by Stanislav on 05.04.2018.
//  Copyright (c) 2018 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SafariServices.SFSafariViewController

@objc protocol NumberInputRoutingLogic {
    
    /// Closes scene
    func routeClose()
    
    /// Opens received code verification screen
    func routeToCodeVerification()
    
    /// Opens email verification screen
    func routeToEmailVerification()
    
    /// Opens Privacy policy
    func routeToPolicy()
}

protocol NumberInputDataPassing {
    var dataStore: NumberInputDataStore? { get }
}

class NumberInputRouter: NSObject, NumberInputDataPassing {
    
    weak var viewController: NumberInputViewController?
    var dataStore: NumberInputDataStore?
    
    // MARK: Navigation
    
    //func navigateToSomewhere(source: NumberInputViewController, destination: SomewhereViewController) {
    //    source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    func passDataToCodeInput(source: NumberInputDataStore, destination: inout CodeInputDataStore) {
        destination.phone = source.phone
    }
    
}

// MARK: - NumberInputRoutingLogic
extension NumberInputRouter: NumberInputRoutingLogic {
    
    func routeClose() {
        viewController?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func routeToCodeVerification() {
        let destinationVC = CodeInputViewController.fromStoryboard
        var destinationDS = destinationVC.router!.dataStore!
        passDataToCodeInput(source: dataStore!, destination: &destinationDS)
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func routeToEmailVerification() {
        let destinationVC = EmailInputViewController.fromStoryboard
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func routeToPolicy() {
        let svc = SFSafariViewController(url: kPolicyURL)
        viewController?.present(svc, animated: true, completion: nil)
    }
    
}

