package com.example.utilityapp.pages

import android.app.Activity
import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.utilityapp.AuthState
import com.example.utilityapp.AuthViewModel
import com.example.utilityapp.R

@Composable
fun SignupPage(
    modifier: Modifier = Modifier,
    navController: NavController,
    authViewModel: AuthViewModel
) {
    var isWorker by remember { mutableStateOf(false) } // State to toggle between user and worker
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var mobileNumber by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var workType by remember { mutableStateOf("") } // Specific to workers
    var workerPhoto by remember { mutableStateOf("") } // For worker photo URL or upload

    val authState = authViewModel.authState.observeAsState()
    val context = LocalContext.current

    LaunchedEffect(authState.value) {
        when (authState.value) {
            is AuthState.Authenticated -> navController.navigate("home")
            is AuthState.Error -> Toast.makeText(
                context,
                (authState.value as AuthState.Error).message,
                Toast.LENGTH_SHORT
            ).show()

            else -> Unit
        }
    }

    Box(
        modifier = modifier.fillMaxSize()
    ) {
        Image(
            painter = painterResource(id = R.drawable.pagebkg),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        Column(
            modifier = modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = if (isWorker) "Worker Signup" else "User Signup",
                fontSize = 32.sp
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = firstName,
                onValueChange = { firstName = it },
                label = { Text(text = "First Name") }
            )

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = lastName,
                onValueChange = { lastName = it },
                label = { Text(text = "Last Name") }
            )

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text(text = "Email") }
            )

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = mobileNumber,
                onValueChange = { newText ->
                    if (newText.all { it.isDigit() } && newText.length <= 10) {
                        mobileNumber = newText
                    }
                },
                label = { Text(text = "Mobile Number") }
            )

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text(text = "Password") }
            )

            if (isWorker) {
                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = workType,
                    onValueChange = { workType = it },
                    label = { Text(text = "Work Type") }
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = workerPhoto,
                    onValueChange = { workerPhoto = it },
                    label = { Text(text = "Photo URL") }
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = {
                    if (isWorker) {
                        // Handle worker signup
                        authViewModel.signupWorker(
                            firstName,
                            lastName,
                            email,
                            password,
                            mobileNumber,
                            workType,
                            workerPhoto
                        )
                    } else {
                        // Handle user signup
                        authViewModel.signup(firstName, lastName, email, password, mobileNumber)
                    }
                },
                enabled = authState.value != AuthState.Loading
            ) {
                Text(text = "Create Account")
            }

            Spacer(modifier = Modifier.height(8.dp))

            TextButton(onClick = { navController.navigate("login") }) {
                Text(text = "Already have an account? Login")
            }

            Spacer(modifier = Modifier.height(8.dp))

            TextButton(onClick = { isWorker = !isWorker }) {
                Text(text = if (isWorker) "Switch to User Signup" else "Switch to Worker Signup")
            }
        }
    }
}
