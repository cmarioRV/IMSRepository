//
//  InvoiceDataTransferObjects.swift
//  server
//
//  Created by Mario Rúa on 10/07/25.
//
import Vapor
import IMSDomain

struct InvoiceItemDTO: Content {
    var description: String?
    var quantity: Double?
    var unitPrice: Double?
}

struct ChatMessageDTO: Content {
    let role: String
    let content: String
}

struct InvoiceJsonResponseDTO: Content {
    var purchaseDate: String?
    var goods: [InvoiceGood]
    var provider: Provider?
}

extension InvoiceJsonResponseDTO {
    func toDomainModel() -> Invoice {
        .init(purchaseDate: purchaseDate,
              goods: goods,
              provider: provider)
    }
}

struct ProviderDTO: Content {
    var id: UUID?
    var createdAt: Date?
    var updatedAt: Date?
    var name: String
    var nit: String?
    var email: String?
    var address: String?
    var phone: String?
}

//extension ProviderDTO: DomainModelConvertible {
//    func toDomainModel() -> Provider {
//        .init(id: id,
//              createdAt: createdAt,
//              updatedAt: updatedAt,
//              name: name,
//              nit: nit,
//              email: email,
//              address: address,
//              phone: phone)
//    }
//}
//
//extension Provider: DTOConvertible {
//    func toDTO() -> ProviderDTO {
//        .init(id: id,
//              createdAt: createdAt,
//              updatedAt: updatedAt,
//              name: name,
//              nit: nit,
//              email: email,
//              address: address,
//              phone: phone)
//    }
//}
