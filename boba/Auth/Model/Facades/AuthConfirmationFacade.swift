//
//  AuthConfirmationFacade.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

protocol AuthConfirmationFacadeDelegate: class {
    func updateConfirmAvailability()
    func showConfirmationError(_ error: UserError)
    func showConfirmationSuccess()
}

class AuthConfirmationFacade {

    weak var delegate: AuthConfirmationFacadeDelegate?

    private var model: AuthModel

    private(set) var phone: String

    init(authModel: AuthModel = Model.instance.auth, phone: String) {
        self.model = authModel
        self.phone = phone
    }

    var confirmationCode: String? {
        didSet {
            delegate?.updateConfirmAvailability()
        }
    }

    var isConfirmAvailable: Bool {
        return confirmationCode?.checkRegexp(Constants.Regexp.authConfirmationCode) == true
    }

    func confirm() {
        guard let confirmationCode = self.confirmationCode else {
            let error = UserError.withMessage(Strings.Auth.emptyConfirmationCodeError)
            delegate?.showConfirmationError(error)
            return
        }

        guard confirmationCode.checkRegexp(Constants.Regexp.authConfirmationCode) else {
            let error = UserError.withMessage(Strings.Auth.incorrectConfirmationCodeError)
            delegate?.showConfirmationError(error)
            return
        }

        model.authorize(phone: phone, confirmationCode: confirmationCode,
                        onError: { [unowned self] in self.delegate?.showConfirmationError($0) },
                        onSuccess: { [unowned self] in self.delegate?.showConfirmationSuccess() })
    }
}
