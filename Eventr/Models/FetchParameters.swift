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
    /*
    let orderField: String
    let orderDescending: Bool
    */
    
    enum FetchOperators: String {
        case lessThanOrEqual
        case equalTo
        case greaterThanOrEqual
        case arrayContains
    }
    
    init(fieldName: String, fieldValue: Any, fetchOperator: FetchOperators /* , orderField: String, orderDescending: Bool */) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.fetchOperator = fetchOperator
        /*
        self.orderField = orderField
        self.orderDescending = orderDescending
        */
    }
}

//let fetchParams = FetchParameters(collectionName: "events", cityName: "Vegas")
