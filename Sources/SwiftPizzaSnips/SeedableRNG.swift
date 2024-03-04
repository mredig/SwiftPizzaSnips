import Foundation

/// Not super high quality RNG, but somewhat uniform. Definltely NOT secure.
public struct SeedableRNG: RandomNumberGenerator {
	public let initialSeed: UInt64
	public private(set) var currentSeedvalue: UInt64

	/// If you don't provide a seed, the system RNG provides one for you, but that sort of defeats the purpose of this
	/// . Additionally, sometimes the first few numbers don't feel very random, so you have the option to provide 
	/// `primingIterations` to cause the RNG to iterate through as many generated numbers, priming the RNG
	/// as it feels much more random after it gets going a little.
	public init(seed: UInt64?, primingIterations: UInt = 0) {
		let unwrappedSeed = seed ?? UInt64.random(in: 0..<UInt64.max)
		self.initialSeed = unwrappedSeed
		self.currentSeedvalue = unwrappedSeed

		for _ in 0..<primingIterations {
			_ = next()
		}
	}

	static func randomNumber(seed: UInt64, max: UInt64 = UInt64.max) -> UInt64 {
		let a: UInt64 = 16807
		let c: UInt64 = 12345
		let value = a &* seed &+ c
		return value % max
	}

	public mutating func next() -> UInt64 {
		let result = Self.randomNumber(seed: currentSeedvalue, max: UInt64.max)
		currentSeedvalue = result
		return result
	}

	/// Changing the seed value will technically invalidate the initial seed as a valid historical record, but it's probably useful to be able to tweak the rng progress.
	public func changingSeedValue(to newValue: UInt64) -> Self {
		var new = self
		new.currentSeedvalue = newValue
		return new
	}
}
