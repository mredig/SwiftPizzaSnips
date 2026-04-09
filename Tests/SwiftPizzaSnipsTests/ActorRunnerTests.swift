import SwiftPizzaSnips
import Testing

struct ActorRunnerTests {
	actor TestActor: ActorRunner {
		var someValue = 0
	}

	@Test func isolatedRunningWorks() async throws {
		let actor = TestActor()

		await #expect(actor.someValue == 0)
		await actor.runIsloated {
			$0.someValue = 5
		}
		await #expect(actor.someValue == 5)
	}

	@Test func isolatedRunningThrows() async throws {
		let actor = TestActor()

		await #expect(actor.someValue == 0)
		let error = await #expect(throws: TestError.self) {
			try await actor.runIsloated { _ in
				throw TestError.basic
			}
		}
		await #expect(actor.someValue == 0)
		#expect(error == .basic)
	}
}
