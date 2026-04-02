//
//  Testing_AgentsApp.swift
//  Testing-Agents
//
//  Created by Saket Pandhare on 02/04/26.
//

import SwiftUI

@main
struct Testing_AgentsApp: App {
    private let container = ServiceContainer.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CreateAccountView(
                    viewModel: CreateAccountViewModel(authService: container.authService)
                )
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signIn:
                        SignInWithEmailView(
                            viewModel: SignInWithEmailViewModel(authService: container.authService)
                        )
                    }
                }
            }
        }
    }
}

enum AuthRoute: Hashable {
    case signIn
}
