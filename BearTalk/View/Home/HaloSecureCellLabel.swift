import SwiftUI

struct HaloSecureCellLabel: View {
    let statusText: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Halo Secure")
                    .font(.headline)

                Spacer()
            }

            HStack {
                Text("Anti-Theft Protection: \(statusText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
