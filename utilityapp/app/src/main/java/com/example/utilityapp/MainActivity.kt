package com.example.utilityapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.page.MainScreen
import com.example.utilityapp.pages.HomePage
import com.example.utilityapp.pages.SettingsPage
import com.example.utilityapp.ui.theme.UtilityAppTheme


class MainActivity : ComponentActivity() {
    // Use the viewModels delegate to initialize the ViewModel correctly
    private val authViewModel: AuthViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Google Sign-In before setting content
        authViewModel.initializeGoogleSignIn(this)

        setContent {
            UtilityAppTheme {
                val navController = rememberNavController() // Initialize NavController

                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    MyAppNavigation(
                        modifier = Modifier.padding(innerPadding),
                        authViewModel = authViewModel
                    )

                    // Pass the navController to MainScreen
                    MainScreen(navController = navController)

                    setContent() {
                        UtilityAppTheme {
                            val backgroundColor = null
                            backgroundColor?.let {
                                Surface(color = it, modifier = Modifier.fillMaxSize()) {
                                    // LoginScreen()
                                    //   RegisterScreen()
                                    // ForgotPasswordScreen()
                                    SettingsPage()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


    fun onCreate(savedInstanceState: Bundle?) {
        onCreate(savedInstanceState)

        setContent {
            UtilityAppTheme {
                val navController = rememberNavController()
                MainScreen(HomePage()) // Make sure this is your main composable
            }
        }
    }


fun setContent(function: @Composable () -> Unit) {
    TODO("Not yet implemented")
}












