package com.example.kivopandriod

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.Button
import android.widget.FrameLayout
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb

class CustomButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    style: Int = 0
) : FrameLayout(context,attrs, style){
    private var button: Button

    init{
        LayoutInflater.from(context).inflate(R.layout.button,this,true)
        button = findViewById(R.id.buttonText)


        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.CustomButton)
            val buttonText = typedArray.getString(R.styleable.CustomButton_text) ?: "Default Text"
            val buttonColor = typedArray.getColor(R.styleable.CustomButton_buttonColor, Color.Blue.toArgb())
            val buttonFontColor = typedArray.getColor(R.styleable.CustomButton_fontColor, Color.White.toArgb())

            setText(buttonText)
            setButtonColor(buttonColor)
            setButtonFontColor(buttonFontColor)

            typedArray.recycle()
        }
    }

    fun setText(text: String) {
        button.text = text
    }

    fun setButtonColor(color: Int) {
        val drawable = button.background as GradientDrawable
        drawable.setColor(color)
    }

    fun setButtonFontColor(color: Int) {
        button.setTextColor(color)
    }
    fun setClickListener(listener: OnClickListener) {
        button.setOnClickListener(listener)
    }
}