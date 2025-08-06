//
//  GoogleVisionResponseDTO.swift
//  server
//
//  Created by Mario Rúa on 5/08/25.
//
import Vapor

struct GoogleVisionResponseDTO: Content {
    struct Response: Content {
        struct Annotation: Content {
            let description: String
        }

        let textAnnotations: [Annotation]?
    }

    let responses: [Response]
}
