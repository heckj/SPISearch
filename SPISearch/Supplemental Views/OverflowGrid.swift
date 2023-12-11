import SwiftUI

// from https://stackoverflow.com/questions/58842453/swiftui-hstack-with-wrap
public struct OverflowGrid: Layout {
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    public init(horizontalSpacing: CGFloat = 4, verticalSpacing: CGFloat? = nil) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing ?? horizontalSpacing
    }
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.max(by: {$0.dimensions(in: proposal).height > $1.dimensions(in: proposal).height})?.dimensions(in: proposal).height ?? 0
        var rows = [CGFloat]()
        subviews.indices.forEach { index in
            let rowIndex = rows.count - 1
            let subViewWidth = subviews[index].dimensions(in: proposal).width
            guard !rows.isEmpty else {
                rows.append(subViewWidth)
                return
            }
            let newWidth = rows[rowIndex] + subViewWidth + horizontalSpacing
            if newWidth < proposal.width ?? 0 {
                rows[rowIndex] += (rows[rowIndex] > 0 ? horizontalSpacing: 0) + subViewWidth
            }else {
                rows.append(subViewWidth)
            }
        }
        let count = CGFloat(rows.count)
        return CGSize(width: rows.max() ?? 0, height: count * height + (count - 1) * verticalSpacing)
        
    }
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let height = subviews.max(by: {$0.dimensions(in: proposal).height > $1.dimensions(in: proposal).height})?.dimensions(in: proposal).height ?? 0
        guard !subviews.isEmpty else {return}
        var x = bounds.minX
        var y = height/2 + bounds.minY
        subviews.indices.forEach { index in
            let subView = subviews[index]
            x += subView.dimensions(in: proposal).width/2
            subviews[index].place(at: CGPoint(x: x, y: y), anchor: .center, proposal: ProposedViewSize(width: subView.dimensions(in: proposal).width, height: subView.dimensions(in: proposal).height))
            x += horizontalSpacing + subView.dimensions(in: proposal).width/2
            if x > bounds.width {
                x = bounds.minX
                y += height + verticalSpacing
            }
        }
    }
}
