import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "clipboard")
        } description: {
            Text(message)
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(
        title: "Add your first vehicle",
        message: "Track service reminders, parts, and costs with RayGarage."
    )
}
