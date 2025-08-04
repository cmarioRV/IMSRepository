//
//  FirestoreGoodRepository.swift
//  repository
//
//  Created by Mario Rúa on 1/08/25.
//
import Vapor
import VaporFirestore
import IMSDomain

enum FirestoreGoodRepositoryError: Error {
    case documentNotFound
}

typealias FirestoreGoodRepositoryProtocol = FirestoreRepositoryProtocol & GoodRepositoryProtocol

public struct FirestoreGoodRepository: FirestoreGoodRepositoryProtocol {
    public init() {}
    
    public func create(_ goods: [Good], with req: Request) async throws -> [Good] {
        var documents : [Firestore.Document<GoodFieldsModel>] = []
        
        for good in goods {
            let goodDocuments: Firestore.List.Response<GoodFieldsModel> = try await req.application.firestoreService.firestore.listDocumentsPaginated(path: "Goods")
            
            var storedDoc: Firestore.Document<GoodFieldsModel>
                let existingGoodDoc = goodDocuments.documents.filter { $0.fields?.name == good.name }.first
                if let existingGoodDoc = existingGoodDoc {
                    storedDoc = try await update(collection: "Goods",
                                            document: existingGoodDoc,
                                            model: good.toFirestoreModel(),
                                            client: req.application.firestoreService.firestore, updateMask: nil)
                } else {
                    storedDoc = try await create(model: good.toFirestoreModel(), client: req.application.firestoreService.firestore)
                }
            
            documents.append(storedDoc)
        }
        
        return documents.compactMap { $0.fields }.map { $0.toDomainModel() }
    }
    
    public func getAll(with req: Request) async throws -> [Good] {
        let client = req.application.firestoreService.firestore
        let result: Firestore.List.Response<GoodFieldsModel> = try await client.listDocumentsPaginated(path: "Goods")
        return result.documents.compactMap { $0.fields }.map { $0.toDomainModel() }
    }
    
    public func getByPrice(minPrice: Double, maxPrice: Double, with req: Request) async throws -> [Good] {
        []
    }
    
    public func delete(_ good: Good, with req: Vapor.Request) async throws -> Bool {
        return false
    }
}

extension FirestoreGoodRepository {
    func create<T>(model: T, client: FirestoreResource) async throws -> Document<T> where T : FirestoreFieldsModel {
        return try await client.createDocument(path: "Goods", fields: model)
    }
    
    func update<T>(collection: String, document: Document<T>,
                   model: T,
                   client: FirestoreResource,
                   updateMask: [String]?) async throws -> Document<T> where T : FirestoreFieldsModel {
        
        guard let storedGoodFieldsModel = document.fields as? GoodFieldsModel,
              let updatedGoodFieldsModel = model as? GoodFieldsModel else {
            throw FirestoreGoodRepositoryError.documentNotFound
        }
        
        let storedProviders = storedGoodFieldsModel.providers.map({ $0.wrappedValue as ProviderFieldsModel })
        let updatedProviders = updatedGoodFieldsModel.providers.map({ $0.wrappedValue })
        let newProviders = Array(Set(storedProviders + updatedProviders)).map { Firestore.MapValue(wrappedValue: $0) }
        let newGoodFields = GoodFieldsModel(name: updatedGoodFieldsModel.name,
                                             description: updatedGoodFieldsModel.description,
                                             measure_unit: updatedGoodFieldsModel.measure_unit,
                                             price: updatedGoodFieldsModel.price,
                                             quantity: updatedGoodFieldsModel.quantity,
                                             category: updatedGoodFieldsModel.category,
                                             providers: newProviders)
        
        guard let model = newGoodFields as? T else {
            throw FirestoreGoodRepositoryError.documentNotFound
        }
        
        return try await client.updateDocument(path: "\(collection)/\(document.id)", fields: model, updateMask: updateMask)
    }
}
