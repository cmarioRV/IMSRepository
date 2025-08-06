//
//  ChatCompletionRequestDTO.swift
//  server
//
//  Created by Mario Rúa on 5/08/25.
//
import Vapor

struct ChatCompletionRequestDTO: Content {
    let model: String
    let messages: [ChatMessageDTO]
    let temperature: Double?
}


