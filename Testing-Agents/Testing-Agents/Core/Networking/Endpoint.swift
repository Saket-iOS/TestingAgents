import Foundation

struct Endpoint: Sendable {
    let path: String
    let method: String
    let body: Data?

    nonisolated static func register(email: String, password: String) -> Endpoint {
        let bodyDict = ["email": email, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: bodyDict)
        return Endpoint(path: "/api/v1/auth/register", method: "POST", body: body)
    }

    nonisolated func urlRequest(baseURL: String = "https://api.example.com") throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
