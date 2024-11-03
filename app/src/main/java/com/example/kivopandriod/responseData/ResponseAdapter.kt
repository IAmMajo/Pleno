package com.example.kivopandriod.responseData

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.TextView
import com.example.kivopandriod.R

class ResponseAdapter(context: Context, private val items: List<ResponseItem>) :
    ArrayAdapter<ResponseItem>(context, 0, items) {

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = convertView ?: LayoutInflater.from(context).inflate(R.layout.response, parent, false)

        val item = items[position]

        val initialIcon: TextView = view.findViewById(R.id.initialIcon)
        val nameTextView: TextView = view.findViewById(R.id.name)
        val statusIcon: ImageView = view.findViewById(R.id.responseIcon)

        initialIcon.text = item.initial
        nameTextView.text = item.name
        statusIcon.setImageResource(item.statusIconResId)

        return view
    }
}