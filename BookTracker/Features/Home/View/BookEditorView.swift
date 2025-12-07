//
//  BookEditorView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct BookEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // State Object
    @State var viewModel: BookEditorViewModel
    
    // State lokal buat Toggle UI
    @State private var isReadingNow: Bool = false
    
    init(book: Book? = nil) {
        let vm = book != nil ? BookEditorViewModel(book: book!) : BookEditorViewModel()
        _viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        // Kita butuh @Bindable di sini buat sheet & toolbar
        @Bindable var vm = viewModel
        
        Form {
            // Panggil fungsi pecahan (biar compiler gak timeout)
            // Kita lempar 'viewModel' ke bawah
            makeAutofillSection(vm: viewModel)
            
            makeCoverSection(vm: viewModel)
            
            makeMetadataSection(vm: viewModel)
            
            makeStatusSection() // Pake state lokal isReadingNow
            
            if case .edit = viewModel.mode {
                makeDeleteSection(vm: viewModel)
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            makeToolbarContent(vm: viewModel)
        }
        // Sheet Search
        .sheet(isPresented: $vm.showSearchSheet) {
            GoogleBooksSearchSheet(viewModel: viewModel)
        }
        // Listener Foto (Syntax iOS 17)
        .onChange(of: vm.photoSelection) { _, _ in
            Task { await viewModel.loadPhoto() }
        }
        // Sync awal status toggle
        .onAppear {
            isReadingNow = (viewModel.status == .reading)
        }
    }
    
    var navTitle: String {
        switch viewModel.mode {
        case .create: return "Add New Book"
        case .edit: return "Edit Book Details"
        }
    }
}

// MARK: - UI Breakdown (Solusi Compiler Timeout)
// Logic: Fungsi terima VM -> Bind Ulang -> Return View
private extension BookEditorView {
    
    // 1. Autofill Section
    func makeAutofillSection(vm: BookEditorViewModel) -> some View {
        @Bindable var vm = vm // <--- RE-BINDING (Kunci biar $ jalan & compiler happy)
        return Section {
            Button(action: { vm.showSearchSheet = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Autofill data from Google Books")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
            }
            .tint(.blue)
        }
    }
    
    // 2. Cover Section
    func makeCoverSection(vm: BookEditorViewModel) -> some View {
        @Bindable var vm = vm
        return Section {
            HStack {
                Spacer()
                PhotosPicker(selection: $vm.photoSelection, matching: .images) {
                    if let data = vm.coverImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title).foregroundStyle(.white).shadow(radius: 2).offset(x: 10, y: 10)
                            }
                    } else {
                        VStack {
                            Image(systemName: "photo.badge.plus").font(.system(size: 40)).foregroundStyle(.blue)
                            Text("Tap to Add Cover").font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(height: 150).frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1)).cornerRadius(8)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            if vm.coverImageData != nil {
                Button("Remove Cover", role: .destructive) {
                    vm.coverImageData = nil
                    vm.photoSelection = nil
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // 3. Metadata Section
    func makeMetadataSection(vm: BookEditorViewModel) -> some View {
        @Bindable var vm = vm
        return Section(header: Text("Book Info")) {
            TextField("Title", text: $vm.title)
            TextField("Author", text: $vm.author)
            TextField("Total Pages", text: $vm.totalPages)
                .keyboardType(.numberPad)
        }
    }
    
    // 4. Status Section (Pake State Lokal)
    func makeStatusSection() -> some View {
        Section {
            Toggle(isOn: $isReadingNow) {
                Label("Start Reading Now", systemImage: "book.fill")
            }
            .tint(.blue)
        } footer: {
            Text(isReadingNow ? "Book will appear in 'Reading Now'" : "Book will start in 'Library (To Read)'")
        }
    }
    
    // 5. Delete Section
    func makeDeleteSection(vm: BookEditorViewModel) -> some View {
        Section {
            Button("Delete Book", role: .destructive) {
                vm.deleteBook(context: context)
                dismiss()
            }
        }
    }
    
    // 6. Toolbar Content
    @ToolbarContentBuilder
    func makeToolbarContent(vm: BookEditorViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                // Update status di VM berdasarkan Toggle sebelum save
                vm.status = isReadingNow ? .reading : .shelf
                
                if vm.save(context: context) {
                    dismiss()
                }
            }
            .disabled(vm.title.isEmpty || vm.totalPages.isEmpty)
        }
        
        if case .create = vm.mode {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
