package com.example.utilityapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.page.MainScreen
import com.example.utilityapp.ui.theme.UtilityAppTheme

class MainActivity : ComponentActivity() {
    // Initialize ViewModel
    private val authViewModel: AuthViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Google Sign-In
        authViewModel.initializeGoogleSignIn(this)

        setContent {
            UtilityAppTheme {
                val navController = rememberNavController()
                MainScreen(navController = navController, authViewModel = authViewModel)
            }
        }
    }
}
