//
//  FirestoreManager.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 10/10/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreManager {
    static let shared = FirestoreManager()
    
    let db = Firestore.firestore()
    
    func saveEvent(_ event: Event, from delegate: FirestoreManagerSaveDelegate) {
        do {
            try db.collection("events").document(event.eventID).setData(from: event)
            delegate.didSaveEvent(self, event)
        } catch {
            guard let errMessage = FirestoreErrorCode(rawValue: error._code)?.getErrorMessage() else {return}
            delegate.didFailWithError(self, errorMessage: errMessage)
        }
    }
    
    func deleteEvent(_ event: Event, from delegate: FirestoreManagerDeleteDelegate) {
        db.collection("events").document(event.eventID).delete() { err in
            if err != nil {
                guard let errMessage = FirestoreErrorCode(rawValue: err!._code)?.getErrorMessage() else {return}
                delegate.didFailWithError(self, errorMessage: errMessage)
            } else {
                delegate.didDeleteEvent(self)
            }
        }
    }
    
    func fetchEvents(with fetchParameters: FetchParameters, from delegate: FirestoreManagerFetchDelegate) {
        var events = [Event]()
        let query = constructQuery(from: fetchParameters)
        
        query.getDocuments { (querySnapshot, err) in
            if err != nil {
                guard let errMessage = FirestoreErrorCode(rawValue: err!._code)?.getErrorMessage() else {return}
                delegate.didFailWithError(self, errorMessage: errMessage)
            }
            
            guard let documents = querySnapshot?.documents else {return}
            
            for document in documents {
                let result = Result {
                    try document.data(as: Event.self)
                }
                switch result {
                case .success(let event):
                    if let event = event {
                        events.append(event)
                    } else {
                        print("Document does not exist")
                    }
                case .failure(let error):
                    print("Error decoding event: \(error)")
                }
            }
            delegate.didFetchEvents(self, events: events)
        }
    }
    
    //MARK: - Helper methods
    func constructQuery(from fetchParameters: FetchParameters) -> Query {
        let collectionRef = db.collection("events")
        var query: Query!
        
        let fieldName = fetchParameters.fieldName
        let fieldValue = fetchParameters.fieldValue
        let fetchOperator = fetchParameters.fetchOperator
        
        switch fetchOperator {
        case .equalTo:
            query = collectionRef.whereField(fieldName, isEqualTo: fieldValue)
        case .greaterThanOrEqual:
            query = collectionRef.whereField(fieldName, isGreaterThan: fieldValue)
        case .lessThanOrEqual:
            query = collectionRef.whereField(fieldName, isLessThan: fieldValue)
        case .arrayContains:
            query = collectionRef.whereField(fieldName, arrayContains: fieldValue)
        }
        return query
    }
}

//MARK: - Protocols
protocol FirestoreFetchDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event])
}

protocol FirestoreSaveDelegate {
    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event)
}

protocol FirestoreDeleteDelegate {
    func didDeleteEvent(_ firestoreManager: FirestoreManager)
}

protocol FirestoreErrorDelegate {
    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String)
}

typealias FirestoreManagerFetchDelegate = FirestoreFetchDelegate & FirestoreErrorDelegate
typealias FirestoreManagerSaveDelegate = FirestoreSaveDelegate & FirestoreErrorDelegate
typealias FirestoreManagerDeleteDelegate = FirestoreDeleteDelegate & FirestoreErrorDelegate
typealias FirestoreManagerCompleteDelegate = FirestoreFetchDelegate & FirestoreSaveDelegate & FirestoreDeleteDelegate & FirestoreErrorDelegate
