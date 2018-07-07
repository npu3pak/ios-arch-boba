//
//  AuthConfirmationViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class AuthConfirmationViewController: UIViewController, AuthConfirmationFacadeDelegate {

    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var codeTextField: FormattedTextField!
    @IBOutlet weak var changePhoneBottomConstraint: NSLayoutConstraint!

    var onChangePhone: (() -> Void)?
    var onAuthSuccess: (() -> Void)?

    var facade: AuthConfirmationFacade!

    private lazy var errorHandler = ErrorHandler(controller: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        facade.delegate = self

        codeTextField.inputMask = Constants.Masks.authConfirmationCode
        codeTextField.onValueChanged = { [unowned self] in self.facade.confirmationCode = $0 }

        showHintMessage()

        #if DEBUG
        fillDebugData()
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        codeTextField.becomeFirstResponder()
    }

    private func fillDebugData() {
        let code = Constants.TestAccount.authConfirmationCode
        codeTextField.text = code
        facade.confirmationCode = code
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func showHintMessage() {
        hintLabel.text = Strings.Auth.confirmationHint(phone: facade.phone)
    }

    @objc func onKeyboardWillShow(_ notification: Notification) {
        let keyboardSize = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        changePhoneBottomConstraint.constant = Sizes.Auth.confirmationChangePhoneBottomMargin + keyboardSize.height
    }

    @objc func onKeyboardWillHide(_ notification: Notification) {
        changePhoneBottomConstraint.constant = Sizes.Auth.confirmationChangePhoneBottomMargin
    }

    @IBAction func onChangePhoneButtonClick(_ sender: Any) {
        onChangePhone?()
    }

    func updateConfirmAvailability() {
        if facade.isConfirmAvailable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.Navigation.apply,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(onConfirmButtonClick))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc private func onConfirmButtonClick(_ sender: Any) {
        showProgressIndicator()
        facade.confirm()
    }

    func showConfirmationError(_ error: UserError) {
        hideProgressIndicator()
        errorHandler.showError(error)
    }

    func showConfirmationSuccess() {
        hideProgressIndicator()
        onAuthSuccess?()
    }
}
