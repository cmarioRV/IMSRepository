//
//  EnhancedMatchingEngine.swift
//  IMSRepository
//
//  Created by Mario Rúa on 7/08/25.
//
import Foundation
import NaturalLanguage
import IMSDomain

public actor EnhancedMatchingEngine {
    public init() {}
    
    // MARK: - Main Matching Function
    
    public func findBestMatches(
        for invoiceGood: InvoiceGood,
        in goods: [Good],
        maxResults: Int = 5,
        minScore: Double = 0.3
    ) async -> [GoodMatchResult] {
        var allResults: [GoodMatchResult] = []
        
        // Strategy 1: Exact Match
        let exactMatches = await findExactMatches(productName: invoiceGood.name, goods: goods)
        allResults.append(contentsOf: exactMatches)
        
        // Strategy 2: Brand-Aware Matching
//        let brandMatches = await findBrandAwareMatches(productName: invoiceGood.name, goods: goods)
//        allResults.append(contentsOf: brandMatches)
        
        // Strategy 3: Token-Based Matching
        let tokenMatches = await findTokenBasedMatches(productName: invoiceGood.name, goods: goods)
        allResults.append(contentsOf: tokenMatches)
        
        // Strategy 4: Phonetic Matching
        let phoneticMatches = await findPhoneticMatches(productName: invoiceGood.name, goods: goods)
        allResults.append(contentsOf: phoneticMatches)
        
        // Strategy 5: Semantic Matching (simplified)
        let semanticMatches = await findSemanticMatches(productName: invoiceGood.name, goods: goods)
        allResults.append(contentsOf: semanticMatches)
        
        // Strategy 6: Levenshtein (fallback)
        let levenshteinMatches = await findLevenshteinMatches(invoiceGood: invoiceGood, goods: goods)
        allResults.append(contentsOf: levenshteinMatches)
        
        // Strategy 7: Substring
        let substringMatches = findSubstringMatches(invoiceGood: invoiceGood, goods: goods, minScore: minScore)
        allResults.append(contentsOf: substringMatches)
        
        // Combine and rank results
        return await combineAndRankResults(allResults, minScore: minScore, maxResults: maxResults)
    }
    
    /// Process a single InvoiceGood with timing
       private func processSingleInvoiceGood(
           invoiceGood: InvoiceGood,
           goods: [Good],
           maxResults: Int,
           minScore: Double
       ) async -> BatchMatchResult {
           let startTime = CFAbsoluteTimeGetCurrent()
           
           let matches = await findBestMatches(
               for: invoiceGood,
               in: goods,
               maxResults: maxResults,
               minScore: minScore
           )
           
           let processingTime = CFAbsoluteTimeGetCurrent() - startTime
           
           return BatchMatchResult(
               invoiceGood: invoiceGood,
               matches: matches,
               processingTime: processingTime
           )
       }
    
    public func findBestMatches(
            invoiceGoods: [InvoiceGood],
            goods: [Good],
            maxResults: Int,
            minScore: Double,
            concurrencyLimit: Int
        ) async -> [PairedGood] {
            let matches = await withTaskGroup(of: BatchMatchResult?.self, returning: [BatchMatchResult].self) { group in
                var results: [BatchMatchResult] = []
                results.reserveCapacity(invoiceGoods.count)
                
                // Add tasks to the group with concurrency control
                let semaphore = AsyncSemaphore(value: concurrencyLimit)
                
                for invoiceGood in invoiceGoods {
                    group.addTask { [weak self] in
                        await semaphore.wait()
                        defer {
                            Task { [weak semaphore] in
                                await semaphore?.signal() }
                        }
                        
                        return await self?.processSingleInvoiceGood(
                            invoiceGood: invoiceGood,
                            goods: goods,
                            maxResults: maxResults,
                            minScore: minScore
                        )
                    }
                }
                
                for await result in group {
                    if let result = result {
                        results.append(result)
                    }
                }
                
                return results
            }
            
            let items = matches.map { result in
                PairedGood(invoiceName: result.invoiceGood.name,
                           candidateMatches: result.matches,
                           quantity: result.invoiceGood.quantity,
                           unitPrice: result.invoiceGood.unitPrice,
                           total: result.invoiceGood.total)
            }
            return items
        }
    
    // MARK: - Strategy Implementations
    
    private func findExactMatches(productName: String, goods: [Good]) async -> [GoodMatchResult] {
        let normalizedInput = normalizeString(productName)
        return goods.compactMap { good in
            let normalizedProduct = normalizeString(good.name)
            if normalizedInput == normalizedProduct {
                return GoodMatchResult(
                    candidateGood: good,
                    score: 1.0,
                    confidence: .high,
                    strategy: .exact,
                    details: GoodMatchDetail(explanation: "Exact match after normalization")
                )
            }
            return nil
        }
    }
    
    private func findBrandAwareMatches(productName: String, goods: [Good]) async -> [GoodMatchResult] {
        let inputTokens = tokenize(productName)
        var results: [GoodMatchResult] = []
        
        for good in goods {
            let productTokens = tokenize(good.name)
            var brandScore = 0.0
            var matchedBrands: [String] = []
            
            // Check if input contains a brand name
            for (category, brands) in ProductKnowledgeBase.brandSynonyms {
                let categoryMatch = productTokens.contains { token in
                    ProductKnowledgeBase.categoryKeywords.values.flatMap { $0 }.contains(token.lowercased())
                }
                
                if categoryMatch {
                    for brand in brands {
                        if inputTokens.contains(where: { $0.lowercased().contains(brand.lowercased()) }) {
                            brandScore = 0.9
                            matchedBrands.append(brand)
                            break
                        }
                    }
                }
            }
            
            if brandScore > 0 {
                results.append(GoodMatchResult(
                    candidateGood: good,
                    score: brandScore,
                    confidence: .high,
                    strategy: .brandAware,
                    details: GoodMatchDetail(
                        brandMatchScore: brandScore,
                        explanation: "Brand match: \(matchedBrands.joined(separator: ", "))"
                    )
                ))
            }
        }
        
        return results
    }
    
    private func findTokenBasedMatches(productName: String, goods: [Good]) async -> [GoodMatchResult] {
        let inputTokens = Set(tokenize(productName).map { $0.lowercased() })
        var results: [GoodMatchResult] = []
        
        for good in goods {
            let productTokens = Set(tokenize(good.name).map { $0.lowercased() })
            
            // Calculate Jaccard similarity
            let intersection = inputTokens.intersection(productTokens)
            let union = inputTokens.union(productTokens)
            
            let jaccardScore = union.isEmpty ? 0.0 : Double(intersection.count) / Double(union.count)
            
            // Boost score for important tokens
            var boostedScore = jaccardScore
            let importantMatches = intersection.filter { token in
                !ProductKnowledgeBase.stopWords.contains(token) && token.count > 2
            }
            
            if !importantMatches.isEmpty {
                boostedScore += Double(importantMatches.count) * 0.1
                boostedScore = min(boostedScore, 1.0)
            }
            
            if boostedScore > 0.3 {
                results.append(GoodMatchResult(
                    candidateGood: good,
                    score: boostedScore,
                    confidence: determineConfidence(boostedScore),
                    strategy: .tokenBased,
                    details: GoodMatchDetail(
                        tokenMatchScore: boostedScore,
                        explanation: "Token match: \(intersection.joined(separator: ", "))"
                    )
                ))
            }
        }
        
        return results
    }
    
    private func findPhoneticMatches(productName: String, goods: [Good]) async -> [GoodMatchResult] {
        let inputSoundex = soundex(productName)
        var results: [GoodMatchResult] = []
        
        for good in goods {
            let productSoundex = soundex(good.name)
            let phoneticScore = comparePhonetically(inputSoundex, productSoundex)
            
            if phoneticScore > 0.6 {
                results.append(GoodMatchResult(
                    candidateGood: good,
                    score: phoneticScore,
                    confidence: determineConfidence(phoneticScore),
                    strategy: .phonetic,
                    details: GoodMatchDetail(
                        phoneticScore: phoneticScore,
                        explanation: "Phonetic similarity"
                    )
                ))
            }
        }
        
        return results
    }
    
    private func findSemanticMatches(productName: String, goods: [Good]) async -> [GoodMatchResult] {
        // Simplified semantic matching using category inference
        let inputCategory = inferCategory(from: productName)
        var results: [GoodMatchResult] = []
        
        for good in goods {
            let productCategory = inferCategory(from: good.name)
            
            if inputCategory == productCategory && inputCategory != "unknown" {
                let semanticScore = calculateCategorySemanticScore(
                    input: productName,
                    product: good.name,
                    category: inputCategory
                )
                
                if semanticScore > 0.4 {
                    results.append(GoodMatchResult(
                        candidateGood: good,
                        score: semanticScore,
                        confidence: determineConfidence(semanticScore),
                        strategy: .semantic,
                        details: GoodMatchDetail(
                            semanticScore: semanticScore,
                            explanation: "Semantic match in category: \(inputCategory)"
                        )
                    ))
                }
            }
        }
        
        return results
    }
    
    private func findLevenshteinMatches(invoiceGood: InvoiceGood, goods: [Good]) async -> [GoodMatchResult] {
        let levenshteinCalculator = LevenshteinCalculator()
        let levenshteinResults = await levenshteinCalculator.findBestMatches(invoiceGood: invoiceGood, goods: goods, maxResults: 10, normalizedThreshold: 0.7)
        
        return levenshteinResults.compactMap { result in
            let product = result.storedGood
            
            let score = 1.0 - result.normalizedDistance
            return GoodMatchResult(
                candidateGood: product,
                score: score,
                confidence: determineConfidence(score),
                strategy: .levenshtein,
                details: GoodMatchDetail(
                    levenshteinScore: score,
                    explanation: "Levenshtein distance: \(result.distance)"
                )
            )
        }
    }
        
    private func findSubstringMatches(invoiceGood: InvoiceGood, goods: [Good], minScore: Double) -> [GoodMatchResult] {
        let invoiceGoodLength = invoiceGood.name.count
        var results: [GoodMatchResult] = []
        for good in goods {
            let goodLength = good.name.count
            
            guard invoiceGoodLength > 0 && goodLength > 0 else { continue }
            
            let shorter = invoiceGoodLength < goodLength ? invoiceGood.name : good.name
            let longer = invoiceGoodLength < goodLength ? good.name : invoiceGood.name
            
            if longer.contains(shorter) {
                let score = Double(shorter.count) / Double(longer.count)
                let result = GoodMatchResult(
                    candidateGood: good,
                    score: score,
                    confidence: determineConfidence(score),
                    strategy: .substring,
                    details: GoodMatchDetail(explanation: "Substring"))
                results.append(result)
                continue
            }
            
            // Check for partial matches
            var maxMatch = 0
            let shorterLength = shorter.count
            
            for i in 0..<shorterLength {
                for j in i+1...shorterLength {
                    let substring = String(shorter[shorter.index(shorter.startIndex, offsetBy: i)..<shorter.index(shorter.startIndex, offsetBy: j)])
                    if substring.count >= 3 && longer.contains(substring) {
                        maxMatch = max(maxMatch, substring.count)
                    }
                }
            }
            
            let score = Double(maxMatch) / Double(max(invoiceGoodLength, goodLength))
            let result = GoodMatchResult(
                candidateGood: good,
                score: score,
                confidence: determineConfidence(score),
                strategy: .substring,
                details: GoodMatchDetail(explanation: "Substring"))
            results.append(result)
        }
        
        return results
            .filter { $0.score >= minScore }
            .sorted { $0.score > $1.score }
            .map { $0 }
    }
    
    // MARK: - Helper Functions
    
    private func combineAndRankResults(_ results: [GoodMatchResult], minScore: Double, maxResults: Int) async -> [GoodMatchResult] {
        // Group by product to avoid duplicates
        var productResults: [String: GoodMatchResult] = [:]
        
        for result in results {
            var productId: String
            if let id = result.candidateGood.id {
                productId = id.uuidString
            } else {
                productId = result.candidateGood.name
            }
            
            if let existing = productResults[productId] {
                // Keep the result with the highest score
                if result.score > existing.score {
                    productResults[productId] = result
                }
            } else {
                productResults[productId] = result
            }
        }
        
        return productResults.values
            .filter { $0.score >= minScore }
            .sorted { $0.score > $1.score }
            .prefix(maxResults)
            .map { $0 }
    }
    
    private func normalizeString(_ string: String) -> String {
        return string.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func tokenize(_ string: String) -> [String] {
        let normalized = normalizeString(string)
        return normalized.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty && !ProductKnowledgeBase.stopWords.contains($0) }
    }
    
    private func soundex(_ string: String) -> String {
        // Simplified Soundex implementation
        let normalized = string.uppercased().replacingOccurrences(of: "[^A-Z]", with: "", options: .regularExpression)
        guard !normalized.isEmpty else { return "0000" }
        
        var soundex = String(normalized.first!)
        let mappings: [Character: Character] = [
            "B": "1", "F": "1", "P": "1", "V": "1",
            "C": "2", "G": "2", "J": "2", "K": "2", "Q": "2", "S": "2", "X": "2", "Z": "2",
            "D": "3", "T": "3",
            "L": "4",
            "M": "5", "N": "5",
            "R": "6"
        ]
        
        for char in normalized.dropFirst() {
            if let mapped = mappings[char] {
                if soundex.last != mapped {
                    soundex.append(mapped)
                }
            }
        }
        
        soundex = String(soundex.padding(toLength: 4, withPad: "0", startingAt: 0).prefix(4))
        return soundex
    }
    
    private func comparePhonetically(_ soundex1: String, _ soundex2: String) -> Double {
        let commonChars = zip(soundex1, soundex2).reduce(0) { $1.0 == $1.1 ? $0 + 1 : $0 }
        return Double(commonChars) / 4.0
    }
    
    private func inferCategory(from productName: String) -> String {
        let tokens = tokenize(productName)
        
        for (category, keywords) in ProductKnowledgeBase.categoryKeywords {
            for keyword in keywords {
                if tokens.contains(where: { $0.lowercased().contains(keyword) }) {
                    return category
                }
            }
        }
        
        return "unknown"
    }
    
    private func calculateCategorySemanticScore(input: String, product: String, category: String) -> Double {
        let inputTokens = Set(tokenize(input))
        let productTokens = Set(tokenize(product))
        let categoryKeywords = Set(ProductKnowledgeBase.categoryKeywords[category] ?? [])
        
        // Base score from token intersection
        let intersection = inputTokens.intersection(productTokens)
        let baseScore = intersection.isEmpty ? 0.0 : Double(intersection.count) / Double(max(inputTokens.count, productTokens.count))
        
        // Boost for category-specific terms
        let categoryBoost = intersection.intersection(categoryKeywords).isEmpty ? 0.0 : 0.2
        
        return min(baseScore + categoryBoost, 1.0)
    }
    
    private func determineConfidence(_ score: Double) -> MatchConfidence {
        switch score {
        case 0.85...1.0: return .high
        case 0.70..<0.85: return .medium
        case 0.50..<0.70: return .low
        default: return .veryLow
        }
    }
}

