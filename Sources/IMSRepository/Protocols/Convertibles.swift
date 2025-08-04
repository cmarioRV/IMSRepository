//
//  Convertibles.swift
//  server
//
//  Created by Mario Rúa on 27/07/25.
//
import Vapor
import Fluent
import IMSDomain

typealias DatabaseModel = Model

protocol FirestoreConvertible where Self: DomainModel {
    associatedtype FirestoreFieldsModelType: FirestoreFieldsModel
    func toFirestoreModel() -> FirestoreFieldsModelType
}

protocol ModelConvertible where Self: DomainModel {
    associatedtype DatabaseModelType: DatabaseModel
    func toModel() -> DatabaseModelType
}

protocol DomainModelConvertible where Self: DatabaseModel {
    associatedtype DomainModelType: DomainModel
    func toDomainModel() -> DomainModelType
}

protocol FirestoreDomainModelConvertible where Self: FirestoreFieldsModel {
    associatedtype DomainModelType: DomainModel
    func toDomainModel() -> DomainModelType
}
