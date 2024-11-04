package com.example.utilityapp

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
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
import com.example.utilityapp.pages.HomePage
import com.example.utilityapp.pages.NotificationPage
import com.example.utilityapp.pages.SettingsPage
import com.example.utilityapp.Navitem
import com.example.utilityapp.pages.ProfilePage
import com.example.utilityapp.pages.SettingPage


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(modifier: Modifier = Modifier) {


    val navItemList = listOf(
        Navitem("Home", Icons.Default.Home, badgeCount = 0),
        Navitem("Notification", Icons.Default.Notifications, badgeCount = 5),
        Navitem("Settings", Icons.Default.Settings, badgeCount = 0),
        Navitem(label ="Profile",Icons.Default.AccountBox, badgeCount = 0),
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
fun ContentScreen(modifier: Modifier = Modifier,selectedIndex: Int) {
    when (selectedIndex) {
        0 -> HomePage()
        1 -> NotificationPage()
        2 -> SettingPage()
        3 -> ProfilePage()
    }


}


