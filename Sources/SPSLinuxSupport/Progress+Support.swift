import Foundation

package extension Progress {
	convenience init(correct: Void = ()) {
		self.init(totalUnitCount: -1)
	}
}
