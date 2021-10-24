//
//  FetchParameters.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 12/10/2021.
//

import Foundation

struct FetchParameters {
    let fieldName: String
    let fieldValue: Any
    let fetchOperator: FetchOperators
    
    enum FetchOperators: String {
        case lessThanOrEqual
        case equalTo
        case greaterThanOrEqual
        case arrayContains
    }
    
    init(fieldName: String, fieldValue: Any, fetchOperator: FetchOperators) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.fetchOperator = fetchOperator
    }
}
