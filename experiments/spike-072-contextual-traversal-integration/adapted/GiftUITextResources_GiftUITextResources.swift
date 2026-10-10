
package struct TextResourceDigest: Equatable, Hashable, Sendable {
    package let word0: UInt32
    package let word1: UInt32
    package let word2: UInt32
    package let word3: UInt32
    package let word4: UInt32
    package let word5: UInt32
    package let word6: UInt32
    package let word7: UInt32

    package init(
        word0: UInt32,
        word1: UInt32,
        word2: UInt32,
        word3: UInt32,
        word4: UInt32,
        word5: UInt32,
        word6: UInt32,
        word7: UInt32
    ) {
        self.word0 = word0
        self.word1 = word1
        self.word2 = word2
        self.word3 = word3
        self.word4 = word4
        self.word5 = word5
        self.word6 = word6
        self.word7 = word7
    }
}

package struct FontResourceID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: TextResourceDigest

    package init(rawValue: TextResourceDigest) {
        self.rawValue = rawValue
    }
}

package struct FontInstanceID: Equatable, Hashable, Sendable {
    package let resource: FontResourceID
    package let instanceIndex: UInt16

    package init(resource: FontResourceID, instanceIndex: UInt16) {
        self.resource = resource
        self.instanceIndex = instanceIndex
    }
}

package struct GlyphID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

