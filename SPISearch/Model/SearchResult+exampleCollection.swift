import Foundation
import SPISearchResult

// Same content as searchcollection_textexample.txt
// Note: these are 3 lines, each with an encoded JSON object, not one large
// JSON blob/list, so they are broken up into 3 strings to more easily assemble
// examples
let search1 = #"""
{"q":"crdt","a":["y-crdt"],"k":["crdts","crdt-implementations","crdt"],"t":"2023-12-06T20:28:11Z","p":[{"x":121,"k":["crdt","crdt-implementations","crdts","swift"],"id":{"o":"heckj","r":"CRDT"},"s":"Conflict-free Replicated Data Types in Swift"},{"s":"Convergent and Commutative Replicated Data Types implementation in Swift","x":25,"k":["crdt","crdt-implementations","crdts","lseq","swift"],"id":{"o":"bluk","r":"CRDT"}},{"s":"Swift language bindings presenting Automerge","x":152,"id":{"o":"automerge","r":"automerge-swift"},"k":["automerge","crdt","crdt-implementations","crdts","swift"]},{"x":13,"k":["crdt","hacktoberfest","ios","realtime-collaboration","swift","yorkie"],"s":"Yorkie iOS SDK","id":{"o":"yorkie-team","r":"yorkie-ios-sdk"}},{"k":["crdt","rust","swift","yjs"],"id":{"o":"y-crdt","r":"yswift"},"x":49,"s":"Swift language bindings to Y-CRDT"},{"x":91,"id":{"o":"appdecentral","r":"replicatingtypes"},"k":[],"s":"Code for the tutorial series on Conflict-Free Replicated Data Types (CRDTs) at appdecentral.com"}]}
"""#
let search2 = #"""
{"q":"crdt","a":["y-crdt"],"k":["crdts","crdt-implementations","crdt"],"t":"2023-12-01T20:28:11Z","p":[{"s":"Convergent and Commutative Replicated Data Types implementation in Swift","x":25,"k":["crdt","crdt-implementations","crdts","lseq","swift"],"id":{"o":"bluk","r":"CRDT"}},{"s":"Swift language bindings presenting Automerge","x":152,"id":{"o":"automerge","r":"automerge-swift"},"k":["automerge","crdt","crdt-implementations","crdts","swift"]},{"x":13,"k":["crdt","hacktoberfest","ios","realtime-collaboration","swift","yorkie"],"s":"Yorkie iOS SDK","id":{"o":"yorkie-team","r":"yorkie-ios-sdk"}},{"k":["crdt","rust","swift","yjs"],"id":{"o":"y-crdt","r":"yswift"},"x":49,"s":"Swift language bindings to Y-CRDT"},{"x":91,"id":{"o":"appdecentral","r":"replicatingtypes"},"k":[],"s":"Code for the tutorial series on Conflict-Free Replicated Data Types (CRDTs) at appdecentral.com"}]}
"""#
let search3 = #"""
{"a":[],"q":"bezier","t":"2023-12-06T20:27:38Z","p":[{"s":"📽 Highly Optimized Graphics Math (glm) for C","k":["3d","3d-math","affine-transform-matrices","avx","bezier","bounding-boxes","c","euler","frustum","marix-inverse","math","matrix","matrix-decompositions","neon","opengl","opengl-math","simd","sse","vector","wasm"],"id":{"r":"cglm","o":"recp"},"x":1898},{"k":["animations","arrow","bezier-path","core-graphics","indicator","panels","sliding-menu","ux"],"id":{"r":"Arrows","o":"antoniocasero"},"s":"Arrows is an animated custom view to give feedback about your UI sliding panels.","x":335},{"x":49,"s":"Create animations over Bezier curves of any number of points","id":{"r":"SceneKit-Bezier-Animations","o":"maxxfrazer"},"k":["arkit","bezier","bezier-animation","bezier-curve","cocoapod","cocoapods","scenekit","scenekit-framework","swift","swift-package-manager","swiftpm"]},{"s":"Simple iOS view that draws a line with an arrow at the end. Uses UIBezierPath for a nice wavy effect.","id":{"r":"ArrowView","o":"bradhowes"},"x":5,"k":["arrow","bezier-path","ios","swift-pm","uibezierpath","uiview"]},{"x":1615,"s":"Easily convert your SVG files into CGPaths, CAShapeLayers, and UIBezierPaths ","id":{"o":"pocketsvg","r":"PocketSVG"},"k":["cocoapods","ios","macos","objective-c","svg","svg-files","swift"]},{"s":"ClippingBezier calculates intersection points, paths, and shapes between two UIBezierPaths","x":238,"k":[],"id":{"r":"ClippingBezier","o":"adamwulf"}},{"x":356,"s":"A small library to dramatically speed up common operations on UIBezierPath, and also bring its functionality closer to NSBezierPath","id":{"o":"adamwulf","r":"PerformanceBezier"},"k":[]},{"x":2,"s":"A view in the form of a popup balloon. UIBezierPath initializer included!","id":{"r":"BalloonView","o":"AndreasVerhoeven"},"k":[]}],"k":["bezier-animation","uibezierpath","bezier-path","bezier-curve","bezier"]}
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
