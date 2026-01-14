//
//  EditNicknameSheet.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 1/17/25.
//

import SwiftUI

struct EditNicknameSheet: View {
    @Binding var nickname: String
    @Binding var isPresented: Bool
    let onSave: (String) -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Vehicle Name", text: $nickname)
                        .focused($isTextFieldFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Edit Vehicle Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, watchOS 26.0, *) {
                        Button(role: .cancel) {
                            isPresented = false
                        }
                        .fontWeight(.semibold)
                        .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .fontWeight(.semibold)
                        .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, watchOS 26.0, *) {
                        Button(role: .confirm) {
                            onSave(nickname)
                            isPresented = false
                        }
                        .fontWeight(.semibold)
                        .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                        .tint(.active)
                    } else {
                        Button("Save") {
                            onSave(nickname)
                            isPresented = false
                        }
                        .fontWeight(.semibold)
                        .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                        .tint(.active)
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    EditNicknameSheet(
        nickname: .constant("Stella"),
        isPresented: .constant(true),
        onSave: { _ in }
    )
}
