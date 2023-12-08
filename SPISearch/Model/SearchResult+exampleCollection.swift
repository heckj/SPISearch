import Foundation
import SPISearchResult

// Same content as searchcollection_textexample.txt
// Note: these are 3 lines, each with an encoded JSON object, not one large
// JSON blob/list, so they are broken up into 3 strings to more easily assemble
// examples
let search1 = #"""
{"a":["y-crdt"],"k":["crdts","crdt-implementations","crdt"],"p":[{"id":{"o":"heckj","r":"CRDT"},"k":["crdt","crdt-implementations","crdts","swift"],"n":"CRDT","s":"Conflict-free Replicated Data Types in Swift","x":121},{"id":{"o":"bluk","r":"CRDT"},"k":["crdt","crdt-implementations","crdts","lseq","swift"],"n":"CRDT","s":"Convergent and Commutative Replicated Data Types implementation in Swift","x":25},{"id":{"o":"automerge","r":"automerge-swift"},"k":["automerge","crdt","crdt-implementations","crdts","swift"],"n":"Automerge","s":"Swift language bindings presenting Automerge","x":153},{"id":{"o":"yorkie-team","r":"yorkie-ios-sdk"},"k":["crdt","hacktoberfest","ios","realtime-collaboration","swift","yorkie"],"n":"Yorkie","s":"Yorkie iOS SDK","x":13},{"id":{"o":"y-crdt","r":"yswift"},"k":["crdt","rust","swift","yjs"],"n":"YSwift","s":"Swift language bindings to Y-CRDT","x":49},{"id":{"o":"appdecentral","r":"replicatingtypes"},"k":[],"n":"ReplicatingTypes","s":"Code for the tutorial series on Conflict-Free Replicated Data Types (CRDTs) at appdecentral.com","x":91}],"q":"crdt","t":"2023-12-08T21:23:19Z"}
"""#
let search2 = #"""
{"a":["y-crdt"],"k":["crdts","crdt-implementations","crdt"],"p":[{"id":{"o":"heckj","r":"CRDT"},"k":["crdt","crdt-implementations","crdts","swift"],"n":"CRDT","s":"Conflict-free Replicated Data Types in Swift","x":121},{"id":{"o":"automerge","r":"automerge-swift"},"k":["automerge","crdt","crdt-implementations","crdts","swift"],"n":"Automerge","s":"Swift language bindings presenting Automerge","x":153},{"id":{"o":"yorkie-team","r":"yorkie-ios-sdk"},"k":["crdt","hacktoberfest","ios","realtime-collaboration","swift","yorkie"],"n":"Yorkie","s":"Yorkie iOS SDK","x":13},{"id":{"o":"y-crdt","r":"yswift"},"k":["crdt","rust","swift","yjs"],"n":"YSwift","s":"Swift language bindings to Y-CRDT","x":49},{"id":{"o":"appdecentral","r":"replicatingtypes"},"k":[],"n":"ReplicatingTypes","s":"Code for the tutorial series on Conflict-Free Replicated Data Types (CRDTs) at appdecentral.com","x":91}],"q":"crdt","t":"2023-12-08T21:23:19Z"}
"""#
let search3 = #"""
{"a":[],"k":["bezier-animation","uibezierpath","bezier-path","bezier-curve","bezier"],"p":[{"id":{"o":"recp","r":"cglm"},"k":["3d","3d-math","affine-transform-matrices","avx","bezier","bounding-boxes","c","euler","frustum","marix-inverse","math","matrix","matrix-decompositions","neon","opengl","opengl-math","simd","sse","vector","wasm"],"n":"cglm","s":"📽 Highly Optimized Graphics Math (glm) for C","x":1908},{"id":{"o":"antoniocasero","r":"Arrows"},"k":["animations","arrow","bezier-path","core-graphics","indicator","panels","sliding-menu","ux"],"n":"Arrows","s":"Arrows is an animated custom view to give feedback about your UI sliding panels.","x":335},{"id":{"o":"maxxfrazer","r":"SceneKit-Bezier-Animations"},"k":["arkit","bezier","bezier-animation","bezier-curve","cocoapod","cocoapods","scenekit","scenekit-framework","swift","swift-package-manager","swiftpm"],"n":"SCNBezier","s":"Create animations over Bezier curves of any number of points","x":49},{"id":{"o":"bradhowes","r":"ArrowView"},"k":["arrow","bezier-path","ios","swift-pm","uibezierpath","uiview"],"n":"ArrowView","s":"Simple iOS view that draws a line with an arrow at the end. Uses UIBezierPath for a nice wavy effect.","x":5},{"id":{"o":"pocketsvg","r":"PocketSVG"},"k":["cocoapods","ios","macos","objective-c","svg","svg-files","swift"],"n":"PocketSVG","s":"Easily convert your SVG files into CGPaths, CAShapeLayers, and UIBezierPaths ","x":1615},{"id":{"o":"adamwulf","r":"ClippingBezier"},"k":[],"n":"ClippingBezier","s":"ClippingBezier calculates intersection points, paths, and shapes between two UIBezierPaths","x":238},{"id":{"o":"adamwulf","r":"PerformanceBezier"},"k":[],"n":"PerformanceBezier","s":"A small library to dramatically speed up common operations on UIBezierPath, and also bring its functionality closer to NSBezierPath","x":356},{"id":{"o":"AndreasVerhoeven","r":"BalloonView"},"k":[],"n":"BalloonView","s":"A view in the form of a popup balloon. UIBezierPath initializer included!","x":2}],"q":"bezier","t":"2023-12-08T21:22:47Z"}

"""#

extension SearchResult {
    static var exampleCollection: [SPISearchResult.SearchResult] {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            var collection: [SPISearchResult.SearchResult] = []
            for sampledata in [search1, search2, search3] {
                let sampleSearchResult = try decoder.decode(SPISearchResult.SearchResult.self, from: sampledata.data(using: .utf8)!)
                collection.append(sampleSearchResult)
            }
            return collection
        } catch {
            return []
        }
    }
}
