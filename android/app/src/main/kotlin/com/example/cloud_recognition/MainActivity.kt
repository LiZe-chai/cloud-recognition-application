package com.example.cloud_recognition

import android.os.Bundle
import android.util.Log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import org.opencv.android.OpenCVLoader
import org.opencv.core.*
import org.opencv.imgproc.Imgproc

class MainActivity: FlutterActivity() {

    private val CHANNEL = "cloud_opencv"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "Initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialized")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "processMask") {

                    val args = call.arguments as Map<String, Any>

                    val maskAny = args["mask"]

                    val mask: FloatArray = when (maskAny) {
                        is FloatArray -> maskAny
                        is ArrayList<*> -> maskAny.map { (it as Number).toFloat() }.toFloatArray()
                        else -> throw IllegalArgumentException("Unsupported mask type: ${maskAny?.javaClass}")
                    }

                    val width = args["width"] as Int
                    val height = args["height"] as Int

                    val boxes = processMask(mask, width, height)
                    result.success(boxes)
                }
            }
    }

    private fun processMask(
        mask: FloatArray,
        width: Int,
        height: Int
    ): List<Map<String, Int>> {

        val mat = Mat(height, width, CvType.CV_32F)
        mat.put(0, 0, mask)

        val binary = Mat()
        Imgproc.threshold(mat, binary, 0.5, 1.0, Imgproc.THRESH_BINARY)
        binary.convertTo(binary, CvType.CV_8U, 255.0)

        val kernel = Imgproc.getStructuringElement(
            Imgproc.MORPH_RECT,
            Size(5.0, 5.0)
        )

        Imgproc.morphologyEx(
            binary,
            binary,
            Imgproc.MORPH_CLOSE,
            kernel
        )

        val labels = Mat()
        val stats = Mat()
        val centroids = Mat()

        val numLabels = Imgproc.connectedComponentsWithStats(
            binary,
            labels,
            stats,
            centroids
        )

        val boxes = mutableListOf<Map<String, Int>>()

        for (i in 1 until numLabels) {

            val area = stats.get(i, Imgproc.CC_STAT_AREA)[0]

            if (area < 100) continue

            val x = stats.get(i, Imgproc.CC_STAT_LEFT)[0].toInt()
            val y = stats.get(i, Imgproc.CC_STAT_TOP)[0].toInt()
            val w = stats.get(i, Imgproc.CC_STAT_WIDTH)[0].toInt()
            val h = stats.get(i, Imgproc.CC_STAT_HEIGHT)[0].toInt()

            boxes.add(mapOf(
                "x" to x,
                "y" to y,
                "w" to w,
                "h" to h
            ))
        }

        return boxes
    }
}