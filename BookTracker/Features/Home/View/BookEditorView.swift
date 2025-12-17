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
    @Environment(\.dismiss) private var dismiss
    
    // State Object
    @State var viewModel: BookEditorViewModel
    @State private var isReadingNow: Bool = false
    
    // State for Image Picking
    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var selectedImage: UIImage?
    
    init(viewModel: BookEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        // Bindable wajib ada di body untuk akses $variable
        @Bindable var vm = viewModel
        
        Form {
            // 1. Autofill
            makeAutofillSection(vm: viewModel)
            
            // 2. Cover Section
            Section {
                coverPickerRow
                removeCoverButtonRow
            }
            .listRowBackground(Color.clear)
            
            // 3. Metadata with Validation
            Section(header: Text("Book Info")) {
                TextField("Title", text: $vm.title)
                // Panggil Helper: Cuma muncul kalo udah diketik atau ditekan save
                if let error = vm.errorMessage(for: .title) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                
                TextField("Author", text: $vm.author)
                if let error = vm.errorMessage(for: .author) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                
                TextField("Total Pages", text: $vm.totalPages)
                    .keyboardType(.numberPad)
                if let error = vm.errorMessage(for: .totalPages) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            
            // 4. Status
            Section {
                Toggle(isOn: $isReadingNow) {
                    Label("Start Reading Now", systemImage: "book.fill")
                }
                .tint(.blue)
            } footer: {
                Text(isReadingNow ? "Book will appear in 'Reading Now'" : "Book will start in 'Library (To Read)'")
            }
            
            // 5. Delete
            if case .edit = viewModel.mode {
                Section {
                    Button("Delete Book", role: .destructive) {
                        vm.deleteBook()
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            makeToolbarContent(vm: viewModel)
        }
        .sheet(isPresented: $vm.showSearchSheet) {
            GoogleBooksSearchSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage = newImage {
                viewModel.process(image: newImage)
            }
        }
        .onAppear {
            isReadingNow = (viewModel.status == .reading)
        }
        .photosPicker(isPresented: $showLibrary, selection: $viewModel.photoSelection, matching: .images)
    }
    
    var navTitle: String {
        switch viewModel.mode {
        case .create: return "Add New Book"
        case .edit: return "Edit Book Details"
        }
    }
}

// MARK: - Subviews

private extension BookEditorView {
    
    var coverPickerRow: some View {
        HStack {
            Spacer()
            Button {
                showImageSourceDialog = true
            } label: {
                coverArtView(data: viewModel.coverImageData)
            }
            .buttonStyle(.plain)
            .confirmationDialog("Add Cover Photo", isPresented: $showImageSourceDialog, titleVisibility: .visible) {
                Button("Choose from Library") {
                    showLibrary = true
                }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo") {
                        showCamera = true
                    }
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var removeCoverButtonRow: some View {
        if viewModel.coverImageData != nil {
            Button("Remove Cover", role: .destructive) {
                withAnimation {
                    viewModel.coverImageData = nil
                    viewModel.photoSelection = nil
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    func coverArtView(data: Data?) -> some View {
        if let data = data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable().scaledToFit().frame(height: 180).cornerRadius(8).shadow(radius: 4)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pencil.circle.fill").font(.title).foregroundStyle(.white).shadow(radius: 2).offset(x: 10, y: 10)
                }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "photo.badge.plus").font(.system(size: 40)).foregroundStyle(.blue)
                Text("Tap to Add Cover").font(.caption).foregroundStyle(.secondary)
            }.frame(height: 150).frame(maxWidth: .infinity).background(Color.gray.opacity(0.1)).cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundStyle(.gray.opacity(0.3)))
        }
    }
    
    func makeAutofillSection(vm: BookEditorViewModel) -> some View {
        @Bindable var vm = vm
        return Section {
            Button(action: { vm.showSearchSheet = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Autofill data from Google Books")
                }.frame(maxWidth: .infinity)
            }.tint(.blue)
        }
    }
    
    @ToolbarContentBuilder
    @MainActor
    func makeToolbarContent(vm: BookEditorViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                // Saat diklik, save() akan set hasAttemptedSave = true
                // Jadi field yg kosong akan langsung merah semua
                if vm.save() {
                    dismiss()
                }
            }
            .disabled(!vm.isFormValid)
        }
        
        if case .create = vm.mode {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
