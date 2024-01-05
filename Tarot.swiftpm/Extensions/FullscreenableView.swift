//
//  SwiftUIView.swift
//  
//
//  Created by Giantwow on 04/01/2024.
//

import SwiftUI

public struct FullscreenableView<Content> : View where Content : View {

    var alignment: Alignment = .topTrailing
    @ViewBuilder var content: () -> Content

    @State private var fullScreen = false
    @Namespace private var fullscreenAnimation

    public var body: some View {
        ZStack(alignment: self.alignment) {
            Button(action: {
                withAnimation {
                    self.fullScreen.toggle()
                }
            }, label: {
                if fullScreen {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                } else {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
            })
            .padding()
            .matchedGeometryEffect(id: "fullscreenarrows", in: fullscreenAnimation)
            
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(fullScreen)
        .statusBarHidden(fullScreen)
    }
}

public struct FullscreenableModifier: ViewModifier {

    var alignment: Alignment

    public func body(content: Content) -> some View {
        FullscreenableView(alignment: alignment) {
            content
        }
    }
}

public extension View {
    func fullscreenable(alignment: Alignment = .topTrailing) -> some View {
        self.modifier(FullscreenableModifier(alignment: alignment))
    }
}

#Preview {
    Text("")
}
