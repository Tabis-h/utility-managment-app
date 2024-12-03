package com.example.utilityapp.page

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import com.example.utilityapp.AuthViewModel
import com.example.utilityapp.Navitem
import com.example.utilityapp.R
import com.example.utilityapp.pages.NotificationPage
import com.example.utilityapp.pages.ProfilePage
import SettingsPage
import androidx.activity.ComponentActivity
import com.example.utilityapp.ui.theme.Worker
import com.example.utilityapp.pages.WorkerCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(navController: NavHostController, authViewModel: AuthViewModel) {
    val navItemList = listOf(
        Navitem("Home", Icons.Default.Home, badgeCount = 0),
        Navitem("Notification", Icons.Default.Notifications, badgeCount = 0),
        Navitem("Settings", Icons.Default.Settings, badgeCount = 0),
        Navitem("Profile", Icons.Default.AccountBox, badgeCount = 0),
    )

    var selectedIndex by remember { mutableIntStateOf(0) }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar {
                navItemList.forEachIndexed { index, navItem ->
                    NavigationBarItem(
                        selected = selectedIndex == index,
                        onClick = { selectedIndex = index },
                        icon = {
                            BadgedBox(badge = {
                                if (navItem.badgeCount > 0)
                                    Badge {
                                        Text(text = navItem.badgeCount.toString())
                                    }
                            }) {
                                Icon(imageVector = navItem.icon, contentDescription = "Icon")
                            }
                        },
                        label = { Text(text = navItem.label) }
                    )
                }
            }
        }
    ) { innerPadding ->
        ContentScreen(
            modifier = Modifier.padding(innerPadding),
            selectedIndex = selectedIndex
        )
    }
}

@Composable
fun ContentScreen(modifier: Modifier = Modifier, selectedIndex: Int) {
    // Example values for the profile page
    val profileImage = painterResource(id = R.drawable.default_profile_image) // Replace with your image resource
    val firstName = "John"
    val lastName = "Doe"
    val phoneNumber = "+1234567890"
    val email = "john.doe@example.com"
    val homeAddress = "123 Main St, Springfield, USA"

    // Define click actions
    val onEditProfileClick: () -> Unit = {
        // Handle edit profile click
        println("Edit Profile clicked")
    }
    val onLogoutClick: () -> Unit = {
        // Handle logout click
        println("Logout clicked")
    }

    // Determine which screen to display based on the selected index
    when (selectedIndex) {
        0 -> HomePage()
        1 -> NotificationPage()
        2 -> SettingsPage()
        3 -> {
            // Pass updated parameters to ProfilePage
            ProfilePage(
                profileImage = profileImage,
                firstName = firstName,
                lastName = lastName,
                phoneNumber = phoneNumber,
                email = email,
                homeAddress = homeAddress,
                onEditProfileClick = onEditProfileClick,
                onLogoutClick = onLogoutClick
            )
        }
    }
}


@Composable
fun HomePage() {
    val workers = listOf(
        Worker("https://example.com/photo1.jpg", "John Doe", "Plumber", "$50"),
        Worker("https://example.com/photo2.jpg", "Jane Smith", "Labour", "$60"),

        // Add more workers as needed
    )

    Column(modifier = Modifier.fillMaxSize().padding(8.dp)) {
        workers.forEach { worker ->
            WorkerCard(worker = worker)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PreviewMainScreen() {
    val navController = rememberNavController()
    MainScreen(navController = navController, authViewModel = AuthViewModel())
}



