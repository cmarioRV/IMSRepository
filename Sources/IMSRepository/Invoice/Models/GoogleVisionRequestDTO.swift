//
//  GoogleVisionRequestDTO.swift
//  server
//
//  Created by Mario Rúa on 5/08/25.
//
import Vapor

struct GoogleVisionRequestDTO: Content {
    let requests: [Request]

    struct Request: Content {
        let image: Image
        let features: [Feature]
    }

    struct Image: Content {
        let content: String  // base64-encoded image
    }

    struct Feature: Content {
        let type: String
    }
}


