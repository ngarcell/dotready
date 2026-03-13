import SwiftUI
import PhotosUI

struct AddDocumentView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: DocumentCategory = .other
    @State private var notes = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var linkedComplianceItemID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Document Info") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(DocumentCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Photo") {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Color(.tertiarySystemGroupedBackground)
                            .frame(height: 200)
                            .overlay {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(.rect(cornerRadius: 10))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        Button(role: .destructive) {
                            self.imageData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                }

                if !store.complianceItems.isEmpty {
                    Section("Link to Compliance Item") {
                        Picker("Compliance Item", selection: $linkedComplianceItemID) {
                            Text("None").tag(UUID?.none)
                            ForEach(store.complianceItems) { item in
                                Text(item.name).tag(UUID?.some(item.id))
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDocument()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    private func saveDocument() {
        let doc = StoredDocument(name: name, category: category, imageData: imageData, linkedComplianceItemID: linkedComplianceItemID, notes: notes)
        store.addDocument(doc)

        if let compID = linkedComplianceItemID,
           var compItem = store.complianceItems.first(where: { $0.id == compID }) {
            compItem.linkedDocumentIDs.append(doc.id)
            store.updateComplianceItem(compItem)
        }
    }
}
