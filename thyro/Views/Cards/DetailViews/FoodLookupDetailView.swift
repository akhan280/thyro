import SwiftUI

// Dummy data for search results
struct SearchResultItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String // e.g., "Restaurant", "Ingredient", "Packaged Food"
    let isLIDCompliant: Bool // Simplified compliance status
}

struct FoodLookupDetailView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [LIDFoodItem] = []
    @State private var isSearching: Bool = false
    @State private var activeFilter: LIDFoodParentCategory? = nil
    @State private var searchTask: Task<Void, Never>? = nil
    
    // Debounce search to avoid too many calls while typing
    private func debouncedPerformSearch() {
        searchTask?.cancel()
        searchTask = Task {
            // Only proceed if the task hasn't been cancelled
            // Add a small delay for typing
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            if Task.isCancelled { return }
            await performSearch()
        }
    }

    private func performSearch() async {
        isSearching = true
        do {
            let items = try await SupabaseService.shared.fetchLIDFoodItems(searchTerm: searchText, categoryFilter: activeFilter)
            if !Task.isCancelled {
                searchResults = items
            }
        } catch {
            if !Task.isCancelled {
                print("Error fetching LID food items: \(error)")
                searchResults = [] // Clear results on error
            }
        }
        if !Task.isCancelled {
            isSearching = false
        }
    }
    
    private var foodSubCategories: [String] = [
        "Fruits", "Vegetables", "Grains & Pasta", "Meats & Poultry",
        "Seafood", "Dairy & Alternatives", "Snacks", "Beverages",
        "Condiments & Sauces", "Baked Goods", "Spreads"
    ] // Example sub-categories for a secondary filter if desired

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search foods, ingredients, restaurants...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.search)
                    .onChange(of: searchText) { _ in debouncedPerformSearch() }
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                        searchTask?.cancel()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)

            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterPill(category: nil, activeFilter: $activeFilter, title: "All")
                    ForEach(LIDFoodParentCategory.allCases, id: \.self) { category in
                        FilterPill(category: category, activeFilter: $activeFilter, title: category.rawValue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .onChange(of: activeFilter) { _ in Task { await performSearch() } }

            // Results List / Content Area
            if isSearching {
                ProgressView("Searching...")
                    .padding(.top, 50)
                Spacer()
            } else if searchResults.isEmpty {
                VStack(alignment: .center, spacing: 15) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.4))
                    Text(searchText.isEmpty && activeFilter == nil ? "Ready to look up LID-friendly options?" : "No Results Found")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty && activeFilter == nil ? "Use the search bar and filters above to check for compliance of various foods and ingredients for your Low Iodine Diet." : "Try adjusting your search term or filters.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 50)
                Spacer()
            } else {
                List(searchResults) { item in
                    LIDFoodItemRow(item: item)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("LID Food Lookup")
        .onAppear {
            // Initial search if needed, e.g., if searchText or filter is pre-filled
            if searchText.isEmpty && activeFilter == nil {
                // Do nothing or load initial suggestions
            } else {
                Task { await performSearch() }
            }
        }
    }
}

struct FilterPill: View {
    let category: LIDFoodParentCategory? // Nil for "All"
    @Binding var activeFilter: LIDFoodParentCategory?
    let title: String
    
    var isSelected: Bool {
        activeFilter == category
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                activeFilter = nil // Deselect if already selected
            } else {
                activeFilter = category
            }
        }) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple.opacity(0.8) : Color(.systemGray4))
                .foregroundColor(isSelected ? .white : Color(.label))
                .cornerRadius(20)
        }
    }
}

struct LIDFoodItemRow: View {
    let item: LIDFoodItem
    
    private var formattedVerifiedDate: String {
        if let date = item.lastVerifiedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short // Or .medium, .long as needed
            formatter.timeStyle = .none
            return "(verified \(formatter.string(from: date)))"
        } else {
            return ""
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.compliance.iconName)
                .foregroundColor(item.compliance.iconColor)
                .font(.system(size: 28))
                .frame(width: 30) // For alignment
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                if let brand = item.brand, !brand.isEmpty {
                    Text("Brand: \(brand)").font(.caption).foregroundColor(.gray)
                }
                if let subCategory = item.subCategory, !subCategory.isEmpty {
                    Text("Category: \(item.parentCategory.rawValue) - \(subCategory)").font(.caption).foregroundColor(.gray)
                } else {
                    Text("Category: \(item.parentCategory.rawValue)").font(.caption).foregroundColor(.gray)
                }
                if let notes = item.notes, !notes.isEmpty {
                    Text("Notes: \(notes)").font(.footnote).italic().foregroundColor(.orange)
                }
                if let dataSource = item.dataSource, !dataSource.isEmpty {
                    Text("Source: \(dataSource) \(formattedVerifiedDate)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        FoodLookupDetailView()
    }
} 