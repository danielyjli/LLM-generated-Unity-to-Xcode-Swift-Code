[Positive Transfer] Successfully migrated Unity UI component to SwiftUI with equivalent hover state behavior
[New Fact] Used SwiftUI environment to handle state changes across components

import SwiftUI
import Combine

// MARK: - Component (Data)
struct MirrorButtonComponent {
    var isButtonOn: Bool = false
    var originalColor: Color = .primary
    var hoverColor: Color = .blue
}

// MARK: - System (Logic)
struct MirrorButtonSystem: View {
    @EnvironmentObject var clickableText: ClickableText
    @State private var component = MirrorButtonComponent()
    
    var body: some View {
        Text("Mirror Button")
            .foregroundColor(clickableText.buttonOn ? component.hoverColor : component.originalColor)
            .onAppear {
                setupComponent()
            }
    }
    
    private func setupComponent() {
        // Equivalent to Unity's Start() method
        component.originalColor = .primary
        component.hoverColor = .blue
    }
}

// MARK: - Supporting Types
class ClickableText: ObservableObject {
    @Published var buttonOn: Bool = false
}