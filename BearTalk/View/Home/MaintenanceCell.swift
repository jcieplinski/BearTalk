import SwiftUI

struct MaintenanceCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false
    
    var body: some View {
        Group {
            if isWideMode {
                Button {
                    showSheet = true
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    MaintenanceView()
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                MaintenanceView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if #available(iOS 26.0, *) {
                                Button(role: .confirm) {
                                    showSheet = false
                                }
                            } else {
                                Button("Done") {
                                    showSheet = false
                                }
                            }
                        }
                    }
            }
            .presentationSizing(.page)
        }
    }
    
    private var cellContent: some View {
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
}

#Preview {
    NavigationStack {
        MaintenanceCell(isWideMode: false)
            .environment(DataModel())
            .padding()
    }
}
