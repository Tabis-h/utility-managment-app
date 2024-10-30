package com.example.smartutilitymanagment

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase


class SignupActivity : AppCompatActivity() {
    var signupName: EditText? = null
    var signupUsername: EditText? = null
    var signupEmail: EditText? = null
    var signupPassword: EditText? = null
    var loginRedirectText: TextView? = null
    var signupButton: Button? = null
    var database: FirebaseDatabase? = null
    var reference: DatabaseReference? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_singup)
        signupName = findViewById<EditText>(R.id.signup_name)
        signupEmail = findViewById(R.id.signup_email)
        signupUsername = findViewById<EditText>(R.id.signup_username)
        signupPassword = findViewById<EditText>(R.id.signup_password)
        loginRedirectText = findViewById(R.id.loginRedirectText)
        signupButton = findViewById(R.id.signup_button)
        signupButton.setOnClickListener(View.OnClickListener {
            database = FirebaseDatabase.getInstance()
            reference = database!!.getReference("users")
            val name = signupName.getText().toString()
            val email = signupEmail.getText().toString()
            val username = signupUsername.getText().toString()
            val password = signupPassword.getText().toString()
            val helperClass: HelperClass = HelperClass(name, email, username, password)
            reference!!.child(username).setValue(helperClass)
            Toast.makeText(this@SignupActivity, "You have signup successfully!", Toast.LENGTH_SHORT)
                .show()
            val intent = Intent(
                this@SignupActivity,
                LoginActivity::class.java
            )
            startActivity(intent)
        })
        loginRedirectText.setOnClickListener(View.OnClickListener {
            val intent = Intent(
                this@SignupActivity,
                LoginActivity::class.java
            )
            startActivity(intent)
        })
    }
}
