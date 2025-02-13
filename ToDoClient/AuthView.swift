import SwiftUI

struct AuthView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAuthenticated = false
    @State private var authError: String?

    var body: some View {
        NavigationStack {
            VStack {
                TextField("username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Login") {
                    Task {
                        do {
                            _ = try await NetworkService.shared.login(username: username, password: password)
                            isAuthenticated = true
                        } catch {
                            authError = "Failed to authenticate."
                        }
                    }
                }
                .padding()
                .disabled(username.isEmpty)
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Register")
                }
                
                if let error = authError {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .fullScreenCover(isPresented: $isAuthenticated) {
                TaskListView()
            }
        }
    }
}
