import GiftUI

public enum LayoutEngine {
    public static func layout<Content: View>(
        _ content: Content,
        in surfaceSize: Size
    ) -> LayoutNode {
        ViewGraph.layout(content, in: surfaceSize).layoutNode()
    }
}
