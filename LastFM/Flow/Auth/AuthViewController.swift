//
//  AuthViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var passwordIsSecure = false {
        didSet {
            let image = passwordIsSecure ? UIImage(named: "eye_open") : UIImage(named: "eye_closed")
            eyePasswordButton.setImage(image, for: .normal)
            passwordTextField.isSecureTextEntry = passwordIsSecure
        }
    }
    
    private lazy var eyePasswordButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        button.addTarget(self, action: #selector(eyeImagePressed), for: .touchUpInside)
        passwordTextField.setRightButtonView(button)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardShouldHide))
        view.addGestureRecognizer(tapGesture)
        
        loginIfUserAuthorized()
        registerNotificationObservers()
        passwordIsSecure = true
    }
    
    private func loginIfUserAuthorized() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        LastfmAuth.auth.userIsExist(completion: { [weak self] (session) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                if session != nil {
                    self?.performSegue(withIdentifier: "mainScreen", sender: self)
                }
            }
        })
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
    
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Error", message:
            "Login or password is incorrect. Try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Actions
extension AuthViewController {
    
    @objc func eyeImagePressed() {
        passwordIsSecure = !passwordIsSecure
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let username = loginTextField.text,
            let password = passwordTextField.text else { return }
        
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        LastfmAuth.auth.login(withUsername: username, password: password) { [weak self] (session, _) in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                self?.activityIndicator.stopAnimating()
                session != nil ? self?.performSegue(withIdentifier: "mainScreen", sender: self) : self?.showAlert()
            }
        }
    }
    
    @objc func keyboardShouldHide() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardSize, from: nil).size.height / 2
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
    }
}
