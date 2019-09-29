//
//  InviteRouter.swift
//  Qorum
//
//  Created by Stanislav on 29.11.2017.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol InviteRoutingLogic {
    
    /// Opens previous screen
    func routeBack()
    
    /// Opens Legal Notes Screen
    func routeToLegalNote()
    
    /// Opens Phone Verification Screen
    func routeToPhoneVerification()
    
    /// OPens Email Verification Screen
    func routeToEmailVerification()
}

protocol InviteDataPassing {
    var dataStore: InviteDataStore? { get set }
}

class InviteRouter: NSObject, InviteDataPassing {
    weak var viewController: InviteViewController?
    var dataStore: InviteDataStore?
}

// MARK: - InviteRoutingLogic
extension InviteRouter: InviteRoutingLogic {
    
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func routeToLegalNote() {
        let destinationVC = LegalNoteViewController.fromStoryboard
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func routeToPhoneVerification() {
        let destinationVC = NumberInputViewController.fromStoryboard.embeddedInNavigationController
        viewController?.present(destinationVC, animated: true, completion: nil)
    }
    
    func routeToEmailVerification() {
        let destinationVC = EmailInputViewController.fromStoryboard.embeddedInNavigationController
        viewController?.present(destinationVC, animated: true, completion: nil)
    }
    
}