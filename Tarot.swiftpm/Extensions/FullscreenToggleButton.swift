//
//  SwiftUIView.swift
//  
//
//  Created by Giantwow on 04/01/2024.
//

import SwiftUI

public struct FullscreenToggleButton: View {
    
    @State private var fullScreen = false
    @Namespace private var fullscreenAnimation
    
    public var body: some View {
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
        .matchedGeometryEffect(id: "fullscreenarrows", in: fullscreenAnimation)
        .navigationBarHidden(fullScreen)
        .statusBarHidden(fullScreen)
    }
}

#Preview {
    Text("")
}
