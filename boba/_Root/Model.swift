//
//  Model.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

class Model {

    let auth: AuthModel

    static let instance = Model()

    private init() {
        auth = AuthModel()
    }
}
