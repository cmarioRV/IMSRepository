//
//  Levenstein.swift
//  IMSDomain
//
//  Created by Mario Rúa on 5/08/25.
//
import Foundation
import IMSDomain

// MARK: - Original Helper Functions and Extensions

public func min3(a: Int, b: Int, c: Int) -> Int {
    return min(min(a, c), min(b, c))
}

public struct Array2D {
    var columns: Int
    var rows: Int
    var matrix: [Int]
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        matrix = Array(repeating: 0, count: columns * rows)
    }
    
    subscript(column: Int, row: Int) -> Int {
        get {
            return matrix[columns * row + column]
        }
        set {
            matrix[columns * row + column] = newValue
        }
    }
    
    func columnCount() -> Int {
        return self.columns
    }
    
    func rowCount() -> Int {
        return self.rows
    }
}

// MARK: - Original Levenshtein Functions

public func levenshtein(sourceString: String, target targetString: String) -> Int {
    let source = Array(sourceString.unicodeScalars)
    let target = Array(targetString.unicodeScalars)
    let (sourceLength, targetLength) = (source.count, target.count)
    var distance = Array2D(columns: sourceLength + 1, rows: targetLength + 1)
    
    for x in 1...sourceLength {
        distance[x, 0] = x
    }
    
    for y in 1...targetLength {
        distance[0, y] = y
    }
    
    for x in 1...sourceLength {
        for y in 1...targetLength {
            if source[x - 1] == target[y - 1] {
                distance[x, y] = distance[x - 1, y - 1]
            } else {
                distance[x, y] = min3(
                    a: distance[x - 1, y] + 1,
                    b: distance[x, y - 1] + 1,
                    c: distance[x - 1, y - 1] + 1
                )
            }
        }
    }
    
    return distance[source.count, target.count]
}

// MARK: - Result Types

public struct LevenshteinResult: Sendable {
    public let invoiceGood: InvoiceGood
    public let storedGood: Good
    public let distance: Int
    public let normalizedDistance: Double
    
    public init(invoiceGood: InvoiceGood, storedGood: Good, distance: Int) {
        self.invoiceGood = invoiceGood
        self.storedGood = storedGood
        self.distance = distance
        self.normalizedDistance = Self.calculateNormalizedDistance(
            distance: distance,
            sourceLength: invoiceGood.name.count,
            targetLength: storedGood.name.count
        )
    }
    
    private static func calculateNormalizedDistance(distance: Int, sourceLength: Int, targetLength: Int) -> Double {
        let maxLength = max(sourceLength, targetLength)
        return maxLength == 0 ? 0.0 : Double(distance) / Double(maxLength)
    }
}

public struct LevenshteinBatch: Sendable {
    public let invoiceGood: InvoiceGood
    public let results: [LevenshteinResult]
    
    public init(invoiceGood: InvoiceGood, results: [LevenshteinResult]) {
        self.invoiceGood = invoiceGood
        self.results = results
    }
    
    // Sorted results by distance (best matches first)
    public var sortedByDistance: [LevenshteinResult] {
        return results.sorted { $0.distance < $1.distance }
    }
    
    // Get best matches below a threshold
    public func bestMatches(threshold: Double = 0.5) -> [LevenshteinResult] {
        return results.filter { $0.normalizedDistance <= threshold }
                     .sorted { $0.distance < $1.distance }
    }
}

// MARK: - Concurrent Levenshtein Calculator

actor LevenshteinCalculator {
    /// Calculate Levenshtein distance concurrently for multiple source strings
    func calculateDistances(invoiceGoods: [InvoiceGood], goods: [Good]) async -> [LevenshteinBatch] {
        return await withTaskGroup(of: LevenshteinBatch.self, returning: [LevenshteinBatch].self) { group in
            var batches: [LevenshteinBatch] = []
            batches.reserveCapacity(invoiceGoods.count)
            
            for invoiceGood in invoiceGoods {
                group.addTask { [self] in
                    return await self.calculateDistances(invoiceGood: invoiceGood, goods: goods)
                }
            }
            
            for await batch in group {
                batches.append(batch)
            }
            
            return batches
        }
    }
    
    /// Calculate Levenshtein distance concurrently for one source string against a dictionary
    public func calculateDistances(invoiceGood: InvoiceGood, goods: [Good]) async -> LevenshteinBatch {
        let results = await withTaskGroup(of: LevenshteinResult.self, returning: [LevenshteinResult].self) { group in
            var results: [LevenshteinResult] = []
            results.reserveCapacity(goods.count)
            
            for good in goods {
                group.addTask {
                    let distance = levenshtein(sourceString: invoiceGood.name, target: good.name)
                    return LevenshteinResult(invoiceGood: invoiceGood, storedGood: good, distance: distance)
                }
            }
            
            for await result in group {
                results.append(result)
            }
            
            return results
        }
        
        return LevenshteinBatch(invoiceGood: invoiceGood, results: results)
    }
    
    /// Find best matches for a source string with configurable thresholds
    public func findBestMatches(
        invoiceGood: InvoiceGood,
        goods: [Good],
        maxResults: Int = 10,
        normalizedThreshold: Double = 0.7
    ) async -> [LevenshteinResult] {
        let batch = await calculateDistances(invoiceGood: invoiceGood, goods: goods)
        
        return batch.results
            .filter { $0.normalizedDistance <= normalizedThreshold }
            .sorted { $0.distance < $1.distance }
            .prefix(maxResults)
            .map { $0 }
    }
}
