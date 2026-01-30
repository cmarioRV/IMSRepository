import Testing
import Fluent
import Vapor
@testable import IMSRepository
@testable import IMSDomain

@Suite("Repository Tests")
struct RepositoryTests {
    
    // MARK: - Mock DAOs
    struct MockGoodDAO: GoodDAOProtocol {
        var findAllResult: [Good] = []
        var findByIdResult: Good?
        var findByNameResult: Good?
        var findByPriceResult: [Good] = []
        var createResult: Good?
        var updateResult: Good?
        var deleteResult: Bool = false
        
        var findAllCalled = false
        var findByIdCalled = false
        var findByNameCalled = false
        var findByPriceCalled = false
        var createCalled = false
        var updateCalled = false
        var deleteCalled = false
        
        func findAll(on database: any Database) async throws -> [Good] {
            findAllCalled = true
            return findAllResult
        }
        
        func findById(_ id: UUID, on database: any Database) async throws -> Good? {
            findByIdCalled = true
            return findByIdResult
        }
        
        func findByName(_ name: String, on database: any Database) async throws -> Good? {
            findByNameCalled = true
            return findByNameResult
        }
        
        func findByPrice(minPrice: Double, maxPrice: Double, on database: any Database) async throws -> [Good] {
            findByPriceCalled = true
            return findByPriceResult
        }
        
        func create(_ good: Good, on database: any Database) async throws -> Good {
            createCalled = true
            return createResult ?? good
        }
        
        func update(_ id: UUID, with dto: Good, on database: any Database) async throws -> Good {
            updateCalled = true
            return updateResult ?? dto
        }
        
        func delete(_ id: UUID, on database: any Database) async throws -> Bool {
            deleteCalled = true
            return deleteResult
        }
    }
    
    struct MockMeasurementUnitDAO: MeasurementUnitDAOProtocol {
        var findByNameResult: MeasurementUnit?
        var saveResult: MeasurementUnit?
        
        func findByName(_ name: String, on database: any Database) async throws -> MeasurementUnit? {
            return findByNameResult
        }
        
        func save(_ unit: MeasurementUnit, on database: any Database) async throws -> MeasurementUnit {
            return saveResult ?? unit
        }
    }
    
    struct MockMeasurementTypeDAO: MeasurementTypeDAOProtocol {
        var findByNameResult: MeasurementType?
        var createResult: MeasurementType?
        
        func findByName(_ name: String, on database: any Database) async throws -> MeasurementType? {
            return findByNameResult
        }
        
        func create(_ type: MeasurementType, on database: any Database) async throws -> MeasurementType {
            return createResult ?? type
        }
    }
    
    struct MockProviderDAO: ProviderDAOProtocol {
        var findByNameResult: Provider?
        var createResult: Provider?
        
        func findByName(_ name: String, on database: any Database) async throws -> Provider? {
            return findByNameResult
        }
        
        func create(_ provider: Provider, on database: any Database) async throws -> Provider {
            return createResult ?? provider
        }
    }
    
    struct MockFoodTypeCategoryDAO: FoodTypeCategoryDAOProtocol {
        var findByNameResult: FoodTypeCategory?
        var createResult: FoodTypeCategory?
        
        func findByName(_ name: String, on database: any Database) async throws -> FoodTypeCategory? {
            return findByNameResult
        }
        
        func create(_ category: FoodTypeCategory, on database: any Database) async throws -> FoodTypeCategory {
            return createResult ?? category
        }
    }
    
    struct MockGoodProviderDAO: GoodProviderDAOProtocol {
        var findByResult: GoodProvider?
        var findByGoodIdResult: [GoodProvider] = []
        var createCalled = false
        var deleteResult = false
        
        func findBy(goodId: UUID, providerId: UUID, on database: any Database) async throws -> GoodProvider? {
            return findByResult
        }
        
        func findBy(goodId: UUID, on database: any Database) async throws -> [GoodProvider] {
            return findByGoodIdResult
        }
        
        func create(goodId: UUID, providerId: UUID, on database: any Database) async throws -> Void {
            createCalled = true
        }
        
        func delete(_ id: UUID, on database: any Database) async throws -> Bool {
            return deleteResult
        }
    }
    
