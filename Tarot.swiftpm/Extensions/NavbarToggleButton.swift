//
//  SwiftUIView.swift
//  
//
//  Created by Giantwow on 04/01/2024.
//

import SwiftUI

public struct NavbarToggleButton: View {
    
    @State private var fullScreen = false
    @Namespace private var fullscreenAnimation
    
    public var body: some View {
        Button(action: {
            withAnimation {
                self.fullScreen.toggle()
            }
        }, label: {
            if fullScreen {
                Image(systemName: "rectangle.arrowtriangle.2.inward")
            } else {
                Image(systemName: "rectangle.arrowtriangle.2.outward")
            }
        })
        .matchedGeometryEffect(id: "fullscreenarrows", in: fullscreenAnimation)
        .navigationBarHidden(fullScreen)
        .statusBarHidden(fullScreen)
    }
}

#Preview {
    Text("")
}
