import XCTest
import SwiftPizzaSnips

final class SeedableRNGTests: XCTestCase {
	func testRandomNumberGeneration() {
		var rng = SeedableRNG(seed: 70, primingIterations: 20)

		let first = Int.random(in: 0...100, using: &rng)
		XCTAssertEqual(65, first)

		let second = Int.random(in: 0...100, using: &rng)
		XCTAssertEqual(35, second)

		let third = Double.random(in: -1000...1_000_000, using: &rng)
		XCTAssertEqual(265821.3033286288, third)
	}

	func testUniformness() throws {
		var rng = SeedableRNG(seed: 0, primingIterations: 20)

		var unique: Set<Int> = []

		for _ in 0..<100 {
			unique.insert(Int.random(in: 0..<100, using: &rng))
		}

		XCTAssertEqual(61, unique.count)

		var count = 100
		while unique.count < 100 {
			count += 1
			unique.insert(Int.random(in: 0..<100, using: &rng))
		}

		XCTAssertEqual(421, count)
	}

	func testUniformness2() throws {
		var rng = SeedableRNG(seed: 0)
		var unique: Set<Int> = []
		var sysUnique: Set<Int> = []

		var seedCounts: [Int] = []
		var sysCounts: [Int] = []

		var seedCount = 0
		var sysCount = 0
		for i in 0..<100 {
			rng = rng.changingSeedValue(to: UInt64(i))
			defer {
				seedCount = 0
				sysCount = 0
				unique.removeAll(keepingCapacity: true)
				sysUnique.removeAll(keepingCapacity: true)
			}
			while unique.count < 100 {
				seedCount += 1
				unique.insert(Int.random(in: 0..<100, using: &rng))
			}

			while sysUnique.count < 100 {
				sysCount += 1
				sysUnique.insert(Int.random(in: 0..<100))
			}
			seedCounts.append(seedCount)
			sysCounts.append(sysCount)
		}

		let seedAverage = Double(seedCounts.reduce(0, +)) / Double(seedCounts.count)
		print("average seed to 100: \(seedAverage)")
		XCTAssertEqual(512.01, seedAverage)
		print("average sys to 100: \(Double(sysCounts.reduce(0, +)) / Double(sysCounts.count))")
	}
}
