import SwiftUI
import PhotosUI

struct DocumentsGalleryView: View {
    @Environment(DataStore.self) private var store
    @Environment(SubscriptionManager.self) private var subscription
    @State private var selectedCategory: DocumentCategory?
    @State private var showAddDocument = false
    @State private var selectedDocument: StoredDocument?
    @State private var showOfficerMode = false
    @State private var showPaywall = false

    private var filteredDocuments: [StoredDocument] {
        guard let cat = selectedCategory else { return store.documents }
        return store.documents.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    categoryFilterBar

                    if filteredDocuments.isEmpty {
                        ContentUnavailableView("No Documents", systemImage: "doc.text", description: Text("Add documents to your vault."))
                            .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(filteredDocuments) { doc in
                                DocumentCard(document: doc) {
                                    selectedDocument = doc
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            if subscription.canUseDocumentVault || store.documents.isEmpty {
                                showAddDocument = true
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Label("Add Document", systemImage: "plus")
                        }
                        if !store.documents.isEmpty {
                            Button {
                                if subscription.canUseOfficerMode {
                                    showOfficerMode = true
                                } else {
                                    showPaywall = true
                                }
                            } label: {
                                Label("Show to Officer", systemImage: "person.badge.shield.checkmark")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddDocument) {
                AddDocumentView()
            }
            .sheet(item: $selectedDocument) { doc in
                DocumentDetailView(document: doc)
            }
            .fullScreenCover(isPresented: $showOfficerMode) {
                OfficerModeView()
            }
            .sheet(isPresented: $showPaywall) {
                UpgradePaywallView()
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(DocumentCategory.allCases) { cat in
                    FilterChip(label: cat.rawValue, isSelected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }
}

struct DocumentCard: View {
    let document: StoredDocument
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                if let imageData = document.imageData, let uiImage = UIImage(data: imageData) {
                    Color(.tertiarySystemGroupedBackground)
                        .frame(height: 120)
                        .overlay {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadii: .init(topLeading: 12, topTrailing: 12)))
                } else {
                    ZStack {
                        Color(.tertiarySystemGroupedBackground)
                        Image(systemName: document.category.icon)
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 120)
                    .clipShape(.rect(cornerRadii: .init(topLeading: 12, topTrailing: 12)))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Text(document.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
