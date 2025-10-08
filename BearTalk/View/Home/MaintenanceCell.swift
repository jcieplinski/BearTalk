import SwiftUI

struct MaintenanceCell: View {
    @Environment(DataModel.self) var model
    
    var body: some View {
        NavigationLink {
            MaintenanceView()
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text("Maintenance")
                        .font(.headline)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Tire Pressure Monitoring")
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
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MaintenanceCell()
            .environment(DataModel())
            .padding()
    }
}
