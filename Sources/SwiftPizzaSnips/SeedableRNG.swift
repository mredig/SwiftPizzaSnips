import Foundation

/// Not super high quality RNG, but somewhat uniform. Definltely NOT secure.
public struct SeedableRNG: RandomNumberGenerator {
	public let initialSeed: UInt64
	public private(set) var currentSeedvalue: UInt64

	public init(seed: UInt64?) {
		let unwrappedSeed = seed ?? UInt64.random(in: 0..<UInt64.max)
		self.initialSeed = unwrappedSeed
		self.currentSeedvalue = unwrappedSeed
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
