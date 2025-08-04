//
//  FirestoreRepositoryProtocol.swift
//  server
//
//  Created by Mario Rúa on 27/07/25.
//
import VaporFirestore

typealias Document = VaporFirestore.Firestore.Document

protocol FirestoreRepositoryProtocol {
    func create<T: FirestoreFieldsModel>(model: T, client: FirestoreResource) async throws -> Document<T>
    func update<T: FirestoreFieldsModel>(collection: String,
                                         document: Document<T>,
                                         model: T,
                                         client: FirestoreResource,
                                         updateMask: [String]?) async throws -> Document<T>
}
