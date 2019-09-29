//
//  ProfileInteractor.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import Foundation

protocol ProfileBusinessLogic: AnyObject {
    
    /// Fetches user data and images
    ///
    /// - Parameter request: data needs to be fetched
    func fetch(_ request: Profile.Request)
    
    /// Asks to send ticket to support
    func sendSupportMail()
    
    /// Asks to logout
    func logoutUser()
    
    /// Asks to check out (i.e close the tab)
    ///
    /// - Parameter checkinId: active checkin id
    func checkout(checkinId: Int)
}

protocol ProfileDataStore { }

class ProfileInteractor: ProfileDataStore {
    var presenter: ProfilePresentationLogic?
    private(set) lazy var worker = ProfileWorker()
}

// MARK: - ProfileBusinessLogic
extension ProfileInteractor: ProfileBusinessLogic {
    
    func fetch(_ request: Profile.Request) {
        switch request {
        case .user(let localOnly):
            let user = User.stored
            guard !user.isGuest else {
                logoutUser()
                return
            }
            presenter?.present(response: .user)
            guard !localOnly else { return }
            var isFirstLoading = false
            if user.firstName == nil {
                isFirstLoading = true
                presenter?.present(response: .loading(.started(message: nil)))
            }
            worker.fetchUser(id: user.userId) { [weak self] result in
                switch result {
                case let .value(fetchedUser):
                    fetchedUser.isAvatarPlaceholder = user.isAvatarPlaceholder
                    fetchedUser.settings = user.settings
                    fetchedUser.save()
                    FBFriend.fetch { result in
                        switch result {
                        case let .value(friends):
                            fetchedUser.facebookFriends = friends
                            fetchedUser.save()
                            print("Did load friends: \(friends.count)")
                        case let .error(error):
                            print("ProfileInteractor fetch.user - ProfileWorker fetchFacebookFriends error:", error)
                        }
                    }
                    if isFirstLoading {
                        self?.presenter?.present(response: .loading(.succeeded(true)))
                    }
                    self?.presenter?.present(response: .user)
                case let .error(error):
                    print(error)
                    if (error as? GenericError)?.status == 401 {
                        self?.logoutUser()
                    }
                }
            }
        case .facebookImage:
            worker.fetchFacebookAvatar(maxSize: 800) { [weak self] fetchResult in
                switch fetchResult {
                case let .value(avatar):
                    guard let avatarURL = avatar.url else {
                        print("ProfileInteractor: avatar url is missing - won't download an image")
                        return
                    }
                    self?.worker.downloadImage(from: avatarURL) { [weak self] downloadResult in
                        switch downloadResult {
                        case let .value(image):
                            let storedUser = User.stored
                            guard !storedUser.isGuest else {
                                print("ProfileInteractor: missing stored user - won't upload an image")
                                return
                            }
                            storedUser.isAvatarPlaceholder = avatar.isPlaceholder
                            storedUser.save()
                            self?.upload(image: image)
                        case let .error(error):
                            print("ProfileInteractor downloadImage error:\n", error)
                        }
                    }
                case let .error(error):
                    print("ProfileInteractor fetchFacebookAvatar error:\n", error)
                }
            }
        case let .photos(image):
            let storedUser = User.stored
            guard !storedUser.isGuest else {
                print("ProfileInteractor: missing stored user - won't upload an image")
                return
            }
            upload(image: image)
        }
    }
    
    func sendSupportMail() {
        presenter?.present(response: .mail(to: "support@qorum.com", subject: "Qorum Support", body: "Hi Qorum Team!\n\n"))
    }
    
    func logoutUser() {
        worker.logoutUser { [weak presenter] in
            presenter?.present(response: .userLoggedOut)
        }
    }
    
    func checkout(checkinId: Int) {
        presenter?.present(response: .loading(.started(message: "Closing Tab")))
        BillWorker().checkOut(checkinId: checkinId) { [weak self] result in
            self?.presenter?.present(response: .loading(.finished))
            self?.logoutUser()
        }
    }
    
    private func upload(image: UIImage) {
        let storedUser = User.stored
        if !storedUser.isGuest {
            worker.upload(image: image, for: storedUser) { [weak self] result in
                switch result {
                case let .value(fetchedUser):
                    storedUser.avatarURL = fetchedUser.avatarURL
                    storedUser.isAvatarPlaceholder = false
                    storedUser.save()
                    self?.presenter?.present(response: .user)
                case let .error(error):
                    print("ProfileInteractor imageUploadFinished error: \(error)")
                }
            }
        } else {
            print("User is guest")
        }
    }
}


