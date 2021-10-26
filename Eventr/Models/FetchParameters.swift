//
//  FetchParameters.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 12/10/2021.
//

import Foundation

struct FetchParameters {
    let fieldName: FieldNames
    let fieldValue: Any
    let fetchOperator: FetchOperators
    let sortBy: FieldNames
    let sortDescending: Bool
    //let documentLimit: Int
    
    enum FieldNames: String {
        case creatorUID
        case eventID
        case city
        case date
        case type
        case participants
    }
    
    enum FetchOperators: String {
        case lessThanOrEqual
        case equalTo
        case greaterThanOrEqual
        case arrayContains
    }
    
    init(fieldName: FieldNames, fieldValue: Any, fetchOperator: FetchOperators, sortBy: FieldNames, sortDescending: Bool /*, documentLimit: Int */) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
        self.fetchOperator = fetchOperator
        self.sortBy = sortBy
        self.sortDescending = sortDescending
        //self.documentLimit = documentLimit
    }
}
