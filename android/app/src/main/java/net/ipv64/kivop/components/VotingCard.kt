package net.ipv64.kivop.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.shape.RoundedCornerShape

// Farben anpassen
private val cardBackgroundColor = Color(0xFFEEEFE3) // Hintergrundfarbe
private val textColor = Color(0xFF1A1C15) // Textfarbe

@Composable
fun VotingCard(
    title: String = "Abstimmung",
    options: List<String> = listOf("Option 1", "Option 2", "Option 3", "Enthalten"),
    onOptionSelected: (String) -> Unit = {}
) {
    var selectedOption by remember { mutableStateOf<String?>(null) }

    Card(
        modifier = Modifier
            .width(550.dp)
            .padding(16.dp),
        colors = CardDefaults.cardColors(containerColor = cardBackgroundColor),
        shape = RoundedCornerShape(12.dp) // Abgerundete Ecken
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // Überschrift mit Stil
            Text(
                text = title,
                style = TextStyle(
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    letterSpacing = 0.25.sp,
                    color = textColor
                ),
                modifier = Modifier.padding(bottom = 12.dp)
            )

            // Auswahlmöglichkeiten
            options.forEach { option ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 2.dp)
                        .toggleable(
                            value = (selectedOption == option),
                            onValueChange = {
                                selectedOption = if (it) option else null
                                if (it) onOptionSelected(option)  // Callback on selection
                            }
                        )
                ) {
                    // Optionen am linken Rand
                    Text(
                        text = option,
                        style = TextStyle(
                            fontWeight = FontWeight.Medium,
                            fontSize = 18.sp,
                            letterSpacing = 0.25.sp,
                            color = textColor
                        ),
                        modifier = Modifier.weight(1f) // Links ausrichten
                    )

                    // Kästchen am rechten Rand
                    Checkbox(
                        checked = selectedOption == option,
                        onCheckedChange = { isChecked ->
                            selectedOption = if (isChecked) option else null
                            if (isChecked) onOptionSelected(option)
                        }
                    )
                }
            }
        }
    }
}

@Preview
@Composable
fun PreviewVotingCard() {
    VotingCard(
        onOptionSelected = { selectedOption ->
            println("Option selected: $selectedOption")
        }
    )
}
