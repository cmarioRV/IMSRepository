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
    var products: [InvoiceGood]
}

