//
//  UberOrderInteractor.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/4/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import UberRides
import UberCore
import Mixpanel

protocol UberOrderBusinessLogic {
    
    var user_token: UberToken? { get set }
    var worker: UberOrderWorker { get }
    
    func authorizeUber()
    
    func getProducts(from startLocation: CLLocationCoordinate2D,
                     to finishLocation: CLLocationCoordinate2D,
                     completion: @escaping APIHandler<[UberClass]>)
    
    func registerUberToken(authorizationCode: String,
                           completion: @escaping APIHandler<String>)
    
    func loadRoute(from startLocation: CLLocationCoordinate2D,
                   to finishLocation: CLLocationCoordinate2D,
                   completion: @escaping APIHandler<GoogleDirection>)
    
    func orderUber(uberData: UberRequestData,
                   handler: @escaping (_ success:Bool, _ uberRequestId:String?, _ error: Any?) -> ())
    
    func registerRide(requestId: String,
                      uberData: UberRequestData,
                      completion: @escaping APIHandler<String>)
    
    func checkRidePromo(checkinId: Int, completion: @escaping (_ success: Bool) -> ())
    
    func applyRidePromo(rideId: String,
                        checkinId: Int,
                        completion: @escaping (UberOrder.ApplyPromo.Response) -> ())
    
    func cancelUber(requestId: String, completion: @escaping (_ success: Bool) -> ())
    
    func loadUberPayments(completion: @escaping (_ success: Bool, _ methods: [UberPaymentMethod]?, _ lastPaymentID: String?) -> ())
    
}

protocol UberOrderDataStore {
    var checkin: Checkin? { get set }
}

class UberOrderInteractor: UberOrderDataStore {
    
    var checkin: Checkin?
    
    var presenter: UberOrderPresentationLogic?
    var worker = UberOrderWorker()
    
    var user_token: UberToken? {
        didSet {
            let storedUser = User.stored
            storedUser.settings.uber_token = user_token?.accessToken
            storedUser.settings.refresh_token = user_token?.refreshToken
            storedUser.save()
            print(user_token ?? "")
        }
    }
    
    init() {
        if let token = User.stored.settings.uber_token {
            self.user_token = UberToken(acessToken: token, refreshToken: nil, expiresIn: nil)
            return
        }
    }
    
}

// MARK: - UberOrderBusinessLogic
extension UberOrderInteractor: UberOrderBusinessLogic {
    
    //MARK: - UberTypes loader
    func authorizeUber() {
        let loginManager = LoginManager(loginType: .authorizationCode)
        loginManager.login(requestedScopes: [.request, .profile, .requestReceipt], presentingViewController: nil) { [weak self] (accessToken, error) in
            if let error = error {
                print("authorizeUber error:\n\(error)\nError code: \(error.userInfo["code"] ?? "")")
                if error.code != 14 {
                    self?.presenter?.presentUberAuthError(error)
                }
            } else if (accessToken?.authorizationCode) != nil {
                print("authorizeUber success")
//                self?.user_token = UberToken(accessToken: accessToken)
                self?.presenter?.presentAuthorize(accessToken!.authorizationCode!)
            } else {
                print("authorizeUber unknown error!\nToken: \(String(describing: accessToken))")
            }
        }
    }
    
    func getProducts(from startLocation: CLLocationCoordinate2D,
                     to finishLocation: CLLocationCoordinate2D,
                     completion: @escaping (APIResult<[UberClass]>) -> Void) {
        worker.getProducts(from: startLocation, to: finishLocation, accessToken: user_token?.accessToken ?? "") { (result) in
            completion(result)
        }
    }
    
    func registerUberToken(authorizationCode: String,
                           completion: @escaping (APIResult<String>) -> Void) {
        worker.registerUberToken(authorizationCode: authorizationCode) { (accessToken) in
            switch accessToken {
            case let .value(token):
                self.user_token = UberToken(acessToken: token, refreshToken: nil, expiresIn: nil)
                let uberToken = NSKeyedArchiver.archivedData(withRootObject: UberToken(acessToken: token, refreshToken: nil, expiresIn: nil))
            case let .error(error):
                print("UberOrderInteractor registerUberToken error:", error)
            }
            completion(accessToken)
        }
    }
    
    func loadRoute(from: CLLocationCoordinate2D,
                   to: CLLocationCoordinate2D,
                   completion: @escaping APIHandler<GoogleDirection>) {
        let sensor = "false"
        let origin = String(format: "%.17g,%.17g", from.latitude, from.longitude)
        let destination = String(format: "%.17g,%.17g", to.latitude, to.longitude)
        let language = "en"
        
        worker.loadRoute(sensor: sensor, origin: origin, destination: destination, language: language) { result in
            switch result {
            case let .value(direction):
                completion(.value(direction))
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
    //MARK: - Ride
    
    func orderUber(uberData: UberRequestData,
                   handler: @escaping (_ success: Bool, _ uberRequestId: String?, _ error: Any?) -> ()) {
        worker.orderUber(uberData: uberData, completion: handler)
    }
    
    func registerRide(requestId: String,
                      uberData: UberRequestData,
                      completion: @escaping APIHandler<String>) {
        worker.registerRide(requestId: requestId, uberData: uberData) { (result) in
            completion(result)
        }
    }
    
    func checkRidePromo(checkinId: Int,
                        completion: @escaping (_ success: Bool) -> ()) {
        guard !User.stored.isGuest else {
            completion(false)
            return
        }
        worker.checkRidePromo(checkinId: checkinId, userId: User.stored.userId) { (success) in
            completion(success)
        }
    }
    
    func applyRidePromo(rideId: String,
                        checkinId: Int,
                        completion: @escaping (UberOrder.ApplyPromo.Response) -> ()) {
        let user = User.stored
        guard !user.isGuest else {
            completion(.error("Can't apply a promo in guest mode"))
            return
        }
        worker.applyRidePromo(rideId: rideId, checkinId: checkinId, userId: user.userId) { response in
            completion(response)
        }
    }
    
    func cancelUber(requestId: String,
                    completion: @escaping (_ success: Bool) -> ()) {
        worker.cancelUber(requestId: requestId) { (success) in
            completion(success)
        }
    }
    
    //Mark: - Payments
    
    func loadUberPayments(completion: @escaping (Bool, [UberPaymentMethod]?, String?) -> ()) {
        worker.loadUberPayments(completion: completion)
    }
    
}
