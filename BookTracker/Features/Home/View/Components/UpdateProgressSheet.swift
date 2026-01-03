//
//  UpdateProgressSheet.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//
import SwiftUI

struct UpdateProgressSheet: View {
    // MARK: - Properties
    let book: Book
    let maxPage: Int
    var scannedPage: String?
    var onSubmit: (Int) async -> Void
    
    // MARK: - State
    @State private var inputPage: String = ""
    @State private var showAlert = false
    @State private var isSaving = false
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    // MARK: - Computed Properties
    private var pageInputError: String? {
        guard let page = Int(inputPage), !inputPage.isEmpty else { return nil }
        if page <= book.currentPage {
            return String(format: NSLocalizedString("Page must be greater than current page (%lld).", comment: ""), book.currentPage)
        }
        return nil
    }
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Form Content
                Form {
                    inputSection
                }
                .navigationTitle(String(localized: "Update Progress"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .onAppear(perform: setupView)
                .onChange(of: inputPage, perform: validateInput)
                .alert(String(localized: "Invalid Page"), isPresented: $showAlert) {
                    Button(String(localized: "OK")) { }
                } message: {
                    Text(String(format: NSLocalizedString("Please enter a valid page number between %lld and %lld.", comment: ""), book.currentPage, maxPage))
                }
                .disabled(isSaving) // Disable form while saving
                
                // Native Loading Overlay
                if isSaving {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    ProgressView(String(localized: "Saving..."))
                        .progressViewStyle(.circular)
                        .tint(.primary)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(.thickMaterial))
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    // MARK: - Components & Builders
    private var inputSection: some View {
        Section {
            HStack {
                Spacer()
                TextField(String(localized: "Halaman"), text: $inputPage)
                    .keyboardType(.numberPad)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            if let error = pageInputError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            Text(String(format: NSLocalizedString("Update progres '%@' (Maks: %lld)", comment: ""), book.title, maxPage))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Batal")) { dismiss() }
                .disabled(isSaving)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(String(localized: "Simpan"), action: {
                Task {
                    await saveAction()
                }
            })
            .disabled(inputPage.isEmpty || isSaving || pageInputError != nil)
        }
    }
    
    // MARK: - Logic & Actions
    
    private func setupView() {
        if let scannedPage = scannedPage, !scannedPage.isEmpty {
            self.inputPage = scannedPage
        } else {
            self.inputPage = String(book.currentPage)
        }
        isFocused = true
    }
    
    private func validateInput(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        
        if filtered != newValue {
            self.inputPage = filtered
        }

        if let number = Int(filtered), number > self.maxPage {
            DispatchQueue.main.async {
                self.inputPage = String(self.maxPage)
            }
        }
    }
    
    private func saveAction() async {
        guard let page = Int(inputPage), page > book.currentPage, page <= maxPage else {
            showAlert = true
            return
        }
        
        isSaving = true
        await onSubmit(page)
        isSaving = false
        dismiss()
    }
}
