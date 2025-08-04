struct RepositoryErrorResponse<T: Codable & Sendable>: Error, Codable {
    struct RepositoryErrorResponseBody: Codable {
        let message: String
        let payload: [T]
    }
    
    let error : RepositoryErrorResponseBody
}
