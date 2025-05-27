import SwiftUI

struct AlertCell: View {
    @Environment(DataModel.self) var model
    
    var body: some View {
        if !model.alerts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("Alert", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                
                ForEach(model.alerts, id: \.self) { alert in
                    Text(alert)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    Color.active.opacity(0.3)
                    
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
        }
    }
}

#Preview {
    AlertCell()
        .environment(DataModel())
} 
