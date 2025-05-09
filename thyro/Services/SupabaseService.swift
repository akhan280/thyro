import Foundation
// import Supabase

// REMINDER: Add the Supabase Swift package to your project:
// In Xcode: File > Add Packages...
// URL: https://github.com/supabase/supabase-swift.git
// Version: .upToNextMajor(from: "0.3.0") (or as specified)

class SupabaseService {
    static let shared = SupabaseService()

    // private var client: SupabaseClient? // Initialize this after configuring Supabase

    private init() {
        // Initialize Supabase client here with your URL and anon key
        // Example (replace with your actual credentials and initialization):
        // self.client = SupabaseClient(supabaseURL: URL(string: "YOUR_SUPABASE_URL")!, supabaseKey: "YOUR_SUPABASE_ANON_KEY")
        // signInAnonymously() // Or call this when appropriate
        print("SupabaseService initialized. REMINDER: Configure Supabase client and add package.")
    }

    func signInAnonymously() async {
        print("SupabaseService: Attempting anonymous sign-in...")
        // Guard client else { print("Supabase client not initialized."); return }
        // do {
        //     let session = try await client!.auth.signInAnonymously()
        //     print("Successfully signed in anonymously: \(session)")
        // } catch {
        //     print("Error signing in anonymously: \(error)")
        // }
        print("SupabaseService: signInAnonymously() (stubbed)")
    }

    // MARK: - JourneyProfile
    func pushProfile(_ profile: JourneyProfile) {
        LocalStore.saveProfile(profile) // Save locally first
        OfflineQueue.shared.addTask { [weak self] in
            // Task to push to Supabase
            // Guard let self = self, let client = self.client else { return }
            // Task {
            //     do {
            //         try await client.database
            //             .from("journey_profiles")
            //             .upsert(profile) // Assuming JourneyProfile is Encodable to match table
            //         print("SupabaseService: JourneyProfile pushed successfully.")
            //     } catch {
            //         print("SupabaseService: Error pushing JourneyProfile: \(error). Will retry later.")
            //         // Re-add to queue or handle error appropriately for retry
            //         // For simplicity, this example doesn't re-add automatically for now.
            //         // self.pushProfile(profile) // Be careful with re-adding to avoid infinite loops without backoff
            //     }
            // }
            print("OfflineQueue Task: Pushing JourneyProfile for ID \(profile.id) (stubbed)")
        }
    }

    func pullProfile() async -> JourneyProfile? {
        print("SupabaseService: Pulling JourneyProfile...")
        // Guard let client = client else { 
        //     print("Supabase client not initialized.")
        //     return LocalStore.loadProfile() // Fallback to local if Supabase not available
        // }
        // do {
        //     let profiles: [JourneyProfile] = try await client.database
        //         .from("journey_profiles")
        //         .select()
        //         .limit(1) // Assuming one profile per user for now
        //         .execute()
        //         .value
        //     if let profile = profiles.first {
        //         LocalStore.saveProfile(profile) // Cache latest from server
        //         return profile
        //     } else {
        //         return LocalStore.loadProfile() // Fallback if not found on server
        //     }
        // } catch {
        //     print("Error pulling JourneyProfile: \(error). Falling back to local store.")
        //     return LocalStore.loadProfile()
        // }
        print("SupabaseService: pullProfile() (stubbed, returning local data)")
        return LocalStore.loadProfile()
    }

    // MARK: - UserConfig
    func pushConfig(_ config: UserConfig) {
        LocalStore.saveConfig(config) // Save locally first
        OfflineQueue.shared.addTask { [weak self] in
            // Task to push to Supabase
            // Guard let self = self, let client = self.client else { return }
            // Task {
            //     do {
            //         try await client.database
            //             .from("user_configs")
            //             .upsert(config)
            //         print("SupabaseService: UserConfig pushed successfully.")
            //     } catch {
            //         print("SupabaseService: Error pushing UserConfig: \(error). Will retry later.")
            //     }
            // }
            print("OfflineQueue Task: Pushing UserConfig for ID \(config.id) (stubbed)")
        }
    }

    func pullConfig() async -> UserConfig? {
        print("SupabaseService: Pulling UserConfig...")
        // Guard let client = client else {
        //     print("Supabase client not initialized.")
        //     return LocalStore.loadConfig() // Fallback to local
        // }
        // do {
        //     let configs: [UserConfig] = try await client.database
        //         .from("user_configs")
        //         .select()
        //         .limit(1) // Assuming one config per user
        //         .execute()
        //         .value
        //     if let config = configs.first {
        //         LocalStore.saveConfig(config) // Cache latest from server
        //         return config
        //     } else {
        //         return LocalStore.loadConfig() // Fallback if not found on server
        //     }
        // } catch {
        //     print("Error pulling UserConfig: \(error). Falling back to local store.")
        //     return LocalStore.loadConfig()
        // }
        print("SupabaseService: pullConfig() (stubbed, returning local data)")
        return LocalStore.loadConfig()
    }
} 