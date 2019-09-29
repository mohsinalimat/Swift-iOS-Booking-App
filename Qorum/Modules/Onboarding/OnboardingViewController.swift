//
//  OnboardingViewController.swift
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
import SnapKit
import SMPageControl

protocol OnboardingDisplayLogic: class { }

class OnboardingViewController: UIViewController, OnboardingDisplayLogic {
    var interactor: OnboardingBusinessLogic?
    var router: (NSObjectProtocol & OnboardingRoutingLogic & OnboardingDataPassing)?
    
    // Content
    
    let onboardingData = [Onboarding.Data.ViewModel.DisplayData(title: "Discover Great Bars", subTitle: "Find the perfect spot with curated\n bars and expert reviews.", image: UIImage(named: "OnboardingScreen0")!),
                          Onboarding.Data.ViewModel.DisplayData(title: "Save on Drinks", subTitle: "Never pay full price.\n Any drink, anytime.", image: UIImage(named: "OnboardingScreen1")!),
                          Onboarding.Data.ViewModel.DisplayData(title: "Pay In-App", subTitle: "Walk out to close out.\n Never leave your card behind.", image: UIImage(named: "OnboardingScreen2")!),
                          Onboarding.Data.ViewModel.DisplayData(title: "Catch a Free Ride", subTitle: "Unlock a free Uber\n 60 minutes after your first round.", image: UIImage(named: "OnboardingScreen3")!)]
    
    var currentIndex = 0 {
        didSet {
            switch currentIndex {
            case 0:
                AnalyticsService.shared.track(event: MixpanelEvents.viewTutorialScreen1.rawValue)
            case 1:
                AnalyticsService.shared.track(event: MixpanelEvents.viewTutorialScreen2.rawValue)
            case 2:
                AnalyticsService.shared.track(event: MixpanelEvents.viewTutorialScreen3.rawValue)
            case 3:
                AnalyticsService.shared.track(event: MixpanelEvents.viewTutorialScreen4.rawValue)
            default:
                break
            }
            pageControl.currentPage = currentIndex
        }
    }
    
    lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        let view = UIView()
        view.backgroundColor = .clear
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.trailing.leading.bottom.equalTo(self.view)
        })
        view.addSubview(controller.view)
        controller.view.snp.makeConstraints({ (make) in
            make.top.trailing.leading.bottom.equalTo(self.view)
        })
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
        return controller
    }()
    
    lazy var pageControl: SMPageControl = {
        let view = SMPageControl()
        view.tapBehavior = .jump
        view.pageIndicatorImage = UIImage(named: "non-selected")
        view.addTarget(self, action: #selector(changePage), for: .valueChanged)
        view.numberOfPages = self.onboardingData.count
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(-65)
            } else {
                make.bottom.equalTo(-64)
            }
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(10)
        })
        
        return view
    }()
    
    lazy var nextButton: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(#imageLiteral(resourceName: "bottom-button-background"), for: .normal)
        view.setTitle(NSLocalizedString("NEXT", comment: ""), for: .normal)
        view.titleLabel!.font = UIFont.montserrat.medium(14)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(-5)
            } else {
                make.bottom.equalTo(-5)
            }
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(51)
        })
        return view
    }()
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OnboardingInteractor()
        let presenter = OnboardingPresenter()
        let router = OnboardingRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseViewBackgroundColor
        configurePageController()
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Configuration
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func configurePageController() {
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers([OnboardingContainerViewController(data: onboardingData.first!)], direction: .forward, animated: false, completion: nil)
        AnalyticsService.shared.track(event: MixpanelEvents.viewTutorialScreen1.rawValue)
        pageControl.currentPage = 0
    }
    
    // MARK: Actions
    @objc func changePage() {
        guard pageControl.currentPage != currentIndex else {
            return
        }
        currentIndex = pageControl.currentPage
        pageController.setViewControllers([OnboardingContainerViewController(data: onboardingData[currentIndex])],
                                          direction: (pageControl.currentPage < currentIndex) ? .reverse : .forward,
                                          animated: true,
                                          completion: nil)
    }
    
    @objc func nextButtonPressed() {
        guard currentIndex < onboardingData.count-1 else {
            UserDefaults.standard.set(true, for: .didShowOnboardingKey)
            router?.navigateBack(source: self)
            return
        }
        currentIndex += 1
        pageController.setViewControllers([OnboardingContainerViewController(data: onboardingData[currentIndex])],
                                          direction: .forward,
                                          animated: true,
                                          completion: nil)
    }
    
}

// MARK: PageViewController Delegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed {
            let controller = pageViewController.viewControllers?.first as! OnboardingContainerViewController
            currentIndex = onboardingData.index(of: controller.data!)!
        }
    }
    
}

// MARK: PageViewController Data Source
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard currentIndex < onboardingData.count-1 else { return nil }
        return OnboardingContainerViewController(data: onboardingData[currentIndex+1])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard currentIndex > 0 else { return nil }
        return OnboardingContainerViewController(data: onboardingData[currentIndex-1])
    }
    
}

