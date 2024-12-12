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

// Farben definieren (einfache Anpassung der Farbpalette)
private val cardBackgroundColor = Color(0xFFEEEFE3) // Hintergrundfarbe der Karte
private val textColor = Color(0xFF1A1C15) // Textfarbe für Titel und Optionen

@Composable
fun VotingCard(
    title: String = "Abstimmung", // Titel der Abstimmung
    options: List<String> = listOf("Option 1", "Option 2", "Option 3", "Enthalten"), // Auswahlmöglichkeiten
    onOptionSelected: (String) -> Unit = {} // Callback, der bei Auswahl einer Option aufgerufen wird
) {
    // Zustandsvariable zum Speichern der ausgewählten Option
    var selectedOption by remember { mutableStateOf<String?>(null) }

    // Karte, die die gesamte Abstimmungskomponente umgibt
    Card(
        modifier = Modifier
            .width(550.dp) // Breite der Karte (kann angepasst werden, z.B. für Responsivität)
            .padding(16.dp), // Außenabstand (Margin) der Karte
        colors = CardDefaults.cardColors(containerColor = cardBackgroundColor), // Hintergrundfarbe der Karte
        shape = RoundedCornerShape(12.dp) // Abgerundete Ecken für ein moderneres Design
    ) {
        // Spalte zur vertikalen Anordnung der Inhalte innerhalb der Karte
        Column(
            modifier = Modifier
                .padding(16.dp) // Innenabstand (Padding) innerhalb der Karte
                .fillMaxWidth() // Breite der Spalte auf die volle Kartenbreite erweitern
        ) {
            // Titel der Abstimmung
            Text(
                text = title, // Titeltext, z.B. "Abstimmung"
                style = TextStyle(
                    fontWeight = FontWeight.Bold, // Fettschrift für den Titel
                    fontSize = 18.sp, // Schriftgröße
                    letterSpacing = 0.25.sp, // Buchstabenabstand
                    color = textColor // Textfarbe
                ),
                modifier = Modifier.padding(bottom = 12.dp) // Abstand unter dem Titel
            )

            // Iteration über die Liste der Optionen
            options.forEach { option ->
                // Eine Zeile pro Option (Text + Checkbox)
                Row(
                    verticalAlignment = Alignment.CenterVertically, // Vertikale Ausrichtung in der Zeile
                    modifier = Modifier
                        .fillMaxWidth() // Zeile nimmt die gesamte Breite ein
                        .padding(vertical = 2.dp) // Vertikaler Abstand zwischen den Zeilen
                        .toggleable( // Ermöglicht das Umschalten zwischen Optionen
                            value = (selectedOption == option), // Überprüft, ob die aktuelle Option ausgewählt ist
                            onValueChange = { isChecked -> // Reaktion auf Änderung
                                selectedOption = if (isChecked) option else null // Zustandsvariable aktualisieren
                                if (isChecked) onOptionSelected(option) // Callback auslösen, wenn ausgewählt
                            }
                        )
                ) {
                    // Text der Option links
                    Text(
                        text = option, // Text der aktuellen Option
                        style = TextStyle(
                            fontWeight = FontWeight.Medium, // Mittlere Schriftstärke
                            fontSize = 18.sp, // Schriftgröße
                            letterSpacing = 0.25.sp, // Buchstabenabstand
                            color = textColor // Textfarbe
                        ),
                        modifier = Modifier.weight(1f) // Text nimmt verfügbaren Platz ein (links ausgerichtet)
                    )

                    // Checkbox rechts
                    Checkbox(
                        checked = selectedOption == option, // Markiert, wenn die Option ausgewählt ist
                        onCheckedChange = { isChecked -> // Reaktion auf Klick auf die Checkbox
                            selectedOption = if (isChecked) option else null // Zustandsvariable aktualisieren
                            if (isChecked) onOptionSelected(option) // Callback auslösen
                        }
                    )
                }
            }
        }
    }
}

// Vorschau für die VotingCard-Komponente (nur in der Entwicklungsumgebung sichtbar)
@Preview
@Composable
fun PreviewVotingCard() {
    VotingCard(
        onOptionSelected = { selectedOption -> 
            println("Option ausgewählt: $selectedOption") // Konsolenausgabe zur Überprüfung der Auswahl
        }
    )
}