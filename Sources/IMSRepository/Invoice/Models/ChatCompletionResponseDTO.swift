//
//  ChatCompletionResponseDTO.swift
//  server
//
//  Created by Mario Rúa on 5/08/25.
//
import Vapor

struct ChatCompletionResponseDTO: Content {
    struct ChoiceDTO: Content {
        struct MessageDTO: Content {
            let role: String
            let content: String
        }

        let index: Int
        let message: MessageDTO
        let finish_reason: String
    }

    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [ChoiceDTO]
}
