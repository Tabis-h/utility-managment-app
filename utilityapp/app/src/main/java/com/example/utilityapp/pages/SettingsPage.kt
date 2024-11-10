package com.example.utilityapp.pages

//noinspection UsingMaterialAndMaterial3Libraries


import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
//noinspection UsingMaterialAndMaterial3Libraries
import androidx.compose.material.*
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp




@Composable
fun SettingsPage(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF1976D2)),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Settings Page",
            fontSize = 40.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White
        )
    }
}





@Composable
fun SettingsPage() {
    Column(modifier = Modifier
        .fillMaxSize()
        .padding(16.dp)) {

        Text(
            text = "Settings",
            fontSize = 24.sp,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        NotificationSettingItem()
        DarkThemeSettingItem()
        PrivacyPolicySettingItem()
        AboutSettingItem()
    }
}

@Composable
fun NotificationSettingItem() {
    var isNotificationsEnabled by remember { mutableStateOf(true) }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = "Enable Notifications", fontSize = 18.sp)
        Spacer(modifier = Modifier.weight(1f))
        Switch(
            checked = isNotificationsEnabled,
            onCheckedChange = {
                val isEnabled = false

                isNotificationsEnabled = it
            }
        )
    }
}

@Composable
fun DarkThemeSettingItem() {
    var isDarkThemeEnabled by remember { mutableStateOf(false) }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = "Dark Theme", fontSize = 18.sp)
        Spacer(modifier = Modifier.weight(1f))
        Switch(
            checked = isDarkThemeEnabled,
            onCheckedChange = {
                val isEnabled = false

                isDarkThemeEnabled = it
            }
        )
    }
}

@Composable
fun PrivacyPolicySettingItem() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .clickable { /* Navigate to Privacy Policy */ },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = "Privacy Policy", fontSize = 18.sp)
    }
}

@Composable
fun AboutSettingItem() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .clickable { /* Navigate to About page */ },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = "About", fontSize = 18.sp)
    }
}

@Preview(showBackground = true)
@Composable
fun PreviewSettingsPage() {
    SettingsPage()
}
