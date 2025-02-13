//
//  RegisterView.swift
//  ToDoClient
//
//  Created by Maxim Makarenkov on 10.12.2024.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var username = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $passwordConfirmation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.register(
                    username: username,
                    password: password,
                    passwordConfirmation: passwordConfirmation
                )
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    Text("Register")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            if viewModel.registrationSuccess != nil && viewModel.registrationSuccess! {
                Text("Registration Successful!")
                    .foregroundColor(.green)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Register")
    }
}