struct SemaphoreTimeoutError: Error { }

// MARK: - AsyncSemaphore for Concurrency Control

actor AsyncSemaphore {
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []
    
    init(value: Int) {
        self.count = value
    }
    
//    func wait(timeout: TimeInterval = 30) async {
//        if count > 0 {
//            count -= 1
//            return
//        }
//        
//        do {
//            try await withThrowingTaskGroup(of: Void.self) { group in
//                group.addTask { [weak self] in
//                    guard let self = self else { return }
//                    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
//                        Task { [weak self] in
//                            await self?.addWaiter(continuation)
//                        }
//                    }
//                }
//                
//                group.addTask {
//                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
//                    throw SemaphoreTimeoutError()
//                }
//                
//                try await group.next()
//                group.cancelAll()
//            }
//        } catch {}
//    }
    
    @available(*, deprecated, message: "Use wait(timeout:) instead")
    func wait() async {
        if count > 0 {
            count -= 1
        } else {
            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }
    }
    
    func signal() {
        if waiters.isEmpty {
            count += 1
        } else {
            let waiter = waiters.removeFirst()
            waiter.resume()
        }
    }
    
    private func addWaiter(_ continuation: CheckedContinuation<Void, Never>) {
        waiters.append(continuation)
    }
}

struct BatchMatchResult: Sendable {
    let invoiceGood: InvoiceGood
    let matches: [GoodMatchResult]
    let processingTime: TimeInterval
    let bestMatch: GoodMatchResult?

    init(invoiceGood: InvoiceGood, matches: [GoodMatchResult], processingTime: TimeInterval) {
        self.invoiceGood = invoiceGood
        self.matches = matches
        self.processingTime = processingTime
        self.bestMatch = matches.first
    }
}
