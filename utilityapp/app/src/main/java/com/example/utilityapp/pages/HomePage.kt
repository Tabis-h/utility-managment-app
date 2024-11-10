package com.example.utilityapp.pages

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import coil.compose.AsyncImage
import coil.compose.rememberImagePainter
import com.example.utilityapp.AuthState
import com.example.utilityapp.AuthViewModel
import com.example.utilityapp.ui.theme.Worker
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text


@Composable
fun HomePage(modifier: Modifier = Modifier, navController: NavController,authViewModel: AuthViewModel) {
    val authState = authViewModel.authState.observeAsState()

    LaunchedEffect(authState.value) {
        when(authState.value){
            is AuthState.Authenticated -> Unit
            is AuthState.Unauthenticated -> navController.navigate("login")
            else -> Unit
        }
    }

    Column (
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = androidx.compose.ui.Alignment.CenterHorizontally
    ){
        Text(text = "Home Page", fontSize = 32.sp)
        TextButton(onClick =  {
            authViewModel.signOut()
        }) {
            Text(text = "Logout")

        }

    }
}


@Composable
fun HomePage(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF1976D2)),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Home Page",
            fontSize = 40.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color.White
        )
    }
}



@Composable
fun WorkerCard(worker: Worker) {
    Card(
        shape = RoundedCornerShape(8.dp),
        elevation = CardDefaults.cardElevation(4.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Worker Photo
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .background(Color.Gray, shape = CircleShape)
            )



            Spacer(modifier = Modifier.width(16.dp))

            // Worker Details
            Column {
                Text(
                    text = worker.name,
                    style = MaterialTheme.typography.titleLarge // Use a specific text style
                )
                Text(
                    text = worker.workType,
                    style = MaterialTheme.typography.bodyMedium, // Use a specific text style
                    color = Color.Gray
                )
                Text(
                    text = "Starting at ${worker.cost}",
                    style = MaterialTheme.typography.titleMedium, // Use a specific text style
                    color = Color.Black
                )
            }
        }
    }
}

@Composable
fun Spacer(modifier: Any) {
    TODO("Not yet implemented")
}




fun items(workers: List<Worker>, any: @Composable Any) {
    TODO("Not yet implemented")
}

@Composable
fun LazyColumn(content: @Composable () -> Unit) {
    TODO("Not yet implemented")
}
