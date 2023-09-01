import Foundation

public extension String {
	private static let loremSource = """
		hic animi ut corrupti laboriosam non est rem voluptate harum qui nulla consequatur ratione quaerat repellat quae \
		voluptatibus et omnis consequatur vero dolores voluptas dolores voluptas vel consequuntur et voluptas cum explicabo \
		suscipit aut odit sint molestiae sapiente sunt et odit aperiam et omnis dolorem magni non cumque non assumenda \
		temporibus quidem laboriosam quod dolor explicabo praesentium aut architecto et ut omnis officiis ea sint mollitia \
		cupiditate molestiae accusamus dicta eum enim aut vel nobis corporis voluptate quia ida underwood sadie barton \
		kieran olsen alfredo hamilton allyson hall nadia chang skyler sykes yvonne perkins eli kane deserunt quae aut \
		et non id ut reiciendis maxime neque quia autem voluptas quia autem beatae corrupti amet quaerat autem aut in \
		illum architecto laudantium et repudiandae voluptas et ea fugiat aut nobis accusamus sit ipsam et sunt \
		voluptatibus non id velit vero sint illum molestias sed enim repellendus iure eius eos reiciendis porro iusto \
		vero id aliquid natus doloribus voluptas consequatur in beatae sed vel vel in aut voluptatum cum ea voluptatem \
		quisquam
		"""
		.split(separator: " ")
		.map { String($0) }

	static func randomLoremIpsum<R: RandomNumberGenerator>(wordCount count: Int, using rng: inout R) -> String {
		(0..<count).compactMap { _ in
			Self.loremSource.randomElement(using: &rng)
		}.joined(separator: " ")
	}

	static func randomLoremIpsum(wordCount count: Int) -> String {
		var rng = SystemRandomNumberGenerator()
		return randomLoremIpsum(wordCount: count, using: &rng)
	}
}
