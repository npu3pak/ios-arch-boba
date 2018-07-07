//
//  AuthViewController.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit
import FormEditor

class AuthViewController: UIViewController, AuthFacadeDelegate {

    @IBOutlet weak var phoneTextField: FormattedTextField!

    var onShowConfirmation: ((AuthConfirmationFacade) -> Void)?

    var facade: AuthFacade!

    private lazy var errorHandler = ErrorHandler(controller: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        facade.delegate = self

        phoneTextField.inputMask = Constants.Masks.phone
        phoneTextField.onValueChanged = { [unowned self] in self.facade.phone = $0 }

        #if DEBUG
        fillDebugData()
        #endif
    }

    private func fillDebugData() {
        let phone = Constants.TestAccount.phone
        phoneTextField.text = phone
        facade.phone = phone
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        phoneTextField.becomeFirstResponder()
    }

    func updateCheckPhoneAvailability() {
        if facade.isCheckPhoneAvailable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.Navigation.apply,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(onCheckPhoneButtonClick))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc private func onCheckPhoneButtonClick(_ sender: Any) {
        showProgressIndicator()
        facade.checkPhone()
    }

    func showConfirmation(facade: AuthConfirmationFacade) {
        hideProgressIndicator()
        onShowConfirmation?(facade)
    }

    func showCheckPhoneError(_ error: UserError) {
        hideProgressIndicator()
        errorHandler.showError(error)
    }
}
