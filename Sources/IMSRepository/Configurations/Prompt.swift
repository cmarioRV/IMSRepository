//
//  Prompts.swift
//  server
//
//  Created by Mario Rúa on 11/07/25.
//

fileprivate struct PromptStrings {
    static let getInvoiceSystemPrompt: String = """
        You are a helpful assistant with expertise in interpreting and matching product names, even when they differ in spelling or form. You are tasked with identifying semantic or approximate matches between items from two different sources, and returning a structured list of results based on the input instructions. Do not explain your reasoning — just return a plain valid JSON with the array of products. Do not use explanations, comments or markdown code blocks (like ```json). Example of the expected JSON:
                {
                  "products": [
                    {
                      "name": "string",
                      "quantity": number,
                      "unit": "string",
                      "unitPrice": number,
                      "total": number
                    }
                  ]
                }
"""
    
    static let getGoodsFromInvoiceSystemPrompt: String = """
        You are a helpful assistant with expertise in interpreting and matching product names, even when they differ in spelling or form. You are tasked with identifying semantic or approximate matches between items from two different sources, and returning a structured list of results based on the input instructions. Do not explain your reasoning — just return a plain valid JSON with the array of products. Do not use explanations, comments or markdown code blocks (like ```json). Example of the expected JSON:
            {
                "products": [
                    {
                        "invoiceName": String,
                        "possibleRelatedStoredGoods": [
                            {
                                "name": String
                            }
                        ]
                        "quantity": Float,
                        "unit": String,
                        "unitPrice": Double,
                        "total": Double,
                        "providers": [
                            {
                                "address": "Cra 74 52 90",
                                "phone": "3000",
                                "name": "OR"
                            }
                        ]
                    }
                ]
            }
        """
    
    static let getGoodsFromInvoiceUserPrompt: String = """
        I have two arrays of ingredients, one came from reading with OCR the purchase invoice, let's call it invoiceIngredients, for example:
        
        [
            {
                "name": "OmaCafé",
                "unitPrice": 45900,
                "unit": "g",
                "quantity": 1,
                "total": 45900
            }
        }
        
        and the other one is the array of ingredients that I already have stored in my DB, let's call it storedIngredients, in the form:
        
        [
            {
                "name": "Lechuga",
                "category": "vegetables",
                "unit": "g",
                "quantity": 12,
                "price": 1200,
                "providers": [
                    {
                        "address": "Cra 74 52 90",
                        "phone": "3000",
                        "name": "OR"
                    }
                ]
            }
        ]
        
        I need you to compare each ingredient from the invoiceIngredients array with the items in the storedIngredients array and determine whether they refer to the same product, even if their names are not exactly the same (for example, "Cafe" and "OmaCafe").

        Return a JSON with an array of objects, like this:
        {
            "products": [
                {
                    "invoiceName": String,
                    "possibleRelatedStoredGoods": [
                        {
                            "name": String
                        }
                    ]
                    "quantity": Float,
                    "unitPrice": Double,
                    "total": Double,
                    "providers": [
                        {
                            "address": "Cra 74 52 90",
                            "phone": "3000",
                            "name": "OR"
                        }
                    ]
                }
            ]
        }
        
        Rules:

        If you believe an ingredient from invoiceIngredients matches or is very similar to one or more ingredients in storedIngredients, create the object described before.
        If no clear match is found, create the object described before with an empty possibleRelatedStoredGoods array property.
        The properties "quantity", "unitPrice" and "total" are extracted from the invoiceIngredient.
        The property "providers" is extracted from storedIngredient.

        Respond only with the final result — do not include explanations.
        """
}

enum PromptBuilder {
    case getSimilarGoods(jsonInvoiceItems: String, jsonStoredItems: String)
    case getInvoiceItems(ocrText: String)
    
    func getPrompt() -> Prompt {
        switch self {
        case .getSimilarGoods(let invoiceItems, let goods):
            return .init(systemPrompt: PromptStrings.getGoodsFromInvoiceSystemPrompt,
                         userPrompt: "\(PromptStrings.getGoodsFromInvoiceUserPrompt) invoiceItems: \(invoiceItems), goods: \(goods)")
        case .getInvoiceItems(ocrText: let ocrText):
            return .init(systemPrompt: PromptStrings.getInvoiceSystemPrompt, userPrompt: ocrText)
        }
    }
}

struct Prompt {
    let systemPrompt: String
    let userPrompt: String
}
