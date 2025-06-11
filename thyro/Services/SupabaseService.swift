import Foundation
import SwiftUI
import Supabase 

class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient 

    private init() {
        let supabaseURLString = "https://ujlpmxkrjcgtyvsecqcw.supabase.co" 
        let supabaseAnonKeyString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqbHBteGtyamNndHl2c2VjcWN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4MDg1MTksImV4cCI6MjA1NjM4NDUxOX0.Q0cvx7_GPhg6il61n-P4SVLK-d8P0KqCKxv4VFAGrvc"

        guard let supabaseURL = URL(string: supabaseURLString),
              !supabaseAnonKeyString.isEmpty,
              supabaseURLString != "YOUR_SUPABASE_URL",
              supabaseAnonKeyString != "YOUR_SUPABASE_ANON_KEY" else {
            fatalError("Supabase URL or Anon Key is missing, invalid, or still using placeholders. Please update them in SupabaseService.swift")
        }

        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKeyString)
        print("SupabaseService initialized with client.")
        
        // Attempt to sign in anonymously when the service is initialized
        // This is a good place if you want auto-sign-in.
        // Consider adding a check if already signed in to avoid redundant calls.
        Task {
            await signInAnonymouslyIfNeeded()
        }
    }

    func signInAnonymouslyIfNeeded() async {
        do {
            // Check if there's an existing session. Supabase client handles session persistence.
            let session = try await client.auth.session
            print("SupabaseService: Session restored for User ID \(session.user.id)")
        } catch AuthError.sessionNotFound {
            print("SupabaseService: No active session. Attempting anonymous sign-in...")
            await signInAnonymously()
        } catch {
            // Other potential errors when trying to get session
            print("SupabaseService: Error checking session: \(error). Attempting anonymous sign-in...")
            await signInAnonymously() // Fallback to sign-in attempt
        }
    }
    
    private func signInAnonymously() async {
        do {
            let session = try await client.auth.signInAnonymously()
            print("SupabaseService: Successfully signed in anonymously: User ID \(session.user.id)")
        } catch {
            print("SupabaseService: Error signing in anonymously: \(error)")
            // Handle error appropriately, e.g., retry logic, inform user, or operate offline.
        }
    }
    
    // MARK: - JourneyProfile
    func pushProfile(_ profile: JourneyProfile) {
        LocalStore.saveProfile(profile) // Save locally first
        OfflineQueue.shared.addTask { [weak self] in
            guard let self = self else { return }
            Task {
                do {
                    // Assuming profile.id is the primary key and we want to link to auth.uid() eventually
                    // For anonymous auth, client.auth.session.user.id is the key.
                    // You might need a user_id field in your JourneyProfile struct and table.
                    // For now, using profile.id, assuming it's unique.
                    try await self.client.database
                        .from("journey_profiles")
                        .upsert(profile) // JourneyProfile needs to be Codable
                    print("SupabaseService: JourneyProfile pushed for UserID \(profile.user_id).")
                } catch {
                    print("SupabaseService: Error pushing JourneyProfile for UserID \(profile.user_id): \(error).")
                    // TODO: Implement retry logic or re-queueing if needed
                }
            }
        }
    }

    func pullProfile(for userID: UUID) async -> JourneyProfile? {
        print("SupabaseService: Pulling JourneyProfile for UserID \(userID)...")
        do {
            // Again, assuming one profile per user, and using a user_id for fetching.
            // If not using user_id, you'd need another way to identify the correct profile.
            // let currentUserID = try await client.auth.session.user.id
            // For now, let's assume we fetch based on a known ID or just the first one for simplicity of the stub.
            // This needs to be adapted to your actual data model (e.g., filter by user_id).
            let profiles: [JourneyProfile] = try await client.database
                .from("journey_profiles")
                .select()
                .eq("user_id", value: userID) // Filter by user_id
                .limit(1) // Placeholder: adjust query as needed
                .execute()
                .value
            
            if let profile = profiles.first {
                LocalStore.saveProfile(profile) // Cache latest from server
                print("SupabaseService: JourneyProfile pulled successfully for UserID \(userID).")
                return profile
            } else {
                print("SupabaseService: No JourneyProfile found on server for UserID \(userID).")
                return nil // Important: return nil if not found, LocalStore load will be fallback
            }
        } catch {
            print("SupabaseService: Error pulling JourneyProfile for UserID \(userID): \(error).")
            return nil // Fallback to nil, let caller decide on LocalStore
        }
    }

    // MARK: - UserConfig
    func pushConfig(_ config: UserConfig) {
        LocalStore.saveConfig(config) 
        OfflineQueue.shared.addTask { [weak self] in
            guard let self = self else { return }
            Task {
                do {
                    try await self.client.database
                        .from("user_configs")
                        .upsert(config)
                    print("SupabaseService: UserConfig pushed for UserID \(config.user_id).")
                } catch {
                    print("SupabaseService: Error pushing UserConfig for UserID \(config.user_id): \(error).")
                }
            }
        }
    }

    func pullConfig(for userID: UUID) async -> UserConfig? {
        print("SupabaseService: Pulling UserConfig for UserID \(userID)...")
        do {
            let configs: [UserConfig] = try await client.database
                .from("user_configs")
                .select()
                .eq("user_id", value: userID) // Filter by user_id
                .limit(1) // Placeholder
                .execute()
                .value
            if let config = configs.first {
                LocalStore.saveConfig(config)
                print("SupabaseService: UserConfig pulled successfully for UserID \(userID).")
                return config
            } else {
                print("SupabaseService: No UserConfig found on server for UserID \(userID).")
                return nil
            }
        } catch {
            print("SupabaseService: Error pulling UserConfig for UserID \(userID): \(error).")
            return nil
        }
    }
    
    // MARK: - LID Food Items
    func fetchLIDFoodItems(searchTerm: String, categoryFilter: LIDFoodParentCategory?) async throws -> [LIDFoodItem] {
        print("SupabaseService: Fetching LID Food Items. Search: '\(searchTerm)', Category: '\(categoryFilter?.rawValue ?? "None")'")
       
        var query = client.database.from("lid_food_items").select() // Returns PostgrestTransformBuilder

        if let categoryFilter = categoryFilter {
            // .eq returns PostgrestFilterBuilder. This can be chained to .select() directly.
            query = query.eq("parent_category", value: categoryFilter.rawValue) 
        }

        if !searchTerm.isEmpty {
            let searchPattern = "%\(searchTerm)%"
            // .or also returns PostgrestFilterBuilder, can be chained.
            query = query.or("name.ilike.\(searchPattern),brand.ilike.\(searchPattern),sub_category.ilike.\(searchPattern)")
        }
        
        // .limit returns PostgrestTransformBuilder. This assignment is fine.
        let finalQuery = query.limit(50) 

        do {
           let items: [LIDFoodItem] = try await finalQuery.execute().value
           print("SupabaseService: Fetched \(items.count) LID food items.")
           return items
        } catch {
           print("SupabaseService: Error fetching LID food items: \(error)")
           throw error 
        }
    }
} 