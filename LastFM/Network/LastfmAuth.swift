//
//  LastfmAuth.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class LastfmAuth {
    
    static let auth = LastfmAuth()
    
    private init() {}
    
    var session: Session?
    
    func login(withUsername username: String, password: String, completion: @escaping (_ session: Session?, _ error: Error?) -> Void) {
        LastfmAPIClient.getMobileSession(username: username, password: password) { [weak self] (result) in
            switch result {
            case .success(let session):
                guard let session = session else { return }
                self?.session = session
                self?.saveUserInfo(username: username, password: password)
                completion(session, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func userIsExist(completion: @escaping (_ session: Session?) -> Void) {
        let userInfo = fetchUserInfo()
        if let username = userInfo.0, let password = userInfo.1 {
            LastfmAPIClient.getMobileSession(username: username, password: password) { [weak self] (result) in
                switch result {
                case .success(let session):
                    guard let session = session else { return }
                    self?.session = session
                    completion(session)
                default:
                    self?.removeUserInfo()
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func logout() {
        self.session = nil
        saveUserInfo(username: nil, password: nil)
    }
    
    private func saveUserInfo(username: String?, password: String?) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    private func fetchUserInfo() -> (String?, String?) {
        let username = UserDefaults.standard.string(forKey: "username")
        let password = UserDefaults.standard.string(forKey: "password")
        
        return (username, password)
    }
    
    private func removeUserInfo() {
        UserDefaults.standard.set(nil, forKey: "username")
        UserDefaults.standard.set(nil, forKey: "password")
    }
}
