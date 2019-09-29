//
//  EditProfileWorker.swift
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
import Moya

class EditProfileWorker {
    
    let emailConflictMessage = "The email already belongs to another account."
    
    var user: User {
        return User.stored
    }
    
    /// Updates user data
    ///
    /// - Parameters:
    ///   - id: current user id
    ///   - parameters: updated parameters
    ///   - completion: completion block
    func updateUser(id: Int, parameters: [String: Any], completion: @escaping APIHandler<Void>) {
        let request = AuthenticatedRequest(target: .updateUser(id: id, parameters: parameters))
        request.perform { [weak self] response in
            if  response.statusCode == 409,
                parameters["email"] != nil,
                let emailConflictMessage = self?.emailConflictMessage
            {
                completion(.error(emailConflictMessage))
                return
            }
            switch response.result {
            case .value:
                completion(.success)
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
}
