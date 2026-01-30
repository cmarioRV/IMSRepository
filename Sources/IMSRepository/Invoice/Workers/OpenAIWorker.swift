//
//  OpenAIWorker.swift
//  IMSRepository
//
//  Created by Mario Rúa on 10/08/25.
//
import OpenAI
import Vapor

typealias OpenAIConvertible = Decodable & Sendable & JSONSchemaConvertible

protocol OpenAIWorkerProtocol {
    func request<T: OpenAIConvertible>(model: OpenAIModel) async throws -> T
}

enum OpenAIModel {
    case query(systemMessage: String, userMessage: String, model: Model, temperature: Double? = nil)
    case response(userMessage: String, model: Model, temperature: Double? = nil)
}

actor OpenAIWorker: OpenAIWorkerProtocol {
    let client: OpenAI
    
    init() throws {
        guard let openAiToken = Environment.get("OPENAI_BEARER_TOKEN") else {
            throw InvoiceRepositoryError.notAuthorized("OpenAI API token not found")
        }
        
        client = OpenAI(apiToken: openAiToken)
    }
    
    func request<T: OpenAIConvertible>(model: OpenAIModel) async throws -> T {
        switch model {
        case .query(systemMessage: let systemMessage, userMessage: let userMessage, let model, let temperature):
            return try await requestWithChatQuery(systemMessage: systemMessage, userMessage: userMessage, model: model)
        case .response(userMessage: let userMessage, let model, let temperature):
            return try await requestWithResponseQuery(userMessage: userMessage, model: model, temperature: temperature)
        }
    }
    
    private func requestWithChatQuery<T: OpenAIConvertible>(systemMessage: String, userMessage: String, model: Model, temperature: Double? = nil) async throws -> T {
        let query = ChatQuery(
            messages: [
                .system(.init(content: .textContent(systemMessage))),
                .user(.init(content: .string(userMessage)))
            ],
            model: model,
            responseFormat: .jsonSchema(
                .init(
                    name: "invoice-info",
                    description: nil,
                    schema: .derivedJsonSchema(T.self),
                    strict: true
                )
            ),
            temperature: temperature
        )
        
        let response = try await client.chats(query: query)
  
        guard let jsonData = response.choices.first?.message.content?.data(using: .utf8) else {
            throw InvoiceRepositoryError.errorFormattingResponse
        }
        
        let result = try JSONDecoder().decode(T.self, from: jsonData)
        return result
    }
    
    private func requestWithResponseQuery<T: OpenAIConvertible>(userMessage: String, model: Model, temperature: Double? = nil) async throws -> T {
        let query = CreateModelResponseQuery(input: .textInput(userMessage), model: model, temperature: temperature)
        
        let response: ResponseObject = try await client.responses.createResponse(query: query)
        
        var resultMessage: String = ""
        for output in response.output {
            switch output {
            case .outputMessage(let message):
                for content in message.content {
                    switch content {
                    case .OutputTextContent(let textContent):
                        resultMessage += textContent.text
                    case .RefusalContent(let refusalContent):
                        print(refusalContent)
                    @unknown default:
                        break
                    }
                }
            default:
                break
            }
        }
        
        guard let jsonData = resultMessage.data(using: .utf8) else {
            throw InvoiceRepositoryError.errorFormattingResponse
        }

        let result = try JSONDecoder().decode(T.self, from: jsonData)
        return result
    }
}

