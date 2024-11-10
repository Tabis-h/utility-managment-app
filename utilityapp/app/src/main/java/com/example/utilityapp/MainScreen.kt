package com.example.utilityapp.page

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.NavHostController
import com.example.utilityapp.AuthViewModel
import com.example.utilityapp.Navitem
import com.example.utilityapp.R
import com.example.utilityapp.pages.HomePage
import com.example.utilityapp.pages.NotificationPage
import com.example.utilityapp.pages.ProfilePage
import com.example.utilityapp.pages.SettingsPage

import com.example.utilityapp.ui.theme.Worker

import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.pages.WorkerCard


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(modifier: Modifier = Modifier, navController: NavHostController) {


    val navItemList = listOf(
        Navitem("Home", Icons.Default.Home, badgeCount=0),
        Navitem("Notification" ,Icons.Default.Notifications, badgeCount = 0),
        Navitem("Settings",Icons.Default.Settings, badgeCount = 0),
        Navitem("Profile", Icons.Default.AccountBox, badgeCount = 0),
    )

    var selectedIndex by remember {
        mutableIntStateOf(0)
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar {
                navItemList.forEachIndexed { index, navItem ->
                    NavigationBarItem(
                        selected =  selectedIndex == index ,
                        onClick = {
                            selectedIndex = index
                        },
                        icon = {
                            BadgedBox(badge = {
                                if(navItem.badgeCount>0)
                                    Badge(){
                                        Text(text = navItem.badgeCount.toString())
                                    }
                            }) {
                                Icon(imageVector = navItem.icon, contentDescription = "Icon")
                            }

                        },
                        label = {
                            Text(text = navItem.label)
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        ContentScreen(modifier = Modifier.padding(innerPadding),selectedIndex)
    }
}


@Composable
fun ContentScreen(modifier: Modifier = Modifier, selectedIndex: Int) {
    // Example values for profile page
    val username = "John Doe"
    val email = "john.doe@example.com"
    val profileImage: Painter = painterResource(id = R.drawable.default_profile_image) // Use a valid image resource ID

    // Callback functions for Edit Profile and Logout buttons
    val onEditProfileClick: () -> Unit = {
        // Handle Edit Profile click
        println("Edit Profile clicked")
    }

    val onLogoutClick: () -> Unit = {
        // Handle Logout click
        println("Logout clicked")
    }

    when (selectedIndex) {
        0 -> HomePage()
        1 -> NotificationPage()
        2 -> SettingsPage()
        3 -> {
            // Pass required parameters to ProfilePage
            ProfilePage(
                profileImage = profileImage,   // Pass the Painter object for the profile image
                username = username,           // Pass the username string
                email = email,                 // Pass the email string
                onEditProfileClick = onEditProfileClick,   // Pass the callback for edit profile
                onLogoutClick = onLogoutClick  // Pass the callback for logout
            )
        }
    }
}


@Composable
fun MainScreen(navController: NavHostController, authViewModel: AuthViewModel) {
    val workers = listOf(
        Worker("https://example.com/photo1.jpg", "John Doe", "Graphic Designer", "$50"),
        Worker("https://example.com/photo2.jpg", "Jane Smith", "Web Developer", "$60"),
        // Add more workers here
    )


}


@Preview(showBackground = true)
@Composable
fun PreviewMainScreen() {
    val navController = rememberNavController() // Create a local NavController for preview
    MainScreen(navController = navController)
}
@Composable
fun MainScreen(homePage: Unit) {
    // Sample worker data
    val worker = Worker(
        name = "John Doe",
        workType = "Electrician",
        cost = "$20/hr",
        photoUrl = "https://example.com/photo.jpg"
    )

    // Display the WorkerCard
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        WorkerCard(worker = worker)
    }
}



