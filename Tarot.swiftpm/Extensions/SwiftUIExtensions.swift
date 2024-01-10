import SwiftUI

extension Binding where Value == Bool {
    
    init<T>(optional: Binding<T?>) {
        self.init {
            optional.wrappedValue != nil
        } set: { value in
            if value {
                
            } else {
                optional.wrappedValue = nil
            }
        }

    }
}
