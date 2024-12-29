import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func onFirstAppear(perform: (() -> Void)? = nil) -> some View {
        self
            .modifier(OnFirstAppear(perform: perform))
    }
}

struct OnFirstAppear: ViewModifier {
    
    let perform: (() -> Void)?
    @State private var firstTimeCalled = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !firstTimeCalled {
                    perform?()
                    firstTimeCalled = true
                }
            }
    }
}

fileprivate struct Example: View {
    @State private var hidden: Bool = true
    var body: some View {
        VStack {
            Text("Hello, world!")
                .onAppear {
                    print("Appearing")
                }
                .onFirstAppear { 
                    print("First time !")
                }
                .if (hidden) { v in
                    v.hidden()
                }
            Toggle(isOn: $hidden) {
                Text("Hide")
            }
        }
    }
}

#Preview {
    Example()
}
