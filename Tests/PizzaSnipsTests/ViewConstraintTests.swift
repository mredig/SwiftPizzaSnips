import XCTest
@testable import SwiftPizzaSnips

final class ViewConstraintTests: XCTestCase {
	private func createAnchorSet(_ anchors: AnyHashable...) -> Set<AnyHashable?> {
		Set(anchors)
	}

	func testCreatingViewConstraintsTop() throws {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB, directions: .top)

		XCTAssertEqual(output.count, 1)
		let constraint = try XCTUnwrap(output.first)
		let constraintAnchors = createAnchorSet(constraint.firstAnchor, constraint.secondAnchor)
		let viewAnchors = createAnchorSet(viewA.topAnchor, viewB.topAnchor)
		XCTAssertEqual(constraintAnchors, viewAnchors)
	}

	func testCreatingViewConstraintsBottom() throws {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB, directions: .bottom)

		XCTAssertEqual(output.count, 1)
		let constraint = try XCTUnwrap(output.first)
		let constraintAnchors = createAnchorSet(constraint.firstAnchor, constraint.secondAnchor)
		let viewAnchors = createAnchorSet(viewA.bottomAnchor, viewB.bottomAnchor)
		XCTAssertEqual(constraintAnchors, viewAnchors)
	}

	func testCreatingViewConstraintsLeading() throws {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB, directions: .leading)

		XCTAssertEqual(output.count, 1)
		let constraint = try XCTUnwrap(output.first)
		let constraintAnchors = createAnchorSet(constraint.firstAnchor, constraint.secondAnchor)
		let viewAnchors = createAnchorSet(viewA.leadingAnchor, viewB.leadingAnchor)
		XCTAssertEqual(constraintAnchors, viewAnchors)
	}

	func testCreatingViewConstraintsTrailing() throws {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB, directions: .trailing)

		XCTAssertEqual(output.count, 1)
		let constraint = try XCTUnwrap(output.first)
		let constraintAnchors = createAnchorSet(constraint.firstAnchor, constraint.secondAnchor)
		let viewAnchors = createAnchorSet(viewA.trailingAnchor, viewB.trailingAnchor)
		XCTAssertEqual(constraintAnchors, viewAnchors)
	}

	func testViewConstraintsActivation() throws {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB)

		XCTAssertTrue(output.allSatisfy { $0.isActive == false })
		output.activate()
		XCTAssertTrue(output.allSatisfy(\.isActive))
	}

	func testViewConstraintsInsets() {
		let viewA = OSView()
		let viewB = OSView()

		viewA.addSubview(viewB)
		let output = viewA.constrain(viewB, inset: NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4))

		func getConstraint(with anchor: AnyObject?) -> NSLayoutConstraint? {
			output.first(where: { $0.firstAnchor === anchor || $0.secondAnchor === anchor })
		}

		var testingConstraint: NSLayoutConstraint?
		testingConstraint = getConstraint(with: viewA.topAnchor)
		XCTAssertEqual(testingConstraint?.constant, 1)

		testingConstraint = getConstraint(with: viewA.leadingAnchor)
		XCTAssertEqual(testingConstraint?.constant, 2)

		testingConstraint = getConstraint(with: viewA.bottomAnchor)
		XCTAssertEqual(testingConstraint?.constant, 3)

		testingConstraint = getConstraint(with: viewA.trailingAnchor)
		XCTAssertEqual(testingConstraint?.constant, 4)
	}
}
