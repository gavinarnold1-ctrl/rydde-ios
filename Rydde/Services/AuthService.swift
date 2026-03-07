import AuthenticationServices
import Foundation
import Security

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false

    private(set) var jwt: String? {
        didSet {
            isAuthenticated = jwt != nil
        }
    }

    private let keychainKey = "app.rydde.jwt"

    private init() {
        self.jwt = loadTokenFromKeychain()
        self.isAuthenticated = self.jwt != nil
    }

    // MARK: - Sign In with Apple

    func handleSignInWithApple(result: Result<ASAuthorization, Error>) async throws {
        let authorization = try result.get()

        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthError.missingIdentityToken
        }

        let fullName = credential.fullName
        let signInBody = SignInRequest(
            identityToken: identityToken,
            firstName: fullName?.givenName,
            lastName: fullName?.familyName
        )

        let response: SignInResponse = try await APIService.shared.post(
            endpoint: "/api/auth/signin",
            body: signInBody
        )

        saveTokenToKeychain(response.token)
        jwt = response.token
    }

    func signOut() {
        deleteTokenFromKeychain()
        jwt = nil
    }

    // MARK: - Keychain

    private func saveTokenToKeychain(_ token: String) {
        let data = Data(token.utf8)

        deleteTokenFromKeychain()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func deleteTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Types

enum AuthError: Error, LocalizedError {
    case missingIdentityToken

    var errorDescription: String? {
        switch self {
        case .missingIdentityToken: return "Missing identity token from Apple"
        }
    }
}

struct SignInRequest: Encodable {
    let identityToken: String
    let firstName: String?
    let lastName: String?
}

struct SignInResponse: Decodable {
    let token: String
}