    // MARK: - Test Helpers
    func createTestGood(name: String = "Test Good") -> Good {
        let measurementType = MeasurementType(id: UUID(), name: "Weight")
        let measurementUnit = MeasurementUnit(id: UUID(), name: "kg", measurementType: measurementType)
        let category = FoodTypeCategory(id: UUID(), name: "Vegetables")
        let provider = Provider(id: UUID(), name: "Test Provider")
        
        return Good(
            id: UUID(),
            name: name,
            description: "Test Description",
            unit: measurementUnit,
            price: 10.99,
            quantity: 5.0,
            category: category,
            providers: [provider]
        )
    }
    
    func createMockRequest() throws -> Request {
        let app = Application(.testing)
        defer { app.shutdown() }
        return Request(application: app, on: app.eventLoopGroup.next())
    }
    
    // MARK: - Repository Tests
    @Test("Get all goods from repository")
    func getAllGoodsFromRepository() async throws {
        // Given
        let testGoods = [createTestGood(name: "Apple"), createTestGood(name: "Banana")]
        var mockGoodDAO = MockGoodDAO()
        mockGoodDAO.findAllResult = testGoods
        
        let repository = GoodRepository(
            goodDao: mockGoodDAO,
            measurementUnitDao: MockMeasurementUnitDAO(),
            measurementTypeDao: MockMeasurementTypeDAO(),
            providerDao: MockProviderDAO(),
            categoryDao: MockFoodTypeCategoryDAO(),
            goodProviderDao: MockGoodProviderDAO()
        )
        
        // When
        let result = try await repository.getAll(with: try createMockRequest())
        
        // Then
        #expect(mockGoodDAO.findAllCalled == true)
        #expect(result.count == 2)
        #expect(result[0].name == "Apple")
        #expect(result[1].name == "Banana")
    }
    
    @Test("Get goods by price range from repository")
    func getGoodsByPriceFromRepository() async throws {
        // Given
        let testGoods = [createTestGood(name: "Cheap Item")]
        var mockGoodDAO = MockGoodDAO()
        mockGoodDAO.findByPriceResult = testGoods
        
        let repository = GoodRepository(
            goodDao: mockGoodDAO,
            measurementUnitDao: MockMeasurementUnitDAO(),
            measurementTypeDao: MockMeasurementTypeDAO(),
            providerDao: MockProviderDAO(),
            categoryDao: MockFoodTypeCategoryDAO(),
            goodProviderDao: MockGoodProviderDAO()
        )
        
        // When
        let result = try await repository.getByPrice(minPrice: 5.0, maxPrice: 15.0, with: try createMockRequest())
        
        // Then
        #expect(mockGoodDAO.findByPriceCalled == true)
        #expect(result.count == 1)
        #expect(result[0].name == "Cheap Item")
    }
    
    @Test("Delete existing good from repository")
    func deleteExistingGoodFromRepository() async throws {
        // Given
        let testGood = createTestGood(name: "To Delete")
        var mockGoodDAO = MockGoodDAO()
        mockGoodDAO.findByNameResult = testGood
        mockGoodDAO.deleteResult = true
        
        var mockGoodProviderDAO = MockGoodProviderDAO()
        mockGoodProviderDAO.findByGoodIdResult = []
        
        let repository = GoodRepository(
            goodDao: mockGoodDAO,
            measurementUnitDao: MockMeasurementUnitDAO(),
            measurementTypeDao: MockMeasurementTypeDAO(),
            providerDao: MockProviderDAO(),
            categoryDao: MockFoodTypeCategoryDAO(),
            goodProviderDao: mockGoodProviderDAO
        )
        
        // When
        let result = try await repository.delete(testGood, with: try createMockRequest())
        
        // Then
        #expect(mockGoodDAO.findByNameCalled == true)
        #expect(mockGoodDAO.deleteCalled == true)
        #expect(result == true)
    }
    
    @Test("Delete non-existing good from repository")
    func deleteNonExistingGoodFromRepository() async throws {
        // Given
        let testGood = createTestGood(name: "Non Existing")
        var mockGoodDAO = MockGoodDAO()
        mockGoodDAO.findByNameResult = nil
        
        let repository = GoodRepository(
            goodDao: mockGoodDAO,
            measurementUnitDao: MockMeasurementUnitDAO(),
            measurementTypeDao: MockMeasurementTypeDAO(),
            providerDao: MockProviderDAO(),
            categoryDao: MockFoodTypeCategoryDAO(),
            goodProviderDao: MockGoodProviderDAO()
        )
        
        // When
        let result = try await repository.delete(testGood, with: try createMockRequest())
        
        // Then
        #expect(mockGoodDAO.findByNameCalled == true)
        #expect(mockGoodDAO.deleteCalled == false)
        #expect(result == false)
    }
}
