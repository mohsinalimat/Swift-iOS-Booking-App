//
//  EditProfilePresenter.swift
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

protocol EditProfilePresentationLogic {
    
    /// Presents current state
    ///
    /// - Parameter response: state model to present
    func present(response: EditProfile.Response)
}

class EditProfilePresenter {
    weak var viewController: EditProfileDisplayLogic?
}

// MARK: - EditProfilePresentationLogic
extension EditProfilePresenter: EditProfilePresentationLogic {
    
    func present(response: EditProfile.Response) {
        switch response {
        case let .user(user):
            let rawItems: [EditProfile.RawItem] = [.firstName, .lastName, .birthDate, .gender, .zipCode, .email, .phone]
            let items: [EditProfile.TableItem] = rawItems.map { $0.tableItem(for: user) }
            viewController?.display(viewModel: .items(items))
            viewController?.setBirthDate(user.birthDate ?? Date())
            viewController?.setGender(user.gender)
        case let .updateState(updateState):
            viewController?.display(viewModel: .updateState(updateState))
        case .updatedUser:
            viewController?.display(title: "Update Successful!", message: "Profile successfully updated")
        case .needsVerifyPhone:
            viewController?.display(viewModel: .verifyAlert(title: "Update Successful!",
                                                            message: "Next, we will verify your mobile # using Digits by Twitter"))
        case let .failedToUpdateUser(message):
            viewController?.display(title: "Update Failed", message: message)
        }
    }
    
}
