package com.example.utilityapp

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.database.FirebaseDatabase

class AuthViewModel : ViewModel() {
    private val auth: FirebaseAuth = FirebaseAuth.getInstance()
    private val database = FirebaseDatabase.getInstance().reference // Initialize the database reference
    private val _authState = MutableLiveData<AuthState?>()
    val authState: MutableLiveData<AuthState?> = _authState

    private lateinit var googleSignInClient: GoogleSignInClient


    // Check if the user is currently authenticated
    fun checkAuthState() {
        _authState.value = if (auth.currentUser != null) {
            AuthState.Authenticated
        } else {
            AuthState.Unauthenticated
        }
    }

    // Login method using Firebase Authentication
    fun login(email: String, password: String) {
        if (email.isEmpty() || password.isEmpty()) {
            _authState.value = AuthState.Error("Email and password cannot be empty")
            return
        }
        _authState.value = AuthState.Loading
        auth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener { task ->
                _authState.value = if (task.isSuccessful) {
                    AuthState.Authenticated
                } else {
                    AuthState.Error(task.exception?.message ?: "Login failed")
                }
            }
    }

    fun initializeGoogleSignIn(activity: Activity) {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(activity.getString(R.string.default_web_client_id)) // Replace with your web client ID from Firebase
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(activity, gso)
    }
    fun googleSignInIntent(): Intent {
        return googleSignInClient.signInIntent
    }
    fun firebaseAuthWithGoogle(idToken: String) {
        val credential = GoogleAuthProvider.getCredential(idToken, null)
        _authState.value = AuthState.Loading
        auth.signInWithCredential(credential)
            .addOnCompleteListener { task ->
                _authState.value = if (task.isSuccessful) {
                    AuthState.Authenticated
                } else {
                    AuthState.Error(task.exception?.message ?: "Google sign-in failed")
                }
            }
    }
    // Signup method using Firebase Authentication and Realtime Database
    fun signup(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        mobileNumber: String
    ) {
        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty() || mobileNumber.isEmpty()) {
            _authState.value = AuthState.Error("All fields must be filled")
            return
        }
        _authState.value = AuthState.Loading
        auth.createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    // Store additional user details
                    val userId = auth.currentUser?.uid
                    val userDetails = User(firstName, lastName, email, mobileNumber)
                    userId?.let {
                        database.child("users").child(it).setValue(userDetails)
                            .addOnCompleteListener { dbTask ->
                                _authState.value = if (dbTask.isSuccessful) {
                                    AuthState.Authenticated
                                } else {
                                    AuthState.Error(dbTask.exception?.message ?: "Database error")
                                }
                            }
                    }
                } else {
                    _authState.value = AuthState.Error(task.exception?.message ?: "Signup failed")
                }
            }
    }

    // Sign out method
    fun signOut() {
        auth.signOut()
        _authState.value = AuthState.Unauthenticated
    }

    // Clear the error state
    fun clearError() {
        if (_authState.value is AuthState.Error) {
            _authState.value = null // or AuthState.Unauthenticated if that fits your UI flow
        }
    }
}


// User data class to hold user information
data class User(
    val firstName: String = "",
    val lastName: String = "",
    val email: String = "",
    val mobileNumber: String = ""
)

sealed class AuthState {
    object Authenticated : AuthState()
    object Unauthenticated : AuthState()
    object Loading : AuthState()
    data class Error(val message: String) : AuthState()
}
