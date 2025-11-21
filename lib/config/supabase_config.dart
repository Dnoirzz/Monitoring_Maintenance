/// Supabase Configuration
/// Store Supabase URL and Anon Key for the project
class SupabaseConfig {
  // NOTE: Replace with your actual Supabase credentials
  // Your Supabase URL: https://dxzkxvczjdviuvmgwsft.supabase.co
  static const String supabaseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co';

  // TODO: Replace this with your actual ANON KEY from Supabase dashboard
  // You can find it in: Project Settings > API > Project API keys > anon public
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4emt4dmN6amR2aXV2bWd3c2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1OTYyMzYsImV4cCI6MjA3OTE3MjIzNn0.cXYHeOepjMX8coJWqTaiz5GlEgAGhm35VMwIqvQhTTw';

  // Connection string (for reference, not used in Flutter app)
  // postgresql://postgres.dxzkxvczjdviuvmgwsft:[YOUR-PASSWORD]@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres
}
