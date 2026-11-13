package com.knowdear.composetest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                SampleScreen()
            }
        }
    }
}

@Composable
fun SampleScreen() {
    var count by remember { mutableStateOf(0) }
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF2A2A72), Color(0xFF6C3483))
                )
            )
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("🎓", fontSize = 44.sp)
        Spacer(Modifier.height(10.dp))
        Text(
            "SSC Exam Prep",
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        Text(
            "Sample — Compose (Gradle build)",
            fontSize = 14.sp,
            color = Color(0xCCFFFFFF)
        )
        Spacer(Modifier.height(30.dp))
        Text(
            "Tap count: $count",
            fontSize = 22.sp,
            color = Color(0xFFFFC107),
            fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.height(14.dp))
        Button(onClick = { count++ }) {
            Text("Tap me — Compose works!", fontSize = 17.sp)
        }
        Spacer(Modifier.height(30.dp))
        Text("Made by Know Dear", fontSize = 12.sp, color = Color(0x8CFFFFFF))
    }
}
