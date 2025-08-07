//
//  ProductKnowledgeBase.swift
//  IMSDomain
//
//  Created by Mario Rúa on 6/08/25.
//

import Foundation
import NaturalLanguage
import IMSDomain

// MARK: - Product Knowledge Base

public struct ProductKnowledgeBase {
    // Synonyms and brand variations
    static let brandSynonyms: [String: [String]] = [
        "cafe": ["omacafe", "nescafe", "sello rojo", "colcafe", "juan valdez"],
        "aceite": ["premier", "gourmet", "la penca", "girasol"],
        "arroz": ["roa", "florhuila", "diana", "supremo"],
        "azucar": ["manuelita", "incauca", "providencia"],
        "sal": ["refisal", "salinas", "bahia"],
        "pasta": ["doria", "la muñeca", "zenú", "pastas la italiana"],
        "leche": ["colanta", "alpina", "parmalat", "algarra"],
        "pan": ["bimbo", "panrico", "la gran parada"]
    ]
    
    // Category-specific keywords
    static let categoryKeywords: [String: [String]] = [
        "bebidas": ["cafe", "té", "jugo", "gaseosa", "agua"],
        "lacteos": ["leche", "queso", "yogurt", "mantequilla", "crema"],
        "carnes": ["pollo", "res", "cerdo", "pescado", "chorizo"],
        "granos": ["arroz", "frijol", "lenteja", "garbanzo", "quinoa"],
        "condimentos": ["sal", "pimienta", "oregano", "comino", "ajo"],
        "aceites": ["aceite", "manteca", "margarina"],
        "harinas": ["harina", "maicena", "avena", "pan"],
        "dulces": ["azucar", "miel", "panela", "chocolate"]
    ]
    
    // Common units and their variations
    static let unitVariations: [String: [String]] = [
        "kilogramo": ["kg", "kilo", "kilos"],
        "gramo": ["g", "gr", "grs"],
        "litro": ["l", "lt", "lts"],
        "mililitro": ["ml", "cc"],
        "unidad": ["unid", "pza", "pieza"],
        "libra": ["lb", "lbs"]
    ]
    
    // Words to ignore during matching
    static let stopWords: Set<String> = [
        "de", "del", "la", "el", "en", "con", "sin", "para", "por",
        "un", "una", "y", "o", "a", "e", "premium", "especial",
        "natural", "organico", "tradicional", "casero", "x"
    ]
}
