import SwiftUI
import SpriteKit

struct ShaderView: View {
    
    /// Examples at https://github.com/twostraws/ShaderKit/tree/main/Shaders
    var source: String
    var uniforms: [SKUniform]? = nil
    var attributes: [SKAttribute]? = nil
    
    @State private var scene: SKScene?
    
    func makeScene(size: CGSize) -> SKScene {
        let shaderNodeName = "shader"
        func makeShaderNode(shader: SKShader) -> SKNode {
            let sprite = SKSpriteNode(texture: nil, size: size)
            sprite.name = shaderNodeName
            sprite.shader = shader
            sprite.color = .white
            sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
            return sprite
        }
        
        if let scene = self.scene,
           let shaderNode = scene.childNode(withName: shaderNodeName) as? SKSpriteNode,
           let shader = shaderNode.shader {
            scene.size = size
            shaderNode.removeFromParent()
            scene.addChild(makeShaderNode(shader: shader))
            return scene
        } else {
            let scene = SKScene(size: size)
            let shader = SKShader(source: source, uniforms: uniforms, attributes: attributes)
            scene.addChild(makeShaderNode(shader: shader))
            DispatchQueue.main.async {
                self.scene = scene
            }
            return scene
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size))
        }
    }
    
}

extension SKAttributeValue {
    
    /**
     Convenience initializer to create an attribute value from a CGSize.
     - Parameter size: The input size; this is usually your node's size.
     */
    public convenience init(size: CGSize) {
        let size = vector_float2(Float(size.width), Float(size.height))
        self.init(vectorFloat2: size)
    }
}

extension SKShader {
    
    /**
     Convenience initializer to create a shader form a source code.
     
     - Parameter source: The source code
     - Parameter uniforms: An array of SKUniforms to apply to the shader. Defaults to nil.
     - Parameter attributes: An array of SKAttributes to apply to the shader. Defaults to nil.
     */
    convenience init(source: String, uniforms: [SKUniform]? = nil, attributes: [SKAttribute]? = nil) {
        
        // if we were sent any uniforms then apply them immediately
        if let uniforms = uniforms {
            self.init(source: source, uniforms: uniforms)
        } else {
            self.init(source: source)
        }
        
        // if we were sent any attributes then apply those too
        if let attributes = attributes {
            self.attributes = attributes
        }
    }
}

extension SKUniform {
    /**
     Convenience initializer to create an SKUniform from an SKColor.
     - Parameter name: The name of the uniform inside the shader, e.g. u_color.
     - Parameter color: The SKColor to set.
     */
    public convenience init(name: String, color: SKColor) {
#if os(macOS)
        guard let converted = color.usingColorSpace(.deviceRGB) else {
            fatalError("Attempted to use a color that is not expressible in RGB.")
        }
        
        let colors = vector_float4([Float(converted.redComponent), Float(converted.greenComponent), Float(converted.blueComponent), Float(converted.alphaComponent)])
#else
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let colors = vector_float4([Float(r), Float(g), Float(b), Float(a)])
#endif
        
        self.init(name: name, vectorFloat4: colors)
    }
    
    /**
     Convenience initializer to create an SKUniform from a CGSize.
     - Parameter name: The name of the uniform inside the shader, e.g. u_size.
     - Parameter color: The CGSize to set.
     */
    public convenience init(name: String, size: CGSize) {
        let size = vector_float2(Float(size.width), Float(size.height))
        self.init(name: name, vectorFloat2: size)
    }
    
    /**
     Convenience initializer to create an SKUniform from a CGPoint.
     - Parameter name: The name of the uniform inside the shader, e.g. u_center.
     - Parameter color: The CGPoint to set.
     */
    public convenience init(name: String, point: CGPoint) {
        let point = vector_float2(Float(point.x), Float(point.y))
        self.init(name: name, vectorFloat2: point)
    }
}


struct ShaderView_Previews: PreviewProvider {
    static var previews: some View {
        ShaderView(source: """
        void main() {
            gl_FragColor = vec4(1, 0, 1, 1);
        }
        """)
        .padding()
    }
}
