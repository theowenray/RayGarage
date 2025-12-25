import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "car.2.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "Add your first vehicle",
        message: "Track service reminders, parts, and costs with RayGarage."
    )
}
