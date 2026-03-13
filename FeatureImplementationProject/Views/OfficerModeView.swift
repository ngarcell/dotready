import SwiftUI

struct OfficerModeView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDocIDs: Set<UUID> = []
    @State private var showPresentation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !showPresentation {
                    List(store.documents, selection: $selectedDocIDs) { doc in
                        HStack(spacing: 12) {
                            if let imageData = doc.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(.rect(cornerRadius: 8))
                            } else {
                                Image(systemName: doc.category.icon)
                                    .font(.title3)
                                    .frame(width: 50, height: 50)
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .clipShape(.rect(cornerRadius: 8))
                            }
                            VStack(alignment: .leading) {
                                Text(doc.name)
                                    .font(.body.weight(.medium))
                                Text(doc.category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .environment(\.editMode, .constant(.active))

                    Button {
                        showPresentation = true
                    } label: {
                        Text("Show Selected (\(selectedDocIDs.count))")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.dotBlue)
                    .disabled(selectedDocIDs.isEmpty)
                    .padding()
                } else {
                    officerPresentationView
                }
            }
            .navigationTitle(showPresentation ? "Documents" : "Show to Officer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(showPresentation ? "Back" : "Close") {
                        if showPresentation {
                            showPresentation = false
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private var officerPresentationView: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView {
                ForEach(store.documents.filter { selectedDocIDs.contains($0.id) }) { doc in
                    VStack(spacing: 20) {
                        if let imageData = doc.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 12))
                        } else {
                            Image(systemName: doc.category.icon)
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Text(doc.name)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text(doc.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(24)
                }
            }
            .tabViewStyle(.page)
        }
    }
}
