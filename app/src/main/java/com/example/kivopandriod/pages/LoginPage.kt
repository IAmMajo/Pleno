package com.example.kivopandriod.pages

import Login
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.example.kivopandriod.components.CustomButton
import com.example.kivopandriod.components.CustomInputField
import com.example.kivopandriod.ui.theme.Background_light
import com.example.kivopandriod.ui.theme.Primary_dark
import com.example.kivopandriod.ui.theme.Text_light
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LoginActivity

var couroutineScope = CoroutineScope(Dispatchers.IO)

@Composable
fun LoginScreen(navController: NavController){
    Column(modifier = Modifier
        .background(color = Background_light)
        .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
        ){
        //TODO: CHANGE LOGIN PAGE!!!
        val annotatedString = buildAnnotatedString {
            append("Log dich in deinen ")
            withStyle(style = SpanStyle(color = Primary_dark)) {
                append("Account")
            }
            append(" ein!")
        }
        Text(text = annotatedString,fontSize = 24.sp, color = Text_light,fontWeight = FontWeight.Bold)
        Column(
            modifier = Modifier
                .fillMaxHeight(),

            verticalArrangement = Arrangement.Center,
        ) {
            var username by remember { mutableStateOf("") }
            CustomInputField(
                label = "Username",
                placeholder = "Enter your username",
                horizontalPadding = 0.dp,
                verticalPadding = 0.dp,
                value = username,
                onValueChange = {username = it}
            )
            Spacer(Modifier.size(12.dp))
            var password by remember { mutableStateOf("")}
            CustomInputField(
                label = "Passwort",
                placeholder = "Enter your passwort",
                isPasswort = true,
                horizontalPadding = 0.dp,
                verticalPadding = 0.dp,
                value = password,
                onValueChange = {password = it}
            )
            Spacer(Modifier.size(12.dp))
            CustomButton(
                text = "Login",
                onClick = {
                    couroutineScope.launch {
                        Login("admin@kivop.ipv64.net", "admin")
                        //navController.navigate("home")
                    }
                    navController.navigate("home")
                },
                color = Primary_dark,
                fontColor = Text_light)
        }
    }
}