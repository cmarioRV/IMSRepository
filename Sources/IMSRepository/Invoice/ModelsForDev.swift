//
//  ModelsForDev.swift
//  IMSRepository
//
//  Created by Mario Rúa on 7/08/25.
//
import IMSDomain

public struct ModelsForDev {
    public static func all() -> [InvoiceGood] {
        return [.init(name: "Pepperoni M", quantity: 1, unit: "B", unitPrice: 45900, total: 45900),
                .init(name: "OmaCafé", quantity: 1, unit: "F", unitPrice: 41500, total: 41500),
                .init(name: "Almendra 2lb", quantity: 1, unit: "B", unitPrice: 44900, total: 44900),
                .init(name: "Wesson Canol", quantity: 1, unit: "B", unitPrice: 79900, total: 79900),
                .init(name: "Burrata", quantity: 1, unit: "C", unitPrice: 41900, total: 41900),
                .init(name: "CAFE INST NESCAF", quantity: 1, unit: "E", unitPrice: 59500, total: 59500),
                .init(name: "PASTA TOMATE ARO", quantity: 1, unit: "A", unitPrice: 58650, total: 58650),
                .init(name: "CALDO COSTILLA A", quantity: 1, unit: "A", unitPrice: 66600, total: 66600),
                .init(name: "GALLET CLUB SOCI", quantity: 1, unit: "A", unitPrice: 7950, total: 7950),
                .init(name: "CAFE GRANO OMA E", quantity: 1, unit: "E", unitPrice: 50750, total: 50750),
                .init(name: "CEREZA LACORUNA", quantity: 1, unit: "A", unitPrice: 53300, total: 53300),
                .init(name: "SALSA PESCADO SQ", quantity: 1, unit: "A", unitPrice: 16900, total: 16900),
                .init(name: "QUESO CREMA COLA", quantity: 1, unit: "EXE", unitPrice: 10600, total: 10600)]
    }
}
