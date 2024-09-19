#if canImport(AuthenticationServices)
import AuthenticationServices

@available(macOS 10.15, iOS 13.0, tvOS 16.0, watchOS 6.2, *)
public extension ASWebAuthenticationSession {
	convenience init(url: URL, callbackURLScheme: String?, completion: @escaping (Result<URL, Error>) -> Void) {
		self.init(
			url: url,
			callbackURLScheme: callbackURLScheme,
			completionHandler: { url, error in
				if let error {
					completion(.failure(error))
				} else {
					do {
						let url = try url.unwrap()
						completion(.success(url))
					} catch {
						completion(.failure(error))
					}
				}
			})
	}
}
#endif
