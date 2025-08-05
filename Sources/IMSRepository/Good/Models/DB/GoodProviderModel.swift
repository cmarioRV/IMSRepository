//
//  GoodProvider.swift
//  server
//
//  Created by Mario Rúa on 7/07/25.
//
import Vapor
import Fluent

public final class GoodProviderModel: DatabaseModel, @unchecked Sendable {
    public static let schema = Create_20250707.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: Create_20250707.goodId)
    var good: GoodModel
    
    @Parent(key: Create_20250707.providerId)
    var provider: ProviderModel
    
    public init() { }
    
    init(id: UUID? = nil, goodId: UUID, providerId: UUID) {
        self.id = id
        self.$good.id = goodId
        self.$provider.id = providerId
    }
}

extension GoodProviderModel {
    enum Create_20250707 {
        static let schema = "good_provider"
        
        static let goodId: FieldKey = .goodId
        static let providerId: FieldKey = .providerId
    }
}
