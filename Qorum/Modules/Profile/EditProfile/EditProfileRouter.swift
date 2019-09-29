//
//  EditProfileRouter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/12/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol EditProfileRoutingLogic {
    
    /// Returns to previous screen
    func routeBack()
    
    /// Opens Email Verification Screen
    func routeToEmailVerification()
    
    /// Opens Phone Number Verification Screen
    func routeToPhoneVerification()
}

protocol EditProfileDataPassing {
    var dataStore: EditProfileDataStore? { get set }
}

class EditProfileRouter: NSObject, EditProfileDataPassing {
    weak var viewController: EditProfileViewController?
    var dataStore: EditProfileDataStore?
}

// MARK: - EditProfileRoutingLogic
extension EditProfileRouter: EditProfileRoutingLogic {
    
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func routeToEmailVerification() {
        let destinationVC = EmailInputViewController.fromStoryboard.embeddedInNavigationController
        viewController?.present(destinationVC, animated: true, completion: nil)
    }
    
    func routeToPhoneVerification() {
        let destinationVC = NumberInputViewController.fromStoryboard.embeddedInNavigationController
        viewController?.present(destinationVC, animated: true, completion: nil)
    }
    
}
