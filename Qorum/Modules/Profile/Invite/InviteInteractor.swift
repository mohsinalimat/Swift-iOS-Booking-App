//
//  InviteInteractor.swift
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
import MessageUI
import TwitterKit
import FBSDKShareKit
import FacebookCore
import FacebookLogin
import FacebookShare

protocol InviteBusinessLogic {
    
    /// Fetches user data
    func fetchUser()
    
    /// Perform share action with request
    ///
    /// - Parameter request: request model
    func action(_ request: Invite.Request)
}

protocol InviteDataStore {
    var appearanceType: String? { get set }
}

class InviteInteractor: NSObject, InviteDataStore {
    var presenter: InvitePresentationLogic?
    private(set) lazy var worker = InviteWorker()
    var messageTitle = "Check out Qorum!"
    var messageDescription = "The definitive guide for navigating nights out."
    var messageImageURL = URL(string: "https://trygigster-qorum-www.herokuapp.com/images/slider-top-image.png")
    weak var fbDelegate: FBSDKSharingDelegate?
    var appearanceType: String?
}

// MARK: - InviteBusinessLogic
extension InviteInteractor: InviteBusinessLogic {
    
    func fetchUser() {
        let user = worker.user
        presenter?.present(response: .init(user: user))
    }
    
    func action(_ request: Invite.Request) {
        let user = worker.user
        guard
            let branchLink = user.branchLink else { return }
        switch request {
        case let .facebook(viewController):
            // loadingView.isHidden = false
            let content = FBSDKShareLinkContent()
            content.contentURL = URL(string: branchLink)
            let dialog = FBSDKShareDialog()
            dialog.fromViewController = viewController
            dialog.shareContent = content
            dialog.mode = .feedBrowser
            dialog.delegate = self
            dialog.show()
        case let .twitter(viewControlller):
            let composer = TWTRComposer()
            composer.setText(messageTitle)
            composer.setURL(URL(string: branchLink))
            if let imageUrl = messageImageURL {
                if let data = try? Data(contentsOf: imageUrl) {
                    composer.setImage(UIImage(data: data))
                }
            }
            composer.show(from: viewControlller) { [weak self] result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    switch result {
                    case .done:
                        self?.worker.trackInvite(for: .postToTwitter, status: .succeed, appearanceType: self?.appearanceType ?? "")
                        let response = Invite.Result.Response(source: .postToTwitter, status: .succeed)
                        self?.presenter?.present(response: response)
                    case .cancelled:
                        self?.worker.trackInvite(for: .postToTwitter, status: .cancelled, appearanceType: self?.appearanceType ?? "")
                        let response = Invite.Result.Response(source: .postToTwitter, status: .cancelled)
                        self?.presenter?.present(response: response)
                    }
                })
            }
        case let .other(viewController):
            var items = [Any]()
            let shareString = messageTitle
            items.append(shareString)
            if let url = URL(string: branchLink) {
                items.append(url)
            }
            if MFMessageComposeViewController.canSendAttachments() {
                if let imageUrl = messageImageURL {
                    if let data = try? Data(contentsOf: imageUrl) {
                        if let attachment = UIImage(data: data) {
                            items.append(attachment)
                        }
                    }
                }
            }
            let shareViewController = UIActivityViewController(activityItems: items,
                                                               applicationActivities: nil)
            var excludedActivities = [
                .assignToContact,
                .addToReadingList,
                .openInIBooks,
                .postToFlickr,
                .postToVimeo,
                .saveToCameraRoll,
                .print,
                .airDrop
            ] as [UIActivityType]
            
