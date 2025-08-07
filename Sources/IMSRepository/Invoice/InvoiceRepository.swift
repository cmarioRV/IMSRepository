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

public struct InvoiceRepository: InvoiceRepositoryProtocol {
    public init() {}
    
    public func getOCRText(from base64Image: String, client: any Client) async throws -> String {
//        let visionRequest = createGoogleVisionRequest(base64Image: base64Image)
//        
//        guard let googleApiKey = Environment.get("GOOGLE_VISION_API_KEY") else {
//            throw InvoiceRepositoryError.notAuthorized("Google Vision API token not found")
//        }
//        
//        return try await requestGoogleVisionOCR(client, googleApiKey, visionRequest)
        let ocrText = """
            PriceSmart
            PRICESMART Colombia S.A.S.
            Carrera 70 No 1-120 Belen
            Medellin, Colombia
            NIT: 900319753-3
            1
            297888 Pepperoni M
            45,900 B
            472978 OmaCafé
            41,500 F
            1
            333342 Almendra2lb
            44,900 B
            1
            46369 Wesson Canol
            79,900 B
            1
            490646 Burrata
            41,900 C
            SUBTOTAL
            TOTAL
            06 MAR 2025
            REVISADO
            254,100
            254,100
            VF
            AMEX
            254,100
            Cuenta #: XXXXXXXXXXXX7208
            EXP : 00/00
            NUM DEL LOTE:
            Cod. De Aut: 447155
            Nro de recibo: 085804
            CAMBIO
            Total Items:
            RESUMEN DE IMPUESTOS
            PLAN
            TOTAL BASE/IMP
            IMPUESTO
            B19% IVA
            170,700
            143,445
            27,255
            C 0% IVA
            41,900
            41,900
            0
            F 5% IVA
            41,500
            39,524
            1,976
            TOTAL
            254,100 224,869
            29,231
            ло
            5
            ****PLATINUM RESUMEN DE RECOMPENSA****
            Recompensa obtenida en transaccion:
            Total de Recompensa Anual:
            Balance:
            4,497
            4,497
            99,439
            Vence: 9/1/2025
            EN ESTA COMPRA USTED ACUMULO
            $8,995 SMARTCASH SI PAGO
            CON NUESTRA TARJETA DE CREDITO
            Asistido Por: 61063311
            Comprobante de Entrega: 0612 1237749
            Este documento solo tiene como propósito
            soportar la entrega de la mercancia.
            La Factura Electrónica que soporta esta
            transacción será enviada al correo
            electrónico el cual registra en su membrecia
            R00610600120068202503061107
            61061078550001
            """
        return ocrText
    }
    
    public func getInvoiceItems(from text: String, client: any Client) async throws -> [InvoiceGood] {
//        let prompt = PromptBuilder.getInvoiceItems(ocrText: text).getPrompt()
//        let request = createOpenAIRequest(systemPrompt: prompt.systemPrompt,
//                                                userPrompt: prompt.userPrompt)
//        
//        let invoice: InvoiceJsonResponseDTO = try await requestOpenAI(requestModel: request,
//                                                                      client: client)
//        return invoice.products
        return ModelsForDev.all()
    }
    
    public func getSimilarGoods(between invoiceItems: [InvoiceGood], and goods: [Good], client: any Client) async throws -> PairedGoods {
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
    
    public func getSimilarGoods(between invoiceItems: [IMSDomain.InvoiceGood], and goods: [IMSDomain.Good]) async throws -> IMSDomain.PairedGoods {
//        let calculator = ConcurrentLevenshteinCalculator()
//        let batch = await calculator.calculateDistances(invoiceGoods: invoiceItems, goods: goods)
//        
//        var pairedGoods: [PairedGood] = []
//        let result = batch.forEach { item in
//            pairedGoods.append(PairedGood(invoiceName: item.invoiceGood.name,
//                                          candidateMatches: item.results.prefix(3).map { $0.storedGood },
//                                          quantity: item.invoiceGood.quantity,
//                                          unitPrice: item.invoiceGood.unitPrice,
//                                          total: item.invoiceGood.total))
//        }
//        return .init(products: pairedGoods)
        let matchingEngine = EnhancedMatchingEngine()
        let items = await matchingEngine.findBestMatches(invoiceGoods: invoiceItems, goods: goods, maxResults: 3, minScore: 0.3, concurrencyLimit: 4)
        return .init(products: items)
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
