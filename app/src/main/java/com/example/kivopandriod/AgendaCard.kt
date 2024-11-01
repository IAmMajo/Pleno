package com.example.kivopandriod

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.Button
import android.widget.FrameLayout
import android.widget.TextView
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import io.noties.markwon.Markwon

class AgendaCard @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    style: Int = 0
) : FrameLayout(context,attrs, style){
    private var textView: TextView
    private val markwon = Markwon.create(context)
    init {
        LayoutInflater.from(context).inflate(R.layout.agendacard, this,true)
        textView = findViewById(R.id.AgendaCard)

        attrs?.let{
            val typedArray = context.obtainStyledAttributes(it, R.styleable.AgendaCard)
            val cardColor = typedArray.getColor(R.styleable.AgendaCard_cardColor, Color.Blue.toArgb())
            val cardFontColor = typedArray.getColor(R.styleable.AgendaCard_cardFontColor, Color.White.toArgb())

            setCardColor(cardColor)
            setCardFontColor(cardFontColor)
        }

    }

    fun setMarkdownText(markdown: String){
        markwon.setMarkdown(textView, markdown)
    }
    fun setCardColor(color: Int) {
        val drawable = textView.background as GradientDrawable
        drawable.setColor(color)
    }
    fun setCardFontColor(color: Int) {
        textView.setTextColor(color)
    }
}