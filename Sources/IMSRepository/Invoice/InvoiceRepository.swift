//
//  InvoiceRepository.swift
//  IMSRepository
//
//  Created by Mario Rúa on 5/08/25.
//
import Vapor
import IMSDomain

enum InvoiceRepositoryError: Error {
    case notAuthorized(String)
    case errorFormattingResponse
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                  return nil
               }

        return prettyJSON
    }
}

struct InvoiceRepository: InvoiceRepositoryProtocol {
    func getOCRText(from base64Image: String, client: any Client) async throws -> String {
        let visionRequest = createGoogleVisionRequest(base64Image: base64Image)
        
        guard let googleApiKey = Environment.get("GOOGLE_VISION_API_KEY") else {
            throw InvoiceRepositoryError.notAuthorized("Google Vision API token not found")
        }
        
        return try await requestGoogleVisionOCR(client, googleApiKey, visionRequest)
    }
    
    func getInvoiceItems(from text: String, client: any Client) async throws -> [InvoiceGood] {
        let prompt = PromptBuilder.getInvoiceItems(ocrText: text).getPrompt()
        let request = createOpenAIRequest(systemPrompt: prompt.systemPrompt,
                                                userPrompt: prompt.userPrompt)
        
        let invoice: InvoiceJsonResponseDTO = try await requestOpenAI(requestModel: request,
                                                                      client: client)
        return invoice.products
    }
    
    func getSimilarGoods(between invoiceItems: [InvoiceGood], and goods: [Good], client: any Client) async throws -> PairedGoods {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let invoiceItemsJsonData = try encoder.encode(invoiceItems)
        let invoiceItemsJsonString = String(data: invoiceItemsJsonData, encoding: .utf8)
        
        let goodsItemsJsonData = try encoder.encode(goods)
        let goodItemsJsonString = String(data: goodsItemsJsonData, encoding: .utf8)
        
        guard let invoiceItemsJsonString = invoiceItemsJsonString else {
            throw InvoiceRepositoryError.errorFormattingResponse
        }
        
        guard let goodItemsJsonString = goodItemsJsonString else {
            throw InvoiceRepositoryError.errorFormattingResponse
        }
        
        let prompt = PromptBuilder.getSimilarGoods(jsonInvoiceItems: invoiceItemsJsonString,
                                                   jsonStoredItems: goodItemsJsonString)
            .getPrompt()
        let request = createOpenAIRequest(systemPrompt: prompt.systemPrompt,
                                          userPrompt: prompt.userPrompt)
        return try await requestOpenAI(requestModel: request, client: client)
    }
}

private extension InvoiceRepository {
    private func createGoogleVisionRequest(base64Image: String) -> GoogleVisionRequestDTO {
        return .init(requests: [
            .init(
                image: .init(content: base64Image),
                features: [.init(type: "TEXT_DETECTION")]
            )
        ])
    }
    
    private func createOpenAIRequest(systemPrompt: String, userPrompt: String, temperature: Double = 0.5) -> ChatCompletionRequestDTO {
        return .init(
            model: "gpt-4o",
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: temperature
        )
    }
    
    private func requestGoogleVisionOCR(_ client: any Client, _ googleApiKey: String, _ visionRequest: GoogleVisionRequestDTO) async throws -> String {
        let response = try await client.post(
            URI(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleApiKey)")
        ) { req in
            try req.content.encode(visionRequest)
        }
        
        let result = try response.content.decode(GoogleVisionResponseDTO.self)
        let extractedText = result.responses.first?.textAnnotations?.first?.description ?? ""
        return extractedText
    }
    
    private func requestOpenAI<T: Decodable>(requestModel: ChatCompletionRequestDTO, client: any Client) async throws -> T {
        
        guard let openAiToken = Environment.get("OPENAI_BEARER_TOKEN") else {
            throw InvoiceRepositoryError.notAuthorized("OpenAI API token not found")
        }
        
        let response = try await client.post("https://api.openai.com/v1/chat/completions") { req in
            try req.content.encode(requestModel)
            req.headers.bearerAuthorization = .init(token: openAiToken)
        }
        
        let result = try response.content.decode(ChatCompletionResponseDTO.self)
        let content = result.choices.first?.message.content ?? ""
        let jsonData = content.data(using: .utf8)!
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
