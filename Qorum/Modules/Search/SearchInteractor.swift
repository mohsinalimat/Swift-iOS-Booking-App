//
//  SearchInteractor.swift
//  Qorum
//
//  Created by Stanislav on 31.01.2018.
//  Copyright (c) 2018 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SearchBusinessLogic {
    
}

protocol SearchDataStore {
    
}

class SearchInteractor: SearchDataStore {
    var presenter: SearchPresentationLogic?
    private(set) lazy var worker = SearchWorker()
}

// MARK: - SearchBusinessLogic
extension SearchInteractor: SearchBusinessLogic {
    
}

