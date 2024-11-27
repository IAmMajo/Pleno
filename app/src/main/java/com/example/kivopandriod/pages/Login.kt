package com.example.kivopandriod.pages

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.kivopandriod.components.CustomButton
import com.example.kivopandriod.components.CustomInputField
import com.example.kivopandriod.ui.theme.Background_light
import com.example.kivopandriod.ui.theme.Primary_dark
import com.example.kivopandriod.ui.theme.Text_light
import kotlin.text.append

@Composable
fun LoginPage(){
    Column(modifier = Modifier
        .background(color = Background_light)
        .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
        ){
        val annotatedString = buildAnnotatedString {
            withStyle(style = SpanStyle(color = Color.Red)) {
                append("Log ")
            }
            withStyle(style = SpanStyle(color = Color.Blue)) {
                append("dich ")
            }
            withStyle(style = SpanStyle(color = Color.Green)) {
                append("in ")
            }
            append("dein Account ein!")
        }
        Text(text = annotatedString,fontSize = 32.sp)
        Column(
            modifier = Modifier
                .fillMaxHeight(),
            verticalArrangement = Arrangement.Center,
        ) {
            CustomInputField(label = "Username", placeholder = "Enter your username", horizontalPadding = 0.dp, verticalPadding = 0.dp)
            Spacer(Modifier.size(12.dp))
            CustomInputField(label = "Passwort", placeholder = "Enter your passwort", isPasswort = true, horizontalPadding = 0.dp, verticalPadding = 0.dp)
            Spacer(Modifier.size(12.dp))
            CustomButton(text = "Login", onClick = {}, color = Primary_dark, fontColor = Text_light)

        }
    }
}