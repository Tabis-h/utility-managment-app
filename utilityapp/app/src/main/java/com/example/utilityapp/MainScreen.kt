package com.example.utilityapp.page

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.utilityapp.AuthViewModel
import com.example.utilityapp.Navitem
import com.example.utilityapp.pages.HomePage
import com.example.utilityapp.pages.NotificationPage
import com.example.utilityapp.pages.ProfilePage
import com.example.utilityapp.pages.SettingsPage

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    modifier: Modifier = Modifier,
    navController: NavController,
    authViewModel: AuthViewModel
) {
    val navItemList = listOf(
        Navitem("", Icons.Default.Home, badgeCount = 0),
        Navitem("", Icons.Default.Notifications, badgeCount = 0), // Abbreviate label if needed
        Navitem("", Icons.Default.Settings, badgeCount = 0),
        Navitem("", Icons.Default.AccountBox, badgeCount = 0),
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
                                if (navItem.badgeCount > 0) {
                                    Badge { Text(text = navItem.badgeCount.toString()) }
                                }
                            }) {
                                Icon(
                                    imageVector = navItem.icon,
                                    contentDescription = navItem.label,
                                    modifier = Modifier.size(28.dp) // Adjust icon size if needed
                                )
                            }
                        },
                        label = {
                            Text(
                                text = navItem.label,
                                fontSize = 11.sp, // Adjust font size here
                                maxLines = 1 // Ensure single-line display
                            )
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        ContentScreen(modifier = Modifier.padding(innerPadding), selectedIndex, navController, authViewModel)
    }
}


@Composable
fun ContentScreen(
    modifier: Modifier = Modifier,
    selectedIndex: Int,
    navController: NavController,
    authViewModel: AuthViewModel
) {
    when (selectedIndex) {
        0 -> HomePage(navController = navController, authViewModel = authViewModel)
        1 -> NotificationPage()
        2 -> SettingsPage()
        3 -> ProfilePage()
    }
}
