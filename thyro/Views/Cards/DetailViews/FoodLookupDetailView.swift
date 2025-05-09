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
    @State private var searchResults: [SearchResultItem] = []
    @State private var isSearching: Bool = false // To show loading or progress
    
    // Placeholder for actual search logic
    func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        // Simulate a network call or database lookup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Example results - replace with actual search logic
            let allItems = [
                SearchResultItem(name: "Sushi (with soy sauce)", category: "Restaurant", isLIDCompliant: false),
                SearchResultItem(name: "Plain Rice Cakes", category: "Packaged Food", isLIDCompliant: true),
                SearchResultItem(name: "Sea Salt (non-iodized)", category: "Ingredient", isLIDCompliant: true),
                SearchResultItem(name: "Table Salt (iodized)", category: "Ingredient", isLIDCompliant: false),
                SearchResultItem(name: "McDonald's Fries (check local sourcing)", category: "Restaurant", isLIDCompliant: false), // Often false due to salt
                SearchResultItem(name: "Fresh Chicken Breast (unseasoned)", category: "Ingredient", isLIDCompliant: true),
                SearchResultItem(name: "Whole Wheat Bread (check ingredients for iodates)", category: "Packaged Food", isLIDCompliant: false),
                SearchResultItem(name: "Egg Whites", category: "Ingredient", isLIDCompliant: true),
                SearchResultItem(name: "Egg Yolks", category: "Ingredient", isLIDCompliant: false),
            ]
            searchResults = allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.localizedCaseInsensitiveContains(searchText) }
            isSearching = false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search foods, ingredients, restaurants...", text: $searchText, onCommit: performSearch)
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.search)
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
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

            // Results List / Content Area
            if isSearching {
                ProgressView()
                    .padding(.top, 50)
                Spacer()
            } else if searchResults.isEmpty && !searchText.isEmpty && !isSearching {
                Text("No results found for \"\(searchText)\".")
                    .foregroundColor(.secondary)
                    .padding(.top, 50)
                Spacer()
            } else if searchResults.isEmpty && searchText.isEmpty {
                VStack {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 10)
                    Text("Ready to look up LID-friendly options?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Use the search bar above to check for compliance of various foods and ingredients for your Low Iodine Diet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 50)
                Spacer()
            } else {
                List(searchResults) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.category)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: item.isLIDCompliant ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(item.isLIDCompliant ? .green : .red)
                            .font(.title2)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("LID Food Lookup")
        // .navigationBarTitleDisplayMode(.inline) // Optional: if you prefer a smaller title
    }
}

#Preview {
    NavigationView {
        FoodLookupDetailView()
    }
} 