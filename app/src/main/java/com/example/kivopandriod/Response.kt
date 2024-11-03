package com.example.kivopandriod

import android.os.Bundle
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import com.example.kivopandriod.responseData.ResponseItem
import com.example.kivopandriod.responseData.ResponseAdapter


class Response : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.reponse_list_view)

        // Beispiel-Daten für die Liste
        val responses = listOf(
            ResponseItem("M", "Max Muster", R.drawable.ic_check_circle),
            ResponseItem("D", "Dieter Ausnahme", R.drawable.ic_open),
            ResponseItem("F", "Fridolin Fröhlich", R.drawable.ic_check_circle),
            ResponseItem("P", "Peter Prüde", R.drawable.ic_check_circle),
            ResponseItem("S", "Susi Sommer", R.drawable.ic_cancel),
            ResponseItem("T", "Thorsten Trauer", R.drawable.ic_check_circle),
            ResponseItem("W", "Wolfgang Wunder", R.drawable.ic_open)
        )

        val test = responses.listIterator()


        // Zugriff auf die ListView und Setzen des Adapters
        val listView: ListView = findViewById(R.id.responseListView)
        val adapter = ResponseAdapter(this, responses)
        listView.adapter = adapter
    }


}
