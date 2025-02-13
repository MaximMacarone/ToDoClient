//
//  RegistrationViewModel.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationSuccess: Bool?

    func register(username: String, password: String, passwordConfirmation: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let success = try await NetworkService.shared.register(
                    username: username,
                    password: password,
                    passwordConfirmation: passwordConfirmation
                )
                DispatchQueue.main.async {
                    self.registrationSuccess = success
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to register: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
