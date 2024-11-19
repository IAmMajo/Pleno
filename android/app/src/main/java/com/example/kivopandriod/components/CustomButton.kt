package com.example.kivopandriod.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Preview
@Composable
fun CustomButton(
    modifier: Modifier = Modifier,
    text: String = "Button",
    color: Color = Color.Gray,
    fontColor: Color = Color.Black,
    onClick: () -> Unit = {},
){
    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .fillMaxWidth()
            .height(60.dp) //todo: get dp from stylesheet
            .background(
                color = color,
                shape = RoundedCornerShape(16.dp) //todo: get dp from stylesheet
            )
            .clickable(onClick = onClick)

    ){
        Text(text, color = fontColor)
    }
}