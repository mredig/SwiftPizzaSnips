import AuthenticationServices

@available(macOS 10.15, iOS 12.0, *)
extension ASWebAuthenticationSession {
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
