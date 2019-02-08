//
//  AuthViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit
import WebKit

protocol AuthViewControllerInteractor: class {
    
}

protocol AuthViewControllerCoordinator: class {
    func showMainScreen()
    func dismiss()
}

class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var interactor: AuthViewInteractor!
    weak var coordinator: AuthViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            LastfmAuth.auth.userIsExist(completion: { [weak self] (session) in
                if session != nil {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                        self?.coordinator?.showMainScreen()
                    }
                }
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        loginTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let username = loginTextField.text,
            let password = passwordTextField.text else { return }
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        LastfmAuth.auth.login(withUsername: username, password: password) { [weak self] (session, _) in
            if session != nil {
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.activityIndicator.stopAnimating()
                    self?.coordinator?.showMainScreen()
                }
            } else {
                DispatchQueue.main.async {
                    self?.view.isUserInteractionEnabled = true
                    self?.activityIndicator.stopAnimating()
                    self?.showAlert()
                }
            }
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Error", message:
            "Login or password is incorrect. Try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        coordinator?.showMainScreen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
