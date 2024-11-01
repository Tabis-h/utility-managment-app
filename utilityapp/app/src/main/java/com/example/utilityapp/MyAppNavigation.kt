package com.example.utilityapp

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.pages.HomePage
import com.example.utilityapp.pages.LoginPage
import com.example.utilityapp.pages.SignupPage

@Composable
fun MyAppNavigation(modifier: Modifier = Modifier,authViewModel: AuthViewModel) {

    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = "login", builder = {
        composable(route = "login"){
            LoginPage(modifier,navController,authViewModel)
        }

        composable(route = "signup"){
            SignupPage(modifier,navController,authViewModel)
        }

        composable(route = "home"){
            HomePage(modifier,navController,authViewModel)
        }
    })

}