            if #available(iOS 11.0, *) {
                excludedActivities.append(.markupAsPDF)
            }
            shareViewController.excludedActivityTypes = excludedActivities
            shareViewController.completionWithItemsHandler = { [weak self] (type, completed, items, error) in
                if let type = type {
                    if completed {
                        self?.worker.trackInvite(for: type, status: .succeed, appearanceType: self?.appearanceType ?? "")
                        let response = Invite.Result.Response(source: type, status: .succeed)
                        self?.presenter?.present(response: response)
                    } else if let _ = error {
                        self?.worker.trackInvite(for: type, status: .failed, appearanceType: self?.appearanceType ?? "")
                        let response = Invite.Result.Response(source: type, status: .failed)
                        self?.presenter?.present(response: response)
                    } else {
                        self?.worker.trackInvite(for: type, status: .cancelled, appearanceType: self?.appearanceType ?? "")
                        let response = Invite.Result.Response(source: type, status: .cancelled)
                        self?.presenter?.present(response: response)
                    }
                }
            }
            // Present the share sheet
            viewController.navigationController?.present(shareViewController, animated: true, completion: nil)
        case let .email(viewController):
            // loadingView.isHidden = false
            showInviteEmail(branchLink, from: viewController)
        case let .sms(viewController):
            //loadingView.isHidden = false
            if MFMessageComposeViewController.canSendText() {
                let messageComposer = MFMessageComposeViewController()
                messageComposer.body = String("\(messageTitle) \(branchLink)")
                messageComposer.messageComposeDelegate = self
                if MFMessageComposeViewController.canSendAttachments() {
                    if let imageUrl = messageImageURL {
                        if let data = try? Data(contentsOf: imageUrl) {
                            if let attachment = UIImage(data: data) {
                                messageComposer.addAttachmentData(UIImageJPEGRepresentation(attachment, 1)!,
                                                                  typeIdentifier: "mime/jpeg",
                                                                  filename: "Qorum.jpeg")
                            }
                        }
                    }
                }
                viewController.navigationController?.present(messageComposer, animated: true, completion: nil)
            }
        }
    }
    
    func showInviteEmail(_ url: String, from viewController: UIViewController) {
        var attachment: SafeMailSender.Attachment?
        if  let imageUrl = messageImageURL,
            let data = try? Data(contentsOf: imageUrl),
            let image = UIImage(data: data)
        {
            attachment = SafeMailSender.Attachment(title: "Qorum", image: image)
        }
        let mailSender = SafeMailSender.shared
        mailSender.delegate = self
        mailSender.send(subject: messageTitle,
                        body: NSLocalizedString("\(messageDescription)<br/><br/><a href='\(url)'>Download Qorum</a>", comment:""),
                        attachment: attachment,
                        from: viewController)
    }
    
}

// MARK: - MFMessageComposeViewControllerDelegate
extension InviteInteractor: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            worker.trackInvite(for: .message, status: .succeed, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .message, status: .succeed)
            presenter?.present(response: response)
        case .cancelled:
            worker.trackInvite(for: .message, status: .cancelled, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .message, status: .cancelled)
            presenter?.present(response: response)
        case .failed:
            worker.trackInvite(for: .message, status: .failed, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .message, status: .failed)
            presenter?.present(response: response)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - SafeMailSenderDelegate
extension InviteInteractor: SafeMailSenderDelegate {
    
    func safeMailSenderDidFinish(with result: SafeMailSender.Result) {
        switch result {
        case .sent:
            worker.trackInvite(for: .mail, status: .succeed, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .mail, status: .succeed)
            presenter?.present(response: response)
        case .cancelled:
            worker.trackInvite(for: .mail, status: .cancelled, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .mail, status: .cancelled)
            presenter?.present(response: response)
        case .failed(_):
            worker.trackInvite(for: .mail, status: .failed, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .mail, status: .failed)
            presenter?.present(response: response)
        case .saved:
            worker.trackInvite(for: .mail, status: .cancelled, appearanceType: appearanceType!)
            let response = Invite.Result.Response(source: .mail, status: .cancelled)
            presenter?.present(response: response)
        }
    }
    
}

//FBSharing capturing
extension InviteInteractor: FBSDKSharingDelegate {
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        worker.trackInvite(for: .postToFacebook, status: .succeed, appearanceType: appearanceType!)
        let response = Invite.Result.Response(source: .postToFacebook, status: .succeed)
        presenter?.present(response: response)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        worker.trackInvite(for: .postToFacebook, status: .failed, appearanceType: appearanceType!)
        let response = Invite.Result.Response(source: .postToFacebook, status: .failed)
        presenter?.present(response: response)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        worker.trackInvite(for: .postToFacebook, status: .cancelled, appearanceType: appearanceType!)
        let response = Invite.Result.Response(source: .postToFacebook, status: .cancelled)
        presenter?.present(response: response)
    }
    
}




