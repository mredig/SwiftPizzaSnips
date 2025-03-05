import Testing
import SwiftPizzaSnips

struct SeedableRNGTests {
	@Test func testRandomNumberGeneration() {
		var rng = SeedableRNG(seed: 70, primingIterations: 20)

		let first = Int.random(in: 0...100, using: &rng)
		#expect(65 == first)

		let second = Int.random(in: 0...100, using: &rng)
		#expect(35 == second)

		let third = Double.random(in: -1000...1_000_000, using: &rng)
		#expect(265821.3033286288 == third)
	}

	@Test func testUniformness() throws {
		var rng = SeedableRNG(seed: 0, primingIterations: 20)

		var unique: Set<Int> = []

		for _ in 0..<100 {
			unique.insert(Int.random(in: 0..<100, using: &rng))
		}

		#expect(61 == unique.count)

		var count = 100
		while unique.count < 100 {
			count += 1
			unique.insert(Int.random(in: 0..<100, using: &rng))
		}

		#expect(421 == count)
	}

	@Test func testUniformness2() throws {
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
		#expect(512.01 == seedAverage)
		print("average sys to 100: \(Double(sysCounts.reduce(0, +)) / Double(sysCounts.count))")
	}


	/// Due to the nature of randomness, it is POSSIBLE for this test to fail, but it shouldn't fail *often*
	@Test func testUniformness3() throws {
		var counts: [Int] = []
		for _ in UInt64(0)..<100 {
			var rng: RandomNumberGenerator = SeedableRNG(seed: UInt64.random(in: 70..<7000), primingIterations: 20)

			var unique: Set<Int> = []
			var count = 0

			while unique.count < 1000 {
				let next = Int.random(in: 0..<1000, using: &rng)
				unique.insert(next)
				count += 1
			}

			counts.append(count)
		}

		let uniformness = UniformnessStatistics(min: counts.min()!, max: counts.max()!, avg: counts.reduce(0, +) / counts.count)

		let sysUniformness = systemUniformness()
		print("Seeded uniformness: \(uniformness)")
		print("System uniformness: \(sysUniformness)")

		func rangeGen(base: Int) -> ClosedRange<Int> {
			let half = base / 2
			let lower = base - half
			let upper = base + half
			return lower...upper
		}
		let acceptedMinRange = rangeGen(base: sysUniformness.min)
		let acceptedMaxRange = rangeGen(base: sysUniformness.max)
		let acceptedAvgRange = rangeGen(base: sysUniformness.avg)

		#expect(acceptedMinRange.contains(uniformness.min))
		#expect(acceptedMaxRange.contains(uniformness.max))
		#expect(acceptedAvgRange.contains(uniformness.avg))
	}

	private func systemUniformness() -> UniformnessStatistics<Int> {
		var counts: [Int] = []
		for _ in 0..<100 {
			var unique: Set<Int> = []
			var count = 0
			
			while unique.count < 1000 {
				let next = Int.random(in: 0..<1000)
				unique.insert(next)
				count += 1
			}
			
			counts.append(count)
		}

		return UniformnessStatistics(min: counts.min()!, max: counts.max()!, avg: counts.reduce(0, +) / counts.count)
	}

	private struct UniformnessStatistics<N: Hashable & Comparable & BinaryInteger>: Hashable {
		let min: N
		let max: N
		let avg: N
	}
}
