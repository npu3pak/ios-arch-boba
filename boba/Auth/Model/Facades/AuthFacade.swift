//
//  AuthFacade.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

protocol AuthFacadeDelegate: class {
    func updateCheckPhoneAvailability()
    func showCheckPhoneError(_ error: UserError)
    func showConfirmation(facade: AuthConfirmationFacade)
}

class AuthFacade {

    weak var delegate: AuthFacadeDelegate?

    private var model: AuthModel

    init(authModel: AuthModel = Model.instance.auth) {
        self.model = authModel
    }

    var phone: String? {
        didSet {
            delegate?.updateCheckPhoneAvailability()
        }
    }

    var isCheckPhoneAvailable: Bool {
        return phone?.checkRegexp(Constants.Regexp.phone) == true
    }

    func checkPhone() {
        guard let phone = self.phone else {
            let error = UserError.withMessage(Strings.Auth.emptyPhoneError)
            delegate?.showCheckPhoneError(error)
            return
        }

        guard phone.checkRegexp(Constants.Regexp.phone) else {
            let error = UserError.withMessage(Strings.Auth.incorrectPhoneError)
            delegate?.showCheckPhoneError(error)
            return
        }

        model.sendConfirmationCode(phone: phone,
                                   onError: { [unowned self] in self.onSendConfirmationCodeError($0) },
                                   onSuccess: { [unowned self] in self.onSendConfirmationCodeSuccess(phone: phone) })
    }

    private func onSendConfirmationCodeError(_ error: UserError) {
        delegate?.showCheckPhoneError(error)
    }

    private func onSendConfirmationCodeSuccess(phone: String) {
        let confirmationFacade = AuthConfirmationFacade(authModel: model, phone: phone)
        delegate?.showConfirmation(facade: confirmationFacade)
    }
}
