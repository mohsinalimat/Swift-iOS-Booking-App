//
//  OnboardingRouter.swift
//  Qorum
//
//  Created by Vadym Riznychok on 9/26/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol OnboardingRoutingLogic {
    func navigateToAuth(source: OnboardingViewController)
    func navigateBack(source: OnboardingViewController)
}

protocol OnboardingDataPassing {
    var dataStore: OnboardingDataStore? { get }
}

class OnboardingRouter: NSObject, OnboardingRoutingLogic, OnboardingDataPassing {
    weak var viewController: OnboardingViewController?
    var dataStore: OnboardingDataStore?
  
    // MARK: Routing
    
    func navigateToAuth(source: OnboardingViewController) {
        source.navigationController?.pushViewController(AuthViewController.fromStoryboard, animated: true)
    }
    
    func navigateBack(source: OnboardingViewController) {
        source.navigationController?.popViewController(animated: false)
    }
    
}
