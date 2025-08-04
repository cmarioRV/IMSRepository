//
//  GoodRepositoryProtocol.swift
//  server
//
//  Created by Mario Rúa on 10/07/25.
//
import Vapor
import Fluent
import IMSDomain

enum GoodRepositoryError: Error {
    case invalidGoods(RepositoryErrorResponse<Good>)
    case notFound(String)
    case writingError
    case invalidCSV
    case wrongValue(String)
}

struct GoodRepository: GoodRepositoryProtocol {
    let goodDao: any GoodDAOProtocol
    let measurementUnitDao: any MeasurementUnitDAOProtocol
    let measurementTypeDao: any MeasurementTypeDAOProtocol
    let providerDao: any ProviderDAOProtocol
    let categoryDao: any FoodTypeCategoryDAOProtocol
    let goodProviderDao: any GoodProviderDAOProtocol
    
    func create(_ goods: [Good], with req: Request) async throws -> [Good] {
        try await req.db.transaction { database in
            for good in goods {
                let existingGood = try await goodDao.findByName(good.name, on: database)
                if let existingGood = existingGood {
                    try await update(storedGood: existingGood, updatedGood: good, on: database)
                } else {
                    try await save(good, on: database)
                }
            }
            
            return goods
        }
    }
    
    func getAll(with req: Vapor.Request) async throws -> [Good] {
        try await goodDao.findAll(on: req.db)
    }
    
    func getByPrice(minPrice: Double, maxPrice: Double, with req: Request) async throws -> [Good] {
        try await goodDao.findByPrice(minPrice: minPrice, maxPrice: maxPrice, on: req.db)
    }
    
    func delete(_ good: Good, with req: Request) async throws -> Bool {
        let existingGood = try await goodDao.findByName(good.name, on: req.db)
        guard let existingGood = existingGood, let goodId = existingGood.id else {
            return false
        }
        
        let existingGoodProviders = try await goodProviderDao.findBy(goodId: goodId, on: req.db)
        try await req.db.transaction { database in
            for existingGoodProvider in existingGoodProviders {
                guard let existingGoodProviderId = existingGoodProvider.id else {
                    continue
                }
                let _ = try await goodProviderDao.delete(existingGoodProviderId, on: database)
            }
        }

        return try await goodDao.delete(goodId, on: req.db)
    }
}

extension GoodRepository: Sendable {
    @discardableResult
    private func save(_ good: Good, on database: any Database) async throws -> Good {
        let unit = try await saveMeasurementUnit(good.unit, on: database)
        let foodCategory = try await saveCategory(good.category, on: database)
        
        var good = good
        good.unit = unit
        good.category = foodCategory
        
        let storedGood = try await saveGood(good, on: database)
        
        guard let storedGoodId = storedGood.id else {
            throw GoodRepositoryError.writingError
        }
        
        try await saveProviders(good.providers, for: storedGoodId, on: database)
        
        return good
    }
    
    @discardableResult
    private func update(storedGood: Good, updatedGood: Good, on database: any Database) async throws -> Good {
        let unit = try await saveMeasurementUnit(updatedGood.unit, on: database)
        let foodCategory = try await saveCategory(updatedGood.category, on: database)
        
        guard let storedGoodId = storedGood.id else {
            throw GoodRepositoryError.writingError
        }
        
        var good = updatedGood
        good.unit = unit
        good.category = foodCategory
        
        try await goodDao.update(storedGoodId, with: good, on: database)
        try await saveProviders(good.providers, for: storedGoodId, on: database)
        return good
    }
    
    @discardableResult
    private func saveProviders(_ providers: [Provider], for goodId: UUID, on database: any Database) async throws -> [Provider] {
        let providers = try await saveProviders(providers, on: database).compactMap({ $0 })
        
        for provider in providers {
            guard let providerId = provider.id else {
                continue
            }
            try await saveIfNeeded(goodId: goodId, providerId: providerId, on: database)
        }
        
        return providers
    }
    
    private func saveMeasurementUnit(_ measurementUnit: MeasurementUnit, on database: any Database) async throws -> MeasurementUnit {
        var storedUnit: MeasurementUnit
        let existingUnit = try await measurementUnitDao.findByName(measurementUnit.name, on: database)
        
        if let existingUnit = existingUnit {
            storedUnit = existingUnit
        } else {
            var unit = measurementUnit
            if let existingType = try await measurementTypeDao.findByName(measurementUnit.measurementType.name, on: database) {
                unit.measurementType = existingType
            } else {
                unit.measurementType = try await measurementTypeDao.create(measurementUnit.measurementType, on: database)
            }
            storedUnit = try await measurementUnitDao.save(unit, on: database)
        }
        
        return storedUnit
    }
    
    private func saveCategory(_ foodCategory: FoodTypeCategory, on database: any Database) async throws -> FoodTypeCategory {
        let storedFoodCategory: FoodTypeCategory
        let existingFoodCategory = try await categoryDao.findByName(foodCategory.name, on: database)
        
        if let existingFoodCategory = existingFoodCategory {
            storedFoodCategory = existingFoodCategory
        } else {
            storedFoodCategory = try await categoryDao.create(foodCategory, on: database)
        }
        
        return storedFoodCategory
    }
    
    private func saveProviders(_ providers: [Provider], on database: any Database) async throws -> [Provider] {
        var storedProviders: [Provider] = []
        for provider in providers {
            let existingProvider = try await providerDao.findByName(provider.name, on: database)
            
            let storedProvider: Provider
            if let existingProvider = existingProvider {
                storedProvider = existingProvider
            } else {
                storedProvider = try await providerDao.create(provider, on: database)
            }
            
            storedProviders.append(storedProvider)
        }
        
        return storedProviders
    }
    
    private func saveGood(_ good: Good, on database: any Database) async throws -> Good {
        let storedGood = try await goodDao.create(good, on: database)
        return storedGood
    }
    
    private func saveIfNeeded(goodId: UUID, providerId: UUID, on database: any Database) async throws -> Void {
        guard let _ = try await goodProviderDao.findBy(goodId: goodId, providerId: providerId, on: database) else {
            try await goodProviderDao.create(goodId: goodId, providerId: providerId, on: database)
            return
        }
    }
}
