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
    
    // State for Image Picking
    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var selectedImage: UIImage?
    @State private var showDeleteConfirmation = false
    
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
            Section(header: Text(String(localized: "Book Info"))) {
                TextField(String(localized: "Title"), text: $vm.title)
                // Panggil Helper: Cuma muncul kalo udah diketik atau ditekan save
                if let error = vm.errorMessage(for: .title) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                
                TextField(String(localized: "Author"), text: $vm.author)
                if let error = vm.errorMessage(for: .author) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                
                TextField(String(localized: "Total Pages"), text: $vm.totalPages)
                    .keyboardType(.numberPad)
                if let error = vm.errorMessage(for: .totalPages) {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            
            // 4. Status
            Section {
                Toggle(isOn: $viewModel.isReadingNow) {
                    Label(String(localized: "Start Reading Now"), systemImage: "book.fill")
                }
                .tint(.blue)
            } footer: {
                Text(viewModel.isReadingNow ? String(localized: "Book will appear in 'Reading Now'") : String(localized: "Book will start in 'Library (To Read)'"))
            }
            
            // 5. Delete
            if case .edit = viewModel.mode {
                Section {
                    Button(String(localized: "Delete Book"), role: .destructive) {
                        showDeleteConfirmation = true
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
        .photosPicker(isPresented: $showLibrary, selection: $viewModel.photoSelection, matching: .images)
        .confirmationDialog(
            String(localized: "Delete Book?"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                viewModel.deleteBook()
                dismiss()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "Deleting this book will also remove all your reading progress. This action cannot be undone."))
        }
    }
    
    var navTitle: String {
        switch viewModel.mode {
        case .create: return String(localized: "Add New Book")
        case .edit: return String(localized: "Edit Book Details")
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
            .confirmationDialog(String(localized: "Add Cover Photo"), isPresented: $showImageSourceDialog, titleVisibility: .visible) {
                Button(String(localized: "Choose from Library")) {
                    showLibrary = true
                }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button(String(localized: "Take Photo")) {
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
            Button(String(localized: "Remove Cover"), role: .destructive) {
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
                Text(String(localized: "Tap to Add Cover")).font(.caption).foregroundStyle(.secondary)
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
                    Text(String(localized: "Autofill data from Google Books"))
                }.frame(maxWidth: .infinity)
            }.tint(.blue)
        }
    }
    
    @ToolbarContentBuilder
    @MainActor
    func makeToolbarContent(vm: BookEditorViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(String(localized: "Save")) {
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
                Button(String(localized: "Cancel")) { dismiss() }
            }
        }
    }
}
