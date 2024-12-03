package com.example.utilityapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.page.MainScreen
import com.example.utilityapp.ui.theme.UtilityAppTheme

class MainActivity : ComponentActivity() {
    private val authViewModel: AuthViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Google Sign-In client
        authViewModel.initializeGoogleSignIn(this)

        setContent {
            UtilityAppTheme {
                // Observe authentication state
                val authState by authViewModel.authState.observeAsState()

                // Ensure navigation is handled based on auth state
                MyAppNavigation(authViewModel = authViewModel)

                // Trigger auth state check on launch
                LaunchedEffect(Unit) {
                    authViewModel.checkAuthState()
                }
            }
        }
    }
}