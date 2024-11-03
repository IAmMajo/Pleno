package com.example.kivopandriod

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.ui.theme.KIVoPAndriodTheme
import androidx.compose.ui.unit.Dp

@Composable
fun CustomInputField(
    label: String,
    placeholder: String,
    modifier: Modifier = Modifier,
    horizontalPadding: Dp = 16.dp,   // Standardwert für horizontales Padding
    verticalPadding: Dp = 8.dp       // Standardwert für vertikales Padding
) {
    val textState = remember { mutableStateOf(TextFieldValue()) }

    Column(
        modifier = modifier
            .padding(horizontal = horizontalPadding, vertical = verticalPadding) // Verwende die Padding-Parameter
            .fillMaxWidth()
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.titleMedium,
            modifier = Modifier.fillMaxWidth()
        )

        OutlinedTextField(
            value = textState.value,
            onValueChange = { textState.value = it },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text(text = placeholder) }
        )
    }
}

@Preview(showBackground = true)
@Composable
fun CustomInputFieldPreview() {
    KIVoPAndriodTheme {
        CustomInputField(
            label = "Text field",
            placeholder = "placeholder"
        )

    }
}
