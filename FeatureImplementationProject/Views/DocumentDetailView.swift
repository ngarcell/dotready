import SwiftUI

struct DocumentDetailView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let document: StoredDocument
    @State private var showDeleteAlert = false
    @State private var showFullScreen = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let imageData = document.imageData, let uiImage = UIImage(data: imageData) {
                        Button { showFullScreen = true } label: {
                            Color(.secondarySystemGroupedBackground)
                                .frame(height: 300)
                                .overlay {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .allowsHitTesting(false)
                                }
                                .clipShape(.rect(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    } else {
                        ZStack {
                            Color(.secondarySystemGroupedBackground)
                            Image(systemName: document.category.icon)
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 200)
                        .clipShape(.rect(cornerRadius: 14))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.name)
                                .font(.title2.bold())
                            Text(document.category.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if !document.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes")
                                    .font(.headline)
                                Text(document.notes)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Added")
                                .font(.headline)
                            Text(document.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Document", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Document?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    store.deleteDocument(document)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showFullScreen) {
                FullScreenDocumentView(document: document)
            }
        }
    }
}

struct FullScreenDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    let document: StoredDocument

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let imageData = document.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}
