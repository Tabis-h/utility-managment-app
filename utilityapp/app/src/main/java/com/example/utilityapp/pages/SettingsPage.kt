import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.utilityapp.R

@Composable
fun UserProfileScreen(
    profileImage: Painter,
    username: String,
    email: String,
    onEditProfileClick: () -> Unit,
    onLogoutClick: () -> Unit,
    onSettingsClick: () -> Unit,
    onFriendsClick: () -> Unit,
    onPrivacyPolicyClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top
    ) {
        Spacer(modifier = Modifier.height(24.dp))

        // Profile Image
        Image(
            painter = profileImage,
            contentDescription = "Profile Image",
            modifier = Modifier
                .size(120.dp)
                .background(MaterialTheme.colorScheme.primary, CircleShape)
                .padding(3.dp),
            contentScale = ContentScale.Crop
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Username
        Text(
            text = username,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )

        // Email
        Text(
            text = email,
            fontSize = 16.sp,
            color = Color.Gray
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Edit Profile Button
        Button(
            onClick = onEditProfileClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Edit Profile")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Settings Button
        OutlinedButton(
            onClick = onSettingsClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Settings")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Friends Button
        OutlinedButton(
            onClick = onFriendsClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Friends")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Privacy Policy Button
        OutlinedButton(
            onClick = onPrivacyPolicyClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Privacy Policy")
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Logout Button
        OutlinedButton(
            onClick = onLogoutClick,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Logout")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun UserProfileScreenPreview() {
    UserProfileScreen(
        profileImage = painterResource(id = R.drawable.profile_picture),
        username = "John Doe",
        email = "john.doe@example.com",
        onEditProfileClick = { /* Handle Edit Profile Click */ },
        onLogoutClick = { /* Handle Logout Click */ },
        onSettingsClick = { /* Handle Settings Click */ },
        onFriendsClick = { /* Handle Friends Click */ },
        onPrivacyPolicyClick = { /* Handle Privacy Policy Click */ }
    )
}

class SettingsPage {

}